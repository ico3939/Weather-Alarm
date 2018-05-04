# Weather-Alarm
An iOS alarm app meant to play a different tone based on the current weather condition

Milestone1:
- Features:
  - Ask for the user's location
  - Connect to Darsky ForecastIO API to grab weather information from the user's location
  - The user can choose a time from the date-time picker
  - Once the time is chosen, the timer will begin to count down
  - Once the timer reaches zero, the summary of the current weather is displaced
  
  ![Milestone 1 screenshot](/Screens/Milestone-1.png?raw=true "Milestone 1 screenshot")
  
- For future:
  - add ability to play sound when finished
    - put in some default music
  - create separate screens for picking time
  - refactor some code into separate classes
  
  
  
Milestone 3:
- Features:
  - The user can create and save alarms
    - The alarms will persist even after the program closes
    - The alarms are organized by time closest to the users' time
    - The user can delete alarms by pressing and holding the alarm in the alarm list view nd picking 'delete.'
    - Multiple alarms can be running simultaneously. Once once runs out, the next one will continue counting
  - The user can set an alarm for the timeof sunrise for the next day
  - The app takes in weather information from the DarkSky API and, depending on the type of information is requested, can either retrieve the given location's weather for that point in time or over the course of the next week
    - The main screen's background and dynamically change based on the weather information
    - A different tone is played depending on the weather if the timer runs out
    
   ![Milestone 3 screenshot](/Screens/Milestone3-1.png?raw=true "Milestone 3 screenshot")![Milestone 3 screenshot](/Screens/Milestone3-2.png?raw=true "Milestone 1 screenshot")![Milestone 3 screenshot](/Screens/Milestone3-3.png?raw=true "Milestone 1 screenshot")![Milestone 3 screenshot](/Screens/Milestone3-4.png?raw=true "Milestone 3 screenshot") 
