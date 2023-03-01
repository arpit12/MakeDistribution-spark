import phonenumbers
from phonenumbers import timezone
from phonenumbers import carrier


my_number = phonenumbers.parse("+919782222255")
print(timezone.time_zones_for_number(my_number))
print(carrier.name_for_number(my_number, "en"))


x = phonenumbers.parse("+919782222255", "IN")
phonenumbers.phonenumberutil.number_type(x)
