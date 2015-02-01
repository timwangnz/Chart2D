package org.sixstreams.search.util;

import java.util.HashMap;
import java.util.Map;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

public class DomUtil
{
   public DomUtil(Document doc)
   {
      mDocument = doc;
      mSeqNameMap.put("SearchableObject", new String[]
            { "Title", "Body", "Keywords", "SearchPlugIn", "SearchableAttributes", "SearchResultActions",
              "SearchFacets" });
   }

   public Node updateChildFacet(Node facetNode, String name, String displayNameKey, String attributeName)
   {
      setAttribute(facetNode, "Name", name);
      setAttribute(facetNode, "DisplayNameKey", displayNameKey);
      setAttribute(facetNode, "Attribute", attributeName);
      return facetNode;
   }

   //dom function

   /**
    * Short hand to next mehtod, doucment is used as parent
    */
   public Node getNode(String path, String nodeName, String attrName, String value)
   {
      return getNode(mDocument, path, nodeName, attrName, value);
   }

   /**
    * Find a child in the node by the path in the parent, by attrbute name and value
    *
    * IF the node is not found, a new one will be created.
    * @param parent the node within which the child node is looked.
    * @param path the path upto the nodeName.
    * @param nodeName the node name to find.
    * @param attrName the node attribute name to match
    * @param value the node attribute value to match
    * @return the node.
    */
   /*
    * <abc>
    *     <paramesters>
    *       <parameter name="test" />
    *      <parameter name="test2" />
    *     </parameters>
    * </abc>
    *
    *   test = getNode(abc, "/parameters", "parameter", "name", "test");
*/
   public Node getNode(Node parent, String path, String nodeName, String attrName, String value)
   {
      Node node = getNode(parent, path);
      Node child = node.getFirstChild();
      while (child != null)
      {
         if (child.getNodeName().equals(nodeName))
         {
            Node attr = child.getAttributes().getNamedItem(attrName);
            if (attr != null)
            {
               String attrValue = attr.getTextContent();
               if (value == null && attrValue == null)
               {
                  return child;
               }

               if (value.equals(attrValue))
               {
                  return child;
               }
            }
         }
         child = child.getNextSibling();
      }
      //if not found, create a new one
      child = mDocument.createElement(nodeName);
      node.appendChild(child);
      ((Element) child).setAttribute(attrName, value);
      return child;
   }

   /**
    * Find or Create an element at the path, starting from root,
    * it will create all the elements on the path if not fould
    * @param path
    * @return the leave node of the path
    */
   public Node getNode(String path)
   {
      return getNode(mDocument, path);
   }

   /**
    * Find or Create an element at the path, starting from node,
    * it will create all the elements on the path if not fould
    * @param node
    * @param path
    * @return
    */
   public Node getNode(Node node, String path)
   {
      if (node == null)
      {
         return null;
      }

      String[] names = path.trim().substring(1).split("/");
      Node current = node;
      for (String name: names)
      {
         Node child = getChild(current, name);
         if (child == null)
         {
            child = addChild(current, mDocument.createElement(name));
         }
         current = child;

      }
      return current;
   }

   /**
    * Set text content to the node. If node == null, does nothing
    * @param node
    * @param value
    */
   public void setTextContent(Node node, String value)
   {
      if (node == null)
      {
         return; //does nothin
      }
      node.setTextContent(value);
   }

   /**
    * Set text content to the node as CDATA. If node == null, does nothing
    * @param node
    * @param value
    */
   public void setCDATA(Node node, String value)
   {
      if (node == null)
      {
         return; //does nothin
      }
      node.appendChild(mDocument.createCDATASection(value));
   }

   /**
    * Set attribute value for the node. Does nothing if node, name, or value == null
    * @param node The node to be set attribute
    * @param name The attribute name
    * @param value The attribute value
    */
   public void setAttribute(Node node, String name, String value)
   {
      if (node == null || name == null || value == null)
      {
         return; //does nothing
      }
      ((Element) node).setAttribute(name, value);
   }

   private Node getChild(Node parent, String name)
   {
      Node child = parent.getFirstChild();
      while (child != null)
      {
         if (child.getNodeName().equals(name))
         {
            return child;
         }
         child = child.getNextSibling();
      }
      return null;
   }

   private Node addChild(Node parent, Node child)
   {
      String[] seqNames = (String[]) mSeqNameMap.get(parent.getNodeName());
      if (seqNames == null)
      {
         parent.appendChild(child);
      }
      else
      {
         Node first = parent.getFirstChild();
         while (first != null)
         {
            if (getSequence(child.getNodeName(), seqNames) < getSequence(first.getNodeName(), seqNames))
            {
               parent.insertBefore(child, first);
               return child;
            }
            first = first.getNextSibling();
         }
         parent.appendChild(child);
      }
      return child;
   }

   private int getSequence(String currentName, String[] names)
   {
      int i = 0;
      for (String name: names)
      {
         if (name.equals(currentName.trim()))
         {
            return i;
         }
         i++;
      }
      return -1;
   }
   protected Document mDocument;
   private Map<String, String[]> mSeqNameMap = new HashMap<String, String[]>();
}
