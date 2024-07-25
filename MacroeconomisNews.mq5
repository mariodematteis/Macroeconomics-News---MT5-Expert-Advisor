#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#property script_show_inputs

input string Address = "127.0.0.1";
input int Port = 56776;

bool SendJSONPositionDetails(int socket, string request)
{

   char req[];
   int len = StringToCharArray(request, req) - 1;
   if (len < 0)
      return (false);

   return (SocketSend(socket, req, len) == len);
}

void SendInfo(string msg)
{

   int socket = SocketCreate();
   if (socket != INVALID_HANDLE)
   {
      if (SocketConnect(socket, Address, Port, 5000))
      {
         if (SendJSONPositionDetails(socket, msg))
         {
            Print("JSONMessage correctly sent");
         }
         else
            Print("Failed to send JSONMessage, error ", GetLastError());
      }
      else
      {
         Print("Connection to ", Address, ":", Port, " failed, error ", GetLastError());
      }
      SocketClose(socket);
   }
   else
      Print("Failed to create a socket, error ", GetLastError());
}

int OnInit()
{
   EventSetTimer(1);
   Print("Economic Calendar launched");
   string json_message = "{'message': 'ea_started'}";
   SendInfo(json_message);
   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   string json_message = "{'message': 'ea_closing'}";
   SendInfo(json_message);
   EventKillTimer();
}

void OnTick()
{
}

void OnTimer()
{
   static ulong calendar_change_id = 0;
   static bool first = true;
   MqlCalendarValue values[];
   if (first)
   {
      if (CalendarValueLast(calendar_change_id, values) > 0)
      {
         PrintFormat("%s: Received the Calendar database current ID: change_id=%d", __FUNCTION__, calendar_change_id);
         first = false;
         return;
      }
      else
      {
         int error_code = GetLastError();
         if (error_code == 0)
         {
            PrintFormat("%s: Received the Calendar database current ID: change_id=%d", __FUNCTION__, calendar_change_id);
            first = false;
            return;
         }
         else
         {
            PrintFormat("%s: Failed to get events in CalendarValueLast. Error code: %d", __FUNCTION__, error_code);
            return;
         }
      }
   }

   ulong old_change_id = calendar_change_id;

   if (CalendarValueLast(calendar_change_id, values) > 0)
   {

      long actual_value = values[5];
      long prev_value = values[6];
      long forecast_value = values[8];

      string json_message = "{'message': 'economic_calendar_news', 'size': '" + string(ArraySize(values)) + "'}";
      SendInfo(json_message);
      ArrayPrint(values);
      if (CalendarValueLastByEvent(event_id, calendar_change_id, values) > 0)
      {
         ArrayPrint(values);
         string json_message = "{'message': 'economic_calendar_news', 'event_name': '" + string(values[12]) +
                               "', 'actual_value': '" + string(actual_value) + "', 'previous_value': '" + string(prev_value) + "', 'forecast_value': '" + string(forecast_value) + "'}";
         SendInfo(json_message);
      }
      PrintFormat("%s: Received new Calendar events: %d", __FUNCTION__, ArraySize(values));
      ArrayPrint(values);
      PrintFormat("%s: Previous change_id=%d, new change_id=%d", __FUNCTION__, old_change_id, calendar_change_id);
      ArrayPrint(values);
   }
}
