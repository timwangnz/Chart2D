package org.sixstreams.search;

import java.util.Iterator;
import java.util.List;

import org.sixstreams.search.meta.PrimaryKey;

/**
 * <Code>ChangeListener</code> is an interface one should implement to customize
 * the way the updates are detected.
 */
public interface ChangeListener
{
   String UPDATE = "UPDATE";
   String INSERT = "INSERT";
   String DELETE = "DELETE";

   /**
    * Returns an iterator that allows iterators through the changes.
    *
    * @param ctx searchable context for the request.
    * @param changtype the type of the change requested. Must be one of following
    * <ul>
    * <li>ChangeListener.UPDATE<li>
    * <li>ChangeListener.INSERT<li>
    * <li>ChangeListener.DELETE<li>
    * </ul>
    * @return Returns an iterator of a list of primaryKeys.
    * Return an empty iterator if nothing changed.
    */
   Iterator<List<PrimaryKey>> getChangeList(SearchContext ctx, String changtype);
}
