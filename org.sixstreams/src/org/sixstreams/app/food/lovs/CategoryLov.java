package org.sixstreams.app.food.lovs;

import org.sixstreams.search.data.java.ListOfValues;

public class CategoryLov extends ListOfValues
{
	public CategoryLov()
	{
		int i=1;
		lov.put("" + (i++), "Soup");
		lov.put("" + (i++), "Main Course");
		lov.put("" + (i++), "Bakery");
		lov.put("" + (i++), "Desert");
		lov.put("" + (i++), "Appetizer");
		lov.put("" + (i++), "Breakfast");
		lov.put("" + (i++), "Cookie");
		lov.put("" + (i++), "Salad");
		lov.put("" + (i++), "Vegetarian");
	}
}

