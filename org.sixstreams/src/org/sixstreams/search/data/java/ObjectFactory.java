package org.sixstreams.search.data.java;

import java.util.Collection;

import org.sixstreams.search.IndexableDocument;


public abstract class ObjectFactory
{
   /**
    * For a given object path (name), create an object to be indexed, or
    * that might contain a list of objects that need to be indexed.
    * @param qName the fully qualified name of an object.
    * @return a Java object to be crawled and/or indexed.
    */
   protected abstract Object createObject(String qName);

   /**
    * Returns a list qNames of children for a given object. Typically
    * names of the objects to be indexed.
    * @param object
    * @return
    */
   protected abstract Collection<String> getChildren(Object object);

   /**
    * Returns true if an object should be indexed. Return false would
    * cause this object not indexed, but its children might still
    * be indexed.
    * @param object the object whether should be indexed or not
    * @return true if the object should be indexed.
    */
   protected abstract boolean isIndexable(Object object);

   /**
    * For a given object, returns its name. This can be the any string
    * as long as it is unique for a given path
    * @param object
    * @return
    */
   protected abstract String getQName(Object object);

   /**
    * Implementers must implement the logic that converts its java object into an
    * indexable document as passed argument.
    *
    * This is called when the indexable document is about to be sent
    * to an index engine.
    *
    * In this method, the indexable document should be setup for indexing
    * completely.
    *
    * @param object the value object to be indexed, such as Canvas
    * @param doc the document created for the value object.
    */
   protected abstract void processObject(Object object, IndexableDocument doc);
}
