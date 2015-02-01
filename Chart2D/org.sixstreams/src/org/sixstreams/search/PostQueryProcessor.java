package org.sixstreams.search;


/**
 * <code>PostQueryProcessor</code> interface should be
 * implemented by the search plugin if developers intend
 * to perform some extra tasks on the resulthits before it is
 * returned.
 * <p>
 * Its sole method <code>queryPostProcess</code> is called before the
 * search hits is returned to caller. Developers can perform any
 * tasks on the result hits, such as filtering,
 * display, personalization as well as resolve URL etc.
 * <p>
 * The search hits belongs to a searchable object which can be
 * obtained from the search context passed in.
 *
 */
public interface PostQueryProcessor
{
   /**
    * If implemented, this method is called after a query returned from a search
    * engine.
    *
    * <p>This method is called before the result hits is displayed to the
    * user. Developers can filter out docs that should not be
    * displayed, or apply any transformation to the indexed documents in the
    * list.
    *
    * @param ctx query time context.
    * @param searchHits searchHits for a particular search.
    */
   void queryPostProcess(SearchContext ctx, SearchHits searchHits);
}
