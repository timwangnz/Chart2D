package com.iswim.loader;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.iswim.model.Address;
import com.iswim.model.Meet;
import com.iswim.model.Race;

import com.iswim.model.Swimmer;
import com.iswim.model.Team;

public class MeetLoader
{
	public static String[] strokes = new String[]
	{
		"Unknown Stroke", "Free", "Back", "Breast", "Fly", "IM", "Free Relay", "Medley Relay"
	};

	private Map<String, Swimmer> swimmers = new HashMap<String, Swimmer>();
	//private Map<String, List<Swimmer>> swimmersWithDate = new HashMap<String, List<Swimmer>>();

	private Map<String, Team> teams = new HashMap<String, Team>();
	private Map<Swimmer, List<Race>> races = new HashMap<Swimmer, List<Race>>();

	private Meet meet;
	private String lsc = "PC";

	public MeetLoader(String lsc, String name)
	{
		this.lsc = lsc;
		meet = new Meet(name);
	}

	public Meet getMeet()
	{
		return meet;
	}

	public Date getDate(String dateString)
	{
		try
		{
			if ((dateString == null) || (dateString.trim().length() == 0))
			{
				return null;
			}

			return new SimpleDateFormat("MMddyyyy").parse(dateString);
		}
		catch (ParseException e)
		{
			e.printStackTrace();

			return null;
		}
	}

	public void addMeetHost(String line)
	{
		meet.setOrgId(line.substring(2, 2 + 1));
		meet.setHostName(line.substring(11, 11 + 30));
		meet.setPhone(line.substring(120, 120 + 12));
		meet._setAddress(this.line2Address(meet.getName(), line.substring(41)));
	}

	public Map<String, Swimmer> getSwimmers()
	{
		return swimmers;
	}

	public Map<Swimmer, List<Race>> getRaces()
	{
		return races;
	}

	public Map<String, Team> getTeams()
	{
		return teams;
	}

	public int getNumberOfSwimmers()
	{
		return swimmers.size();
	}

	String swimmerId;
	
	String lastLine;
	Team team;
	String swimmerIdLine;
	void updateSwimmer(Team team, String line)
	{
		swimmerId = line.substring(2, 16);
		swimmerId = swimmerId.replace("*", "_");
		swimmerId = swimmerId.toUpperCase();
		swimmerIdLine = line;
		addRace(lastLine);
		this.team = team;
	}
	
	String lastSwimmerName;
	public void addRace(String line)
	{ 
		try
		{
			// D0
			// char org = line.charAt(2);
			
			// swimmer
			String swimmerName = line.substring(11, 11 + 28);
			if (lastSwimmerName == null || !lastSwimmerName.equals(swimmerName))
			{
				lastSwimmerName = swimmerName;
				lastLine = line;
				return;
			}
			
			lastSwimmerName = swimmerName;


			String citizen = line.substring(52, 52 + 3);
			String dob = line.substring(55, 55 + 8);
			String age = line.substring(63, 63 + 2);
			char gender = line.charAt(66);
			String[] names = swimmerName.trim().split(",");

			String lastName = names[0];
			String firstNameAndMiddle = names[1];
			 

			String middleName = "";
			String firstName = "";
			if (firstNameAndMiddle.length() > 0)
			{
				//
				String[] elements = firstNameAndMiddle.trim().split(" ");
				firstName = elements[0];
				if (elements.length > 1)
				{
					middleName = elements[1];
				}
				
			}


			firstName = "" + firstName.charAt(0) + firstName.substring(1).toLowerCase();
			lastName = "" + lastName.charAt(0) + lastName.substring(1).toLowerCase();
			
			Date dateOfBirth = getDate(dob);
			
			String first = firstName.length() < 3 ? firstName : firstName.substring(0,3);
			String second = middleName.length() == 0 ? "_" : middleName;
			String third = lastName.length() < 4 ? lastName : lastName.substring(0, 4);
				
			while(first.length() < 3)
			{
				first = first + "_";
			}
				
			while(third.length() < 4)
			{
				third = third + "_";
			}
				
			String raceSwimmerId = String.format("%s%s%s%s",new SimpleDateFormat("MMddyy").format(dateOfBirth), first, "_", third);				
			raceSwimmerId = raceSwimmerId.toUpperCase();

			if (!raceSwimmerId.equals(swimmerId))
			{
				String m1 = swimmerId.substring(9,10);
				String m2 = raceSwimmerId.substring(9,10);
				if(!m2.equals(m1))
				{
					swimmerId = raceSwimmerId;
				}
			}
			swimmerId = raceSwimmerId;
			Swimmer swimmer = swimmers.get(swimmerId);
			if (swimmer == null)
			{
				swimmer = new Swimmer(swimmerId);
				swimmer.setId(swimmerId);
				swimmer.setSwimmerUSSNo(swimmerId);
				swimmer.setDateOfBirth(dateOfBirth);
				swimmer.setCitizen(citizen);
				swimmer.setFirstName(firstName);
				swimmer.setLastName(lastName);
				swimmer.setMiddleName(middleName);
				swimmer.setGender("" + gender);
				swimmers.put(swimmerId, swimmer);
			}

			if (team.getTeamCode().equals("PCPC") ||team.getTeamCode().equals("UN")||team.getTeamCode().equals("PCUN"))
			{
				//
			}
			else
			{
				swimmer.setClub(team.getTeamCode());
				swimmer.setLSC(team.getLSC());
			}
			
			Race race = new Race();
			race.setTeam(swimmer.getClub());
			race.setSwimmerDoB(dateOfBirth);
			race.setLSC(swimmer.getLSC());
			race.setSwimmerUSSNo(swimmer.getSwimmerUSSNo());
			//race.setSwimmerId(key);
			race.setGender("" + gender);
			int swimmerAge = parseInt(age);
			try
			{
				race.setSwimmerAge(swimmerAge);
			}
			catch (Exception e)
			{
				// ignore it
			}

			race.setFirstName(firstName);
			race.setLastName(lastName);
			race.setMiddleName(middleName);
			race.setMeet(meet.getUniqueName());
			String distance = line.substring(67, 67 + 4);
			race.setDistance(parseInt(distance));

			char stroke = line.charAt(71);
			race.setStroke(strokes[parseInt("" + stroke)]);
			String eventAge = line.substring(76, 76 + 4);

			if (swimmerAge < 9)
			{
				eventAge = "UN08";
			}
			else if (swimmerAge < 11)
			{
				eventAge = "UN10";
			}
			else if (swimmerAge < 13)
			{
				eventAge = "1112";
			}
			else if (swimmerAge < 15)
			{
				eventAge = "1314";
			}
			else if (swimmerAge < 17)
			{
				eventAge = "1516";
			}
			else if (swimmerAge < 19)
			{
				eventAge = "1718";
			}
			else
			{
				eventAge = "Senior";
			}

			race.setAge(eventAge);

			String date = line.substring(80, 80 + 8);
			race.setDate(getDate(date));

			// race
			// String seedTime = line.substring(88, 88 + 8);
			// char seedCourse = line.charAt(96);
			// race.setSeedTime(stringToTime(seedTime));

			String finalTime = line.substring(115, 115 + 8);
			char finalCourse = line.charAt(123);
			// String finalHeat = line.substring(128, 128 + 2);
			// String finalLane = line.substring(130, 130 + 2);
			// String finalRanking = line.substring(135, 135 + 3);
			// D01 CORTEZ, STEVEN M AUSA0417199614MM 2001 4131402192011
			// 2:03.02YNS Y
			long time = 100000000000L;
			long atime = stringToTime(finalTime);
			if (atime != -1 && atime < time)
			{
				time = atime;
				race.setCourse("" + finalCourse);
				race.setTime(time);
			}

			String prelimTime = line.substring(97, 97 + 8);
			char prelimCourse = line.charAt(105);

			// String prelimHeat = line.substring(124, 124 + 2);
			// String prelimLane = line.substring(126, 126 + 2);
			// String prelimRanking = line.substring(132, 132 + 3);

			atime = stringToTime(prelimTime);
			if (atime != -1 && atime < time)
			{
				time = atime;
				race.setCourse("" + prelimCourse);
				race.setTime(time);
			}

			String swimOffTime = line.substring(106, 106 + 8);
			char swimOffCourse = line.charAt(114);
			atime = stringToTime(swimOffTime);
			if (atime != -1 && atime < time)
			{
				time = atime;
				race.setCourse("" + swimOffCourse);
				race.setTime(time);
			}

			String points = line.substring(138, 138 + 4);
			if (points.trim().length() > 0)
			{

			}

			if (race.getTime() > 0L)
			{
				List<Race> myRaces = races.get(swimmer);
				if (myRaces == null)
				{
					myRaces = new ArrayList<Race>();
					races.put(swimmer, myRaces);
				}
				myRaces.add(race);
			}
		}
		catch (Exception e)
		{
			// we will not add this lie
		}
	}

	public static String timeToString(long time)
	{
		long mins = time / 60000;
		long seconds = time / 1000 - mins * 60;
		long subsecs = time - seconds * 1000 - mins * 60000;
		return "" + mins + ":" + seconds + "." + subsecs / 10;
	}

	public static long stringToTime(String time)
	{
		if (time == null)
		{
			return -1;
		}

		time = time.trim();

		if (time.length() == 0)
		{
			return -1;
		}

		if (time.indexOf(":") != -1)
		{
			String[] times = time.split(":");
			String minute = times[0];
			String seconds = times[1];
			String[] second = seconds.split("\\.");
			seconds = second[0];
			String centSec = second[1];
			return (Long.parseLong(minute) * 60 * 1000) + (Long.parseLong(seconds) * 1000) + (Long.parseLong(centSec) * 10);
		}
		else
		{
			try
			{
				String[] times = time.split("\\.");
				String second = times[0];
				String centSec = times[1];

				return (Long.parseLong(second) * 1000) + (Long.parseLong(centSec) * 10);
			}
			catch (Throwable e)
			{
				return -1;
			}
		}
	}

	void updateTeam(Team team, String line)
	{

		// System.err.println(line);
		//
	}


	Team addTeam(String line)
	{
		Team team = new Team();

		// swimmer
		String teamCode = line.substring(11, 11 + 6);
		String teamLSC = line.substring(11, 11 + 2);
		String teamName = line.substring(17, 17 + 30);
		String shortName = line.substring(47, 47 + 16);

		team.setLSC(teamLSC);
		Address address = line2Address(teamName, line.substring(63));
		team.setTeamCode(teamCode.trim());
		team.setFullName(teamName);
		team.setShortName(shortName);
		team._setAddress(address);
		if (lsc.equals(team.getLSC()))
		{
			teams.put(teamCode, team);
		}
		return team;
	}

	void updateMeet(String line)
	{

		String meetName = line.substring(10, 40);
		meet.setUniqueName(meetName.trim());
		meet._setAddress(this.line2Address(meet.getName(), line.substring(41)));
		meet.setMeetCode(line.charAt(120));

		String meetStart = line.substring(121, 121 + 8);
		String meetEnd = line.substring(129, 129 + 8);
		String altitude = line.substring(137, 137 + 4);

		meet.setStartDate(getDate(meetStart));
		meet.setEndDate(getDate(meetEnd));
		meet.setAltitude(parseInt(altitude));
		meet.setCourse(line.substring(149, 149 + 1));
	}

	public static int parseInt(String value)
	{
		if (value == null || value.trim().length() == 0)
		{
			return -1;
		}

		try
		{
			return Integer.parseInt(value.trim());
		}
		catch (Exception e)
		{
			return -1;
		}
	}

	private Address line2Address(String owner, String line)
	{
		String line1 = line.substring(0, 0 + 22);
		String line2 = line.substring(22, 22 + 22);
		String city = line.substring(44, 44 + 20);
		String state = line.substring(64, 64 + 2);

		String postalCode = line.substring(66, 66 + 10);
		String country = line.substring(76, 76 + 3);
		// String region = line.substring(79, 79 + 1);

		Address address = new Address(owner, line1, line2, city, state, postalCode, country);

		return address;
	}
}

