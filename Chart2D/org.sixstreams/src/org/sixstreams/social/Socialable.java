package org.sixstreams.social;

import java.util.ArrayList;
import java.util.List;

import org.sixstreams.rest.Auditable;
import org.sixstreams.rest.IdObject;

public class Socialable extends IdObject implements Auditable
{
	private List<String> tags = new ArrayList<String>();

	private long liked;
	
	private long followers;
	private long following;
	
	private double rating = new Double(0);
	private long timesRated;

	private String website;
	private String facetbook;
	private String linkedin;
	private String twitter;

	private String imageUrl;
	
	public Socialable()
	{
		super();
	}

	public String getWebsite()
	{
		return website;
	}

	public void setWebsite(String website)
	{
		this.website = website;
	}


	public void like()
	{
		liked++;
	}

	public long getLiked()
	{
		return liked;
	}

	public void setLiked(long liked)
	{
		this.liked = liked;
	}

	public void setTags(List<String> tags)
	{
		if (tags == null || tags.size() == 0)
		{
			return;
		}
		this.tags = new ArrayList<String>(tags);
	}

	public List<String> getTags()
	{
		return tags;
	}

	public void setRating(double rating)
	{
		this.rating = rating;
	}

	public double getRating()
	{
		return rating;
	}

	public void setTimesRated(long noRated)
	{
		this.timesRated = noRated;
	}

	public long getTimesRated()
	{
		return timesRated;
	}

	public String getImageUrl()
	{
		return imageUrl;
	}

	public void setImageUrl(String imageUrl)
	{
		this.imageUrl = imageUrl;
	}

	public long getFollowers()
	{
		return followers;
	}

	public void setFollowers(long followers)
	{
		this.followers = followers;
	}

	public long getFollowing()
	{
		return following;
	}

	public void setFollowing(long following)
	{
		this.following = following;
	}

	public String getFacetbook()
	{
		return facetbook;
	}

	public void setFacetbook(String facetbook)
	{
		this.facetbook = facetbook;
	}

	public String getLinkedin()
	{
		return linkedin;
	}

	public void setLinkedin(String linkedin)
	{
		this.linkedin = linkedin;
	}

	public String getTwitter()
	{
		return twitter;
	}

	public void setTwitter(String twitter)
	{
		this.twitter = twitter;
	}
}
