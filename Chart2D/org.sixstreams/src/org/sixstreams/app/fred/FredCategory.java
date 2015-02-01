package org.sixstreams.app.fred;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.search.util.XMLTable;

@Searchable(title = "name", isSecure = false)
public class FredCategory
{
  @SearchableAttribute(isKey=true)
  private String id;
  private String name;
  private String desc;
  private String parentId;

  FredCategory(XMLTable data)
  {
    id = "" + data.get("id");
    name = "" + data.get("name");
    parentId = "" + data.get("parent_id");
  }

  public void setId(String id)
  {
    this.id = id;
  }

  public String getId()
  {
    return id;
  }

  public void setName(String name)
  {
    this.name = name;
  }

  public String getName()
  {
    return name;
  }

  public void setParentId(String parentId)
  {
    this.parentId = parentId;
  }

  public String getParentId()
  {
    return parentId;
  }

  public void setDesc(String desc)
  {
    this.desc = desc;
  }

  public String getDesc()
  {
    return desc;
  }
}
