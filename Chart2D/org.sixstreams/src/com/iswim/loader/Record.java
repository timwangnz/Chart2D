package com.iswim.loader;

import java.util.ArrayList;

public class Record extends ArrayList{
		String age;
		String gender;
		String name;
		String time;
		String course;
		String stroke;
		String distance;
		
		public Record(String name, String age, String gender, String course, String distance, String stroke, String time)
		{
			this.distance = distance;
			this.age = age;
			this.gender = gender;
			this.name = name;
			this.stroke = stroke.trim();
			this.course = course.trim();
			this.time = time.trim();
		}
		
		public Record(String age, String gender, String course, String distance, String stroke)
		{
			this.distance = distance;
			this.age = age;
			this.gender = gender;
			
			this.stroke = stroke.trim();
			this.course = course.trim();
			
		}

		public String toString()
		{
			return name + "," + distance + "," + stroke + "," + age + "," + gender + "," + course + "," + time;
		}
	
}
