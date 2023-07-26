# CIMIS-Station-Browser

## Overview
 CIMIS-Station-Browser is a Swift-based mobile application designed to provide access to CIMIS Stations and run reports for the latest station data. CIMIS Station Data reports include valuable data points for agricultural and gardening use such as Evapotranspiration (Eto), Soil Temperature, and Precipitation as well as other basic weather data.
 
 ## Inspiration
 Greg Alder - The Yard Posts: https://gregalder.com/yardposts/using-the-evapotranspiration-rate-to-water-your-garden-better/

## Features

1. **Station List:** The home screen of the app provides a list of all active CIMIS stations and allows a user to save the sation for quick access as well as offline availability of station details.

2. **Station Details & Daily Report:** The details screen for each station provides basic information about the CIMIS Station and allows the user to enter a CIMIS API key and fetch the latest Daily Station Report. To create a key:
        - Visit https://cimis.water.ca.gov/Auth/Register.aspx and register an account. 
        - Once registered, login and navigate to https://cimis.water.ca.gov/Auth/EditAccount.aspx
        - At the bottom of the account page, generate a key by tapping `Get AppKey`
        - Store your AppKey for later use and hit `Save`
    Alternatively:
        - Ask a friendly neighborhood developer for their AppKey to borrow.

## Getting Started

To get the CIMIS-Station-Browser running, you'll need to have Xcode installed on your machine. You can clone this project to your local machine to get started.

### Prerequisites

- Xcode 12 or later
- Swift 5 or later
- iOS 13 or later

### Installation

1. Clone the repo:

```bash
git clone https://github.com/eliotw1/CIMIS-Station-Browser.git
```

2. Open the project:

Open the `CIMIS-Station-Browser.xcodeproj` file in Xcode.

3. Run the project:

Select the desired simulator and click the 'Run' button or use the shortcut `Cmd + R`.

## Contributions

Contributions, issues, and feature requests are welcome. Feel free to check the [issues page](https://github.com/eliotw1/CIMIS-Station-Browser/issues) if you want to contribute.

## License

Distributed under the MIT License. See `LICENSE` for more information.
