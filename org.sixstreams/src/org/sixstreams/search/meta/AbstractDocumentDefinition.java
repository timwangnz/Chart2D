package org.sixstreams.search.meta;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Default implemenation of virutal document definition.
 *
 * A document defines strcture of an indexable document, including
 * data source, mAttrDefinitions, security ect.
 * <p>
 * For each document, one can assign one or more security mAttrDefinitions.
 */
public class AbstractDocumentDefinition
   implements DocumentDefinition
{
   private List<DocumentDefinition> documentDefinitions = new ArrayList<DocumentDefinition>();
   private String name;
   // make these thread-safe so that field defs can be added at run time
   private transient List<AttributeDefinition> attrDefinitions = new ArrayList<AttributeDefinition>();
   private transient Map<String, AttributeDefinition> attrDefinitionMap =
      new Hashtable<String, AttributeDefinition>();
   protected transient SearchableObject searchableObject;

   /**
    * Constructs a definition from a name.
    * @param name of the document.
    */
   public AbstractDocumentDefinition(String name)
   {
      this.name = name;
 
   }
   
   public void setAttrValueFor(Object obj, String attrName, Object value)
   {
	   //not implemented
   }
   
   /**
    * Gets a list of mAttrDefinitions that constitute the unique key
    * @return list of mAttrDefinitions.
    */
   public Collection<AttributeDefinition> getKeyAttrDefs()
   {
      ArrayList<AttributeDefinition> list = new ArrayList<AttributeDefinition>();

      for (Iterator<AttributeDefinition> iter = this.attrDefinitions.iterator(); iter.hasNext(); )
      {
         AttributeDefImpl field = (AttributeDefImpl) iter.next();

         if (field.isPrimaryKey())
         {
            list.add(field);
         }
      }
      Collections.sort(list, new AttrDefinitionImplComparator());
      return list;
   }

   public String getName()
   {
      return name;
   }

   private class AttrDefinitionImplComparator
      implements Comparator<AttributeDefinition>
   {
      @Override
      public int compare(AttributeDefinition o1, AttributeDefinition o2)
      {
         return o1.getName().compareTo(o2.getName());
      }
   }

   public Collection<AttributeDefinition> getAttrDefs()
   {
      return attrDefinitions;
   }

   /**
    * Adds a field definition to this document.
    */
   public void addAttrDef(AttributeDefinition node)
   {
      if (node instanceof AttributeDefinition)
      {
         AttributeDefinition field = (AttributeDefinition) node;
         attrDefinitions.add(field);
         field.setDocumentDef(this);
         attrDefinitionMap.put(field.getName(), field);
      }
      else if (node instanceof DocumentDefinition)
      {
         DocumentDefinition docDef = (DocumentDefinition) node;
         docDef.setSearchableObject(searchableObject);
         documentDefinitions.add(docDef);
      }
   }

   /**
    * Returns a list of child DocumentDefinitions.
    * @return list of child mDocumentDefinitions.
    */
   public Collection<DocumentDefinition> getChildDocumentDefs()
   {
      return documentDefinitions;
   }

   /**
    * Sets searchable object reference.
    * @param searchableObject reference to the searchable object this document
    * belonging.
    * @throws IllegalStateException if this document already belong to a searchable object.
    */
   public void setSearchableObject(SearchableObject searchableObject)
   {
      if (this.searchableObject != null && !searchableObject.equals(searchableObject))
      {
         throw new IllegalStateException("Document can not be assigned to a different searchable object");
      }
      this.searchableObject = searchableObject;
   }

   /**
    * Returns searchable object reference this document definition belonging.
    * @return searchable object.
    */

   public SearchableObject getSearchableObject()
   {
      return searchableObject;
   }

   /**
    * String representation of this document.
    * @return
    */
   public String toString()
   {
      return getName();
   }

   /**
    * Removes child node from this node. Implmentation of TreeNode.
    * @param child to be removed.
    */
   public void remove(Object child)
   {
      if (child instanceof DocumentDefinition)
      {
         documentDefinitions.remove(child);
      }
      if (child instanceof AttributeDefinition)
      {
         AttributeDefImpl field = (AttributeDefImpl) child;
         attrDefinitions.remove(field);
         attrDefinitionMap.remove(field.getName());
      }
   }

   /**
    * Returns named field definition.
    * @param fieldName this is the column name (alias name) of the field.
    * @return a field definition, null if not found.
    */
   public AttributeDefinition getAttributeDef(String fieldName)
   {
      return attrDefinitionMap.get(fieldName);
   }

   /**
    * Returns field definition by name
    * @param fieldName field name whose definition is interested in.
    * @return a field definition, null if not found.
    */
   public AttributeDefinition getAttrDefByName(String fieldName)
   {
      Iterator<AttributeDefinition> iter = attrDefinitionMap.values().iterator();

      while (iter.hasNext())
      {
         AttributeDefinition fd = (AttributeDefinition) iter.next();

         if (fieldName.equals(fd.getName()))
         {
            return fd;
         }
      }
      return null;
   }

   protected void setName(String name)
   {
      this.name = name;
   }

   /**
    * Cleans up internal variables.
    */
   public void clear()
   {
      documentDefinitions.clear();
      attrDefinitions.clear();
      attrDefinitionMap.clear();
   }
}
