package org.sixstreams.search.data.java;

import org.sixstreams.search.meta.SearchableObject;

/**
 * Crawlable Java object definition
 */
public abstract class SearchableObjectImpl
   extends SearchableObject
{
   /**
    * Returns crawalbe object factory
    * @return
    */
   abstract public ObjectFactory getObjectFactory();

   /**
    * Default constuctor. It sets the class name to its name field.
    */
   public SearchableObjectImpl()
   {
      super(SearchableObjectImpl.class.getName());
   }

   /**
    * Constructor used by framework to construct the object.
    * @param name - the name of the object.
    */
   public SearchableObjectImpl(String name)
   {
      super(name);
   }

   /**
    * Override default behavior to force a true flag.
    * @return true always.
    */
   public final boolean isActive()
   {
      return true;
   }
}
