The script works extremely fast except the first time to update the whole data. It takes about **_2 minutes_** to update the whole database with **_80_** different channels. This is parallel though, the biggest channel determines the total time. You can set a cronjob for this. It's not a heavy work for the PC. It justs fetch the text data with yt-dlp. **_Video example below:_**

This script is a sophisticated and ingenious tool designed to streamline your **YouTube** experience by organizing and managing your favorite YouTube channels, allowing you to browse and watch videos directly within the script without ever visiting its website. You can **assign the channels with various categories such as "Tech", "Science", "Sports"**, etc. The videos can be played using the 'mpv' media player. Moreover, the script allows you to **sort videos based on view count or duration**; download videos; and even maintain a **"Watch Later"** list. If you combine this script with "[SponsorBlock](https://github.com/po5/mpv_sponsorblock)" lua script created for "mpv", then you will have the ultimate experience. SponsorBlock removes all sponsored segments in a video including intros, outros or similar unnecessary parts. It's normally a browser extension but is also available for "mpv".

**_No browsers, accounts, distractions, crappy algorithm and recommendations, advertisements, sponsors, intros, outros, fillers or empty spaces. We eliminate them all._**

**Required Programs:** dmenu | mpv | **_jq_** | yt-dlp

### FEATURES
- Browse all videos from all channels you set at the same time. You can filter titles through dmenu.
- Browse a channel's videos.
- Select a channel either from the main menu or inside a Category.
- Watch, Download or Put videos in a "Watch Later List".
- Sort videos by view or duration. The default sort is upload date. The only problem is, we can't have the exact upload date, so we can't apply much more advanced filtering. It can be done but it makes fetching the data for the first time too slow.
- The menus have a complex loop system. It always continues where you left off. The script doesn't close itself when you make a selection. So you don't have to run the script over and over again and get to where you left off. You can also press Escape to return to a prior menu.
- You won't see the URLs or any unnecessary things inside dmenu. Just the titles.

### JUSTIFICATION
This script is incredibly beneficial for those who seek a minimalist and focused approach to consuming content on YouTube. By providing a CLI-based interface (dmenu), the script reduces distractions and clutter that are commonly encountered on the Youtube website. It allows users to personalize their content consumption and manage channels more effectively. The script is also remarkably efficient and easy to navigate, providing a user-friendly experience that saves time and promotes productivity.

The script is organized into functions that each perform a specific task, such as updating channel data, retrieving video titles, playing videos, downloading videos, adding videos to the watch later list, and browsing all channels. These functions are called by the main script to provide the user with various options for navigating and interacting with the videos.

The script makes use of various Bash features such as associative arrays, shell redirection and piping, to simplify and streamline the code. It also uses conditionals and loops to handle different user input and error cases. Overall, this script is a powerful and flexible tool for browsing, watching, organizing YouTube channels, and it provides a great example of Bash usage to automate and streamline complex tasks.
