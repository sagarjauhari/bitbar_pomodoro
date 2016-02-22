# Bitbar Pomodoro
Unofficial [Pomodoro](https://en.wikipedia.org/wiki/Pomodoro_Technique) plugin
for the fantastic tool [Bitbar](https://github.com/matryer/bitbar)

![](/images/pic1.png) ![](/images/pic2.png)

## Set daily goal
Latest version allows setting a daily goal for the number of Pomodoros to complete and shows the progress in the dropdown.

![](/images/pic4_progress1.png) ![](/images/pic5_progress2.png)

*Note: Only completed Pomodoros are counted towards the daily goal. Pomodoros stopped midway won't show up in the daily progress bar.*


### Installation
Read the Bitbar [plugins page](https://github.com/matryer/bitbar-plugins) for
instructions on how to install this plugin. Refreshes every 5 seconds but you
can modify the frequency by changing the filename.

### Configuration
The following can be configured in `pomodoro_bitbar.rb`:
- **POMODORO_TIME**: 25 minutes by default
- **TMP_FILE_PATH**: Path of temporary file used to keep track of Pomodoros. You
    shouldn't need to change this unless there are some permissions issues to
    read/write files in the `tmp` directory
- **LOG_FILE_PATH**: Path of file to log Pomodoros. Daily goal tracking is enabled if this path is set.
- **DAILY_GOAL**: Daily goal for number of Pomodoros to complete.
