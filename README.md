# Economic Calendar Project

This project consists of a Python server application and a MetaTrader Expert Advisor (EA) script that work together to monitor and report economic calendar events.

## Components

1. **Python Server (app.py)**
   - Listens for incoming connections from the MetaTrader EA
   - Handles and processes economic calendar data
   - Runs as a multi-threaded application

2. **MetaTrader Expert Advisor (MacroeconomisNews.mq5)**
   - Monitors the economic calendar in MetaTrader
   - Sends updates to the Python server when new events occur

## Setup and Configuration

### Python Server

1. Ensure you have Python installed on your system or install the environment with settings provided in `environment.yml`.
2. The server listens on IP `127.0.0.1` (localhost) and port `56776` by default.

To run the server:

```
python app.py
```

### MetaTrader Expert Advisor

1. Compile the `MacroeconomisNews.cpp` script in your MetaTrader environment.
2. Set the following input parameters if needed:
   - `Address`: The IP address of the Python server (default: "127.0.0.1")
   - `Port`: The port number of the Python server (default: 56776)

## How It Works

1. The Python server starts and waits for connections.
2. The MetaTrader EA is initialized and sends a startup message to the server.
3. The EA monitors the economic calendar for new events.
4. When a new event is detected, the EA sends the event details to the Python server.
5. The Python server processes and logs the received events.
6. When the EA is stopped, it sends a closing message to the server.

## Message Types

The EA sends JSON-formatted messages to the server:

1. EA Started: `{'message': 'ea_started'}`
2. New Economic Event: `{'message': 'economic_calendar_news', 'size': '<number_of_events>'}`
3. EA Closing: `{'message': 'ea_closing'}`

## Notes

- The current implementation focuses on detecting new calendar events rather than processing specific event details.
- The EA uses the MetaTrader `MqlCalendarValue` structure to retrieve event data.
- The Python server uses threading to handle multiple connections simultaneously.

## Future Improvements

- Implement more detailed event processing in the EA script.
- Add error handling and reconnection logic in case of network issues.
- Expand the Python server to store or further analyze the received economic data.