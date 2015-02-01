package org.sixstreams.search;

import java.io.OutputStream;

import java.util.Map;

import org.sixstreams.search.meta.PrimaryKey;

/**
 * An attachment is a document that is associated to an IndexableDocument.
 * It is indexed as part of the indexable document. Blob or Clob columns are
 * normally treated as attachements.
 */
public interface Attachment
{
   String ATTACHMENT_CLASS = "ATTACHMENT_CLASS";
   String TABLE_NAME = "tableName";
   String COLUMN_NAME = "columnName";
   String SCHEMA_NAME = "schemaName";
   String DATA_TYPE_NAME = "dataType";
   String KEY_COUNT = "keyCount";
   String KEY_NAME_PREFIX = "keyName";
   String KEY_VALUE_PREFIX = "keyValue";

   /**
    * Returns Mime type of this attachment. This value is advisory. The consumer
    * might detect the mime type.
    */
   String getType();

   /**
    * Returns configuration parameters that will be used to retrieve the attachment.
    * These name value paires are used to form URL.
    * @return configuration parameters. You must return empty map if nothing needed.
    */
   Map<String, String> getParameters();

   /**
    *Returns the primary key for the attachment. Information can be used to identify
    * the attachment, in form of PrimaryKey.
    * @return primary key value for the attachment.
    */
   PrimaryKey getPrimaryKey();

   /**
    * This method is called to initialize this the object before read method is called.
    * The implementor must set internal status ready for read operation.
    * @param ctx search context.
    * @param parameters configuration parameters.
    * @param pk primary key value.
    */
   void initialize(SearchContext ctx, Map<String, String> parameters, PrimaryKey pk);

   /**
    * Reads the attachment. The implementor is responsible to write the attachment to the
    * output stream provided.
    * @param ctx runtim search context.
    * @param out output stream to write the attachment.
    */
   void read(SearchContext ctx, OutputStream out);
}
