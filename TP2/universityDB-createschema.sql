create table classroom
	(building		varchar(15),
	 room_number		varchar(7),
	 capacity		numeric(4,0),
	 primary key (building, room_number)
	);

create table department
	(dept_name		varchar(20), 
	 building		varchar(15), 
	 budget		        numeric(12,2),
	 primary key (dept_name)
	);

create table course
	(course_id		varchar(8), 
	 title			varchar(50), 
	 dept_name		varchar(20),
	 credits		numeric(2,0),
	 primary key (course_id),
	 foreign key (dept_name) references department
	);

create table teacher
	(ID			varchar(5), 
	 name			varchar(20), 
	 dept_name		varchar(20), 
	 salary			numeric(8,2),
	 primary key (ID),
	 foreign key (dept_name) references department
	);

create table section
	(course_id		varchar(8), 
         sec_id			varchar(8),
	 semester		varchar(6)
		check (semester in ('Fall', 'Winter', 'Spring', 'Summer')), 
	 year			numeric(4,0), 
	 building		varchar(15),
	 room_number		varchar(7),
	 time_slot_id		varchar(4),
	 primary key (course_id, sec_id, semester, year),
	 foreign key (course_id) references course,
	 foreign key (building, room_number) references classroom
	);

create table teaches
	(ID			varchar(5), 
	 course_id		varchar(8),
	 sec_id			varchar(8), 
	 semester		varchar(6),
	 year			numeric(4,0),
	 primary key (ID, course_id, sec_id, semester, year),
	 foreign key (course_id,sec_id, semester, year) references section,
	 foreign key (ID) references teacher
	);

create table student
	(ID			varchar(5), 
	 name			varchar(20), 
	 dept_name		varchar(20), 
	 tot_cred		numeric(3,0),
	 primary key (ID),
	 foreign key (dept_name) references department
	);

create table takes
	(ID			varchar(5), 
	 course_id		varchar(8),
	 sec_id			varchar(8), 
	 semester		varchar(6),
	 year			numeric(4,0),
	 grade		        varchar(2),
	 primary key (ID, course_id, sec_id, semester, year),
	 foreign key (course_id,sec_id, semester, year) references section,
	 foreign key (ID) references student
	);

create table advisor
	(s_ID			varchar(5),
	 i_ID			varchar(5),
	 primary key (s_ID),
	 foreign key (i_ID) references teacher (ID),
	 foreign key (s_ID) references student (ID)
	);

create table time_slot
	(time_slot_id		varchar(4),
	 day			varchar(1),
	 start_hr		numeric(2),
	 start_min		numeric(2),
	 end_hr			numeric(2),
	 end_min		numeric(2),
	 primary key (time_slot_id, day, start_hr, start_min)
	);

create table prereq
	(course_id		varchar(8), 
	 prereq_id		varchar(8),
	 primary key (course_id, prereq_id),
	 foreign key (course_id) references course,
	 foreign key (prereq_id) references course
	);


