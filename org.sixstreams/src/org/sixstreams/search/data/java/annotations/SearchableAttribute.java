package org.sixstreams.search.data.java.annotations;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Documented
@Retention(RetentionPolicy.RUNTIME)
public @interface SearchableAttribute
{
   float boost() default 1.0f;

   boolean isEncrypted() default false; //should engine encrypt the value
   
   boolean isSecure() default false; //should engine secure the value

   boolean isIndexed() default true; //should engine index the value

   boolean isStored() default true; //should engine store the value

   boolean isKey() default false; //if this field is a key

   boolean isDisplayable() default true; //if this field is displayed by default UI

   boolean isRequired() default false; //if this field is displayed by default UI

   boolean isSortable() default false; //if this field is sorted by defualt UI

   boolean isEditable() default false; //if this field is allowed for change from default UI

   boolean isRangeSearchEnabled() default false; //if range search is allowed for this field

   int sequence() default 0; //order used for display

   String foreignKey() default "";
   String aggregateFunction() default ""; //used to calculate aggregate values on a collection, average, summary

   String readableType() default ""; //type for currency, percentage, or format

   String groupName() default "";

   String lov() default "";

   String facetName() default ""; //e.g. address

   String facetPath() default ""; //e.g. country.state.city

   String convertor() default ""; //the data converter, must implement org.sixstreams.data.Convertor interface
}
