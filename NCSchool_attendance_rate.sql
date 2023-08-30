/*Source data: https://www.dpi.nc.gov/about-dpi/education-directory/district-code-and-phone-numbers#SchoolDistricts-1873, https://www.dpi.nc.gov/documents/fbs/accounting/adaadm-ratios-22xlsx/download?attachment */


--------------------------------------------------------------------------------------------Attendance rate each year with school and county information.

SELECT attendance.LEA, attendance.School, LEA.LEA_county, attendance.year, attendance.attendance_daily_avg, attendance.membership_daily_avg, (attendance_daily_avg/membership_daily_avg)*100 as attendance_rate
FROM [dbo].[NC_school_attendance] attendance
JOIN [dbo].[LEA_info] LEA
	ON attendance.LEA = LEA.LEA_code
WHERE attendance_daily_avg > 0
and membership_daily_avg > 0
ORDER BY year, attendance_rate desc;

--------------------------------------------------------------------------------Attendance rate (truncated) each year with school and county information.

SELECT attendance.LEA, attendance.School, LEA.LEA_county, attendance.year, attendance.attendance_daily_avg, attendance.membership_daily_avg, ROUND((attendance_daily_avg/membership_daily_avg)*100, 2,1) as attendance_rate
FROM [dbo].[NC_school_attendance] attendance
JOIN [dbo].[LEA_info] LEA
	ON attendance.LEA = LEA.LEA_code
WHERE attendance_daily_avg > 0
and membership_daily_avg > 0
and (attendance_daily_avg/membership_daily_avg)*100 <= 70
ORDER BY school, year;

SELECT attendance.LEA, attendance.School, LEA.LEA_county, attendance.year, attendance.attendance_daily_avg, attendance.membership_daily_avg,(attendance_daily_avg/membership_daily_avg)*100 as attendance_rate
FROM [dbo].[NC_school_attendance] attendance
JOIN [dbo].[LEA_info] LEA
	ON attendance.LEA = LEA.LEA_code
WHERE attendance_daily_avg > 0
and membership_daily_avg > 0
--and (attendance_daily_avg/membership_daily_avg)*100 = 100
ORDER BY school, year;


SELECT *
FROM [dbo].[LEA_info]

SELECT School, year, attendance_daily_avg, (attendance_daily_avg/membership_daily_avg)*100 as attendance_rate
FROM [dbo].[NC_school_attendance]
WHERE School = 'Gateway Education Center'
--or like 'Piedmont Classical%'
--or like 'Smith%'
Order by school, year;

SELECT School, year, attendance_daily_avg, (attendance_daily_avg/membership_daily_avg)*100 as attendance_rate
FROM [dbo].[NC_school_attendance]
WHERE School like 'Piedmont %'
--or like 'Piedmont Classical%'
--or like 'Smith%'
Order by school, year;

SELECT School, year, attendance_daily_avg, (attendance_daily_avg/membership_daily_avg)*100 as attendance_rate
FROM [dbo].[NC_school_attendance]
WHERE School like '%Smith High School'
--or like 'Piedmont Classical%'
--or like 'Smith%'
Order by school, year;
