package org.sixstreams.rest.writers;

public interface Formatter {

    public String renderPhone(String label, String attrExpr, boolean actionable);

    public String renderEMail(String label, String attrExpr, boolean actionable);

    public String renderAttr(String label, String attrExpr, boolean actionable);

    public String renderMap(String attrExpr, boolean actionable);
}
