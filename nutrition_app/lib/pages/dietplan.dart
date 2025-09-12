import '../core/app_export.dart';

class DietPlanPage extends StatefulWidget {
  const DietPlanPage({Key? key}) : super(key: key);

  @override
  DietPlanPageState createState() => DietPlanPageState();
}

class DietPlanPageState extends State<DietPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _userDetails = {};
  String _dietPlan = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Diet Plan',
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Age'),
                            onSaved: (value) => _userDetails['age'] = value!,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Gender'),
                            onSaved: (value) => _userDetails['gender'] = value!,
                          ),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Weight (kg)'),
                            onSaved: (value) =>
                                _userDetails['weight_kg'] = value!,
                          ),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Height (cm)'),
                            onSaved: (value) =>
                                _userDetails['height_cm'] = value!,
                          ),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Activity Level'),
                            onSaved: (value) =>
                                _userDetails['activity_level'] = value!,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'User Goal'),
                            onSaved: (value) =>
                                _userDetails['user_goal'] = value!,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Dietary Restriction'),
                            onSaved: (value) =>
                                _userDetails['dietary_restriction'] = value!,
                          ),
                          ElevatedButton(
                            onPressed: _submitDetails,
                            child: Text('Submit Details'),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _fetchDietPlan,
                      child: Text('Fetch Diet Plan'),
                    ),
                    Text(_dietPlan),
                  ],
                ),
              ),
      ),
    );
  }

  void _submitDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      // Get username from shared preferences
      String username = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('username')!);
      _userDetails['username'] = username;
      print(_userDetails);
      bool success = await DietPlanNotifier().submitDietDetails(_userDetails);
      setState(() {
        _isLoading = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Details submitted successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to submit details')));
      }
    }
  }

  void _fetchDietPlan() async {
    setState(() {
      _isLoading = true;
    });
    // Get username from shared preferences
    String username = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('username')!);

    try {
      String dietPlan = await DietPlanNotifier().fetchDietPlan(username);
      setState(() {
        _dietPlan = dietPlan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
