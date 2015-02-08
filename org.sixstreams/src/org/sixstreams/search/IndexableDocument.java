package org.sixstreams.search;

/**
 * An indexable document represents an instance of a searchable object
 * that can be indexed by a search engine.
 * <p>
 * <p>A search engine implementation should have its own implementation
 * of this interface to represent its internal data structure and expose
 * it per this interface.
 * <p>The implementation is consumed by various components.
 */
public interface IndexableDocument
   extends Document
{
   String DELETE = "DELETE";
   String UPDATE = "UPDATE";
   String INSERT = "INSERT";
}
