package org.sixstreams.search;

import java.util.List;

/**
 * The <code>PreIndexProcessor</code> interface should be
 * implemented by application developers if they intend
 * to perform data manipulation for a particular searchable object.
 * <p>
 * Its sole method <code>preIndexProcess</code> is called for a list of
 * indexable documents after its has been extracted from the data source.
 * <p>
 * For example, in this method, one can perform lookup,
 * flex field or other aggregations on the indexable document. This is
 * batch operation, still heavy database operations should be avoided.
 *
 * @see org.sixstreams.IndexableDocument IndexableDocument for more details
 *
 */
public interface PreIndexProcessor
{
   /**
    * Called after the documents are extracted from data source and before
    * security methods are called. It provides an eficient way for developers
    * to implement runtime logic an a batch mode. Document passed to you in the
    * collections contains mAttributes, child documents etc.
    *
    * @param ctx runtime context.
    * @param documents a list of IndexableDocuments to be indexed.
    */
   void preIndexProcess(SearchContext ctx, List<IndexableDocument> documents);
}
