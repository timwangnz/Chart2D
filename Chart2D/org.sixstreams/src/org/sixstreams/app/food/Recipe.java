package org.sixstreams.app.food;

import java.util.List;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.social.Socialable;

@Searchable(title = "name", isSecure=false)
public class Recipe extends Socialable
{
	private String name;
	private String desc;
	private int servings;
	private float cost;
	//
	private String cuisine;
	//stir fly, 
	private String method;
	
	private String difficulty;
	//
	private String flavor;
	
	@SearchableAttribute(lov="org.sixstreams.app.food.lovs.CategoryLov")
	private String category;
	
	private String mainIngredient;
	
	private int prepTime;
	private int cookTime;

	private List<String> ingredients;
	private List<String> directions;
	private List<String> tips;
	
	public String getName()
	{
		return name;
	}
	public void setName(String name)
	{
		this.name = name;
	}

	public String getDesc()
	{
		return desc;
	}
	public void setDesc(String desc)
	{
		this.desc = desc;
	}
	public int getPrepTime()
	{
		return prepTime;
	}
	public void setPrepTime(int prepTime)
	{
		this.prepTime = prepTime;
	}
	public int getCookTime()
	{
		return cookTime;
	}
	public void setCookTime(int cookTime)
	{
		this.cookTime = cookTime;
	}
	public List<String> getIngredients()
	{
		return ingredients;
	}
	public void setIngredients(List<String> ingredients)
	{
		this.ingredients = ingredients;
	}
	public List<String> getDirections()
	{
		return directions;
	}
	public void setDirections(List<String> directions)
	{
		this.directions = directions;
	}
	public float getCost()
	{
		return cost;
	}
	public void setCost(float cost)
	{
		this.cost = cost;
	}
	public String getCuisine()
	{
		return cuisine;
	}
	public void setCuisine(String cuisine)
	{
		this.cuisine = cuisine;
	}
	public String getMethod()
	{
		return method;
	}
	public void setMethod(String method)
	{
		this.method = method;
	}
	public String getDifficulty()
	{
		return difficulty;
	}
	public void setDifficulty(String difficulty)
	{
		this.difficulty = difficulty;
	}
	public String getFlavor()
	{
		return flavor;
	}
	
	public void setFlavor(String flavor)
	{
		this.flavor = flavor;
	}
	
	public String getCategory()
	{
		return category;
	}
	
	public void setCategory(String category)
	{
		this.category = category;
	}
	
	public String getMainIngredient()
	{
		return mainIngredient;
	}
	
	public void setMainIngredient(String mainIngredient)
	{
		this.mainIngredient = mainIngredient;
	}
	
	public int getServings()
	{
		return servings;
	}
	public void setServings(int servings)
	{
		this.servings = servings;
	}

	public List<String> getTips()
	{
		return tips;
	}
	public void setTips(List<String> tips)
	{
		this.tips = tips;
	}
}
