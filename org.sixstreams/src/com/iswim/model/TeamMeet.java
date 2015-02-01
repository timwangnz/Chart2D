package com.iswim.model;


public class TeamMeet extends Meet
{
	public TeamMeet(String meet)
	{
		super(meet);
	}
	

	private String team;
	
	public String getTeam()
	{
		return team;
	}
	public void setTeam(String team)
	{
		this.team = team;
	}
	
}
