import os
import time
from typing import List

from dotenv import load_dotenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.wait import WebDriverWait


class Zstu:
    def __init__(self):
        options = Options()
        options.binary_location = r"C:\Program Files (x86)\Google\Chrome Beta\Application\chrome.exe"
        options.add_argument("headless")
        options.add_argument("disable-gpu")
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('window-size=1920,1080')
        self.driver = webdriver.Chrome(options=options)
        self.driver.implicitly_wait(10)

    def locate_and_click(self, CSS_SELECTOR):
        target = self.driver.find_element(By.CSS_SELECTOR, CSS_SELECTOR)
        self.driver.execute_script("arguments[0].scrollIntoView();", target)  # 拖动到可见的元素去
        target.click()

    def test(self):
        self.driver.get(os.getenv("ZSTU_URL"))
        WebDriverWait(self.driver, 10).until(ec.title_is("E浙理"))

        web_element: WebElement = self.driver.find_element_by_css_selector('input[placeholder="Username"]')
        web_element.send_keys(os.getenv('ZSTU_USERNAME'))

        web_element: WebElement = self.driver.find_element_by_css_selector('input[placeholder="Password"]')
        web_element.send_keys(os.getenv('ZSTU_PASSWORD'))

        web_element: WebElement = self.driver.find_element(By.CSS_SELECTOR, '.login-button')
        web_element.click()

        time.sleep(1)
        web_elements: List[WebElement] = self.driver.find_elements(By.CSS_SELECTOR, '.bi-text')
        for web_element in web_elements:
            if "便捷服务" in web_element.text:
                web_element.click()
                break

        web_elements: List[WebElement] = self.driver.find_elements(By.CSS_SELECTOR, '.bi-text')
        for web_element in web_elements:
            if "健康申报" in web_element.text:
                web_element.click()
                break

        time.sleep(6)
        self.driver.switch_to.default_content()
        self.driver.switch_to.frame(
            self.driver.find_element(By.CSS_SELECTOR, 'iframe[src^="/webroot/decision/v10/entry/access"]'))

        if len(self.driver.find_elements_by_css_selector('tbody tr')) == os.getenv('ZSTU_FORM_OPTION_NUM'):
            with open(file='/logs/success', mode='w') as F:
                F.write('0')
                return

        self.locate_and_click("#D17-0-0 .fr-group-span:nth-child(1) .fr-widget-click")
        self.locate_and_click("#D18-0-0 .fr-group-span:nth-child(1) .fr-widget-click")
        self.locate_and_click("#F20-0-0 .fr-group-span:nth-child(1) .fr-widget-click")
        self.locate_and_click("#F21-0-0 .fr-group-span:nth-child(2) .fr-widget-click")
        self.locate_and_click("#F22-0-0 .fr-group-span:nth-child(2) .fr-widget-click")
        self.locate_and_click("#F23-0-0 .fr-group-span:nth-child(2) .fr-widget-click")
        self.locate_and_click("#F25-0-0 .fr-group-span:nth-child(2) .fr-widget-click")
        self.locate_and_click("#F27-0-0 .fr-group-span:nth-child(1) .fr-widget-click")
        self.locate_and_click("#F29-0-0 .fr-group-span:nth-child(2) .fr-widget-click")
        self.locate_and_click("#F32-0-0 .fr-group-span:nth-child(2) .fr-widget-click")
        self.locate_and_click("#F35-0-0 .fr-group-span:nth-child(2) .fr-widget-click")

        self.driver.get_screenshot_as_file("/logs/fill_in_%s.png" % time.strftime("%Y-%m-%d_%H", time.localtime()))

        self.driver.find_element(By.CSS_SELECTOR, '.fr-btn').click()

        time.sleep(2)
        self.driver.get_screenshot_as_file("/logs/status_%s.png" % time.strftime("%Y-%m-%d_%H", time.localtime()))

        if len(self.driver.find_elements_by_css_selector("tr.verify-row-alt")) == 0:
            with open(file='/logs/success', mode='w') as f:
                f.write('1')

        self.driver.quit()


load_dotenv()
zstu = Zstu()
zstu.test()
print('Success!')
