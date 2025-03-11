from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.support.ui import WebDriverWait
import pyautogui
import time

username = ""
password = ""
gecko_diver_path = "/home/kiosk-user/autologin/geckodriver"
# Generate a URL in eventmap roomdisplay and update the url variable below
url = "https://roomdisplay.is.ed.ac.uk/Display?rooms=2104,2105,1846,2106,2107,2108,2109,2021,1849&branding=ev&type=lobbyCalendar&reEntry=0&calendarType=booking"

options = Options()
#options.headless = False  # Optional: If you want Firefox to run in headless mode (no UI)
# Run Firefox in Kiosk mode (not working in sway, getting black srceen)
# options.add_argument("--kiosk") 
service = Service(gecko_diver_path)  # Specify the path to geckodriver

driver = webdriver.Firefox(service=service, options=options)

driver.get(url)

input_field = driver.find_element(By.ID, "email-input")

input_field.send_keys(username)
input_field.send_keys(Keys.RETURN)

time.sleep(10)

pyautogui.press("f11")

input_field_MS_email = driver.find_element(By.TAG_NAME, "input") 
input_field_MS_email.send_keys(username)
input_field_MS_email.send_keys(Keys.RETURN)

time.sleep(10)

input_field_MS_pass = driver.find_element(By.ID, "passwordInput")
input_field_MS_pass.send_keys(password)
input_field_MS_pass.send_keys(Keys.RETURN)

time.sleep(5)

input_field_MS_yes = driver.find_element(By.ID, "idSIButton9")
input_field_MS_yes.click()
