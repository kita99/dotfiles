#!/usr/bin/env python3

from datetime import datetime
# import time
import math


stage_1 = datetime(2022, 10, 24) # Wireframing
stage_2 = datetime(2022, 11, 28) # Frontend building
stage_3 = datetime(2022, 12, 19) # Backend building
stage_4 = datetime(2022, 12, 26) # Integration front + back

now = datetime.now()

delta = stage_2 - now
total_hours = delta.total_seconds() / 60 / 60
remainder_hours = total_hours - math.floor(total_hours)
remainder_minutes = remainder_hours * 60

print(f"Stage 1: {math.floor(total_hours)}h{math.floor(remainder_minutes)}m")

# time.sleep(60)
