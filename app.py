import json
import socket
import threading


class ThreadEconomicCalendar(threading.Thread):
    def __init__(self):
        super().__init__()
        self.session = True
        self.ip_address = '127.0.0.1'
        self.port_address = 56776
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    def EAServer(self, conn, address):
        print(f"New connection established with {address[0]}")
        msg = conn.recv(1024)
        msg = msg.decode("utf-8")
        msg = msg.replace("\'", "\"")
        try:
            msg_json = json.loads(msg)
            main_message = msg_json['message']
            if main_message == "ea_started":
                print("Expert Advisor for macroeconomics calendar correctly running")
            elif main_message == "economic_calendar_news":
                print(f"New news has been received: {msg}")
            elif main_message == "ea_closing":
                print("Expert Advisor for macroeconomics calendar stopped working")
        except json.JSONDecodeError:
            print("JSON not correctly formatted")

        conn.close()

    def run(self) -> None:
        print("Waiting for any economic calendar signal...")
        try:
            self.socket.bind((self.ip_address, self.port_address))
            self.socket.listen()
            while True:
                conn, address = self.socket.accept()
                thread = threading.Thread(target=self.EAServer, args=(conn, address))
                thread.start()
        except socket.error as e:
            print(f"Error occurred: {e}")


if __name__ == '__main__':
    thread_calendar = ThreadEconomicCalendar()
    thread_calendar.start()
