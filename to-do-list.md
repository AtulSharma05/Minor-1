# Project Refactoring: Nutrition to Workout Focus

* [ ] **1. Remove Nutrition Components:**
    * [ ] Identify and remove all files and code related to nutrition, food logging, diet plans, and calorie tracking.
    * [ ] This includes models, views, controllers, services, and UI components.
    * [ ] Files to inspect: `expanding_img_food_track.dart`, `expanding_text_food_track.dart`, `food_data_source.dart`, `dietplan_data_source.dart`, `food_item.dart`, `food_notifiers.dart`, `dietplan_notifier.dart`, `dietplan.dart` and any other related files.
* [ ] **2. Implement Offline Mode:**
    * [ ] Integrate a local storage solution (e.g., Hive, shared_preferences) to store workout data on the device.
    * [ ] Create a data abstraction layer that can switch between the backend and local storage based on an environment flag.
    * [ ] Add a `BACKEND_ENABLED` flag to the `.env` file to toggle between online and offline modes.
* [ ] **3. Implement Workout Logging & Tracking:**
    * [ ] Create a new database schema or modify the existing one to store workout logs.
    * [ ] Develop UI for users to log their workouts (e.g., exercise name, sets, reps, weight, duration).
    * [ ] Implement the logic to save, retrieve, and display workout history.
* [ ] **4. Add Workout Streak Feature:**
    * [ ] Implement a system to track consecutive days of workout activity.
    * [ ] Display the workout streak to the user on their profile or a dedicated dashboard.
* [ ] **5. Introduce a Reward System:**
    * [ ] Add a new field to the user's profile to store in-app tokens.
    * [ ] Implement logic to award tokens for completing workouts and maintaining streaks.
* [ ] **6. Placeholder for ML Pose Detection:**
    * [ ] Integrate a placeholder UI element for camera input.
    * [ ] Add comments in the code to indicate where the ML pose detection logic will be added in the future.
* [ ] **7. Integrate Metronome Beats:**
    * [ ] Research and integrate a metronome feature to help users with their workout tempo.
    * [ ] This could be a visual or auditory metronome.
* [ ] **8. Update Project Theme:**
    * [ ] Choose a new color scheme, fonts, and overall design that reflects a workout and fitness-focused app.
    * [ ] Update the app's UI components with the new theme.
* [ ] **9. Code Cleanup and Refactoring:**
    * [ ] Review the entire codebase to ensure that all remnants of the nutrition features are removed.
    * [ ] Refactor the code for better organization and readability.