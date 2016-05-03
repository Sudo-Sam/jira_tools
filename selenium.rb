require "selenium-webdriver"

driver = Selenium::WebDriver.for :chrome
driver.navigate.to "http://jira.<>.com"

element = driver.find_element(:name, 'login-form-username')
element.send_keys "Hello WebDriver!"
element.submit

puts driver.title

