package com.iswim.loader;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PlistGenerator {

    public static void main(String[] arg) {
		// readFile("/Users/anpwang/Downloads/national.csv", "national");
        //readFile("C:\\Documents and Settings\\anpwang.anpwang-LAP2\\My Documents\\Dropbox\\Private\\swimmingdata\\junior.txt","cba");
        // readFile("C:\\Documents and Settings\\anpwang.anpwang-LAP2\\My Documents\\Dropbox\\Private\\swimmingdata\\junior.txt",
        // "junior");
        // readFile("C:\\Documents and Settings\\anpwang.anpwang-LAP2\\My Documents\\Dropbox\\Private\\swimmingdata\\senior.txt","national");
        // readFile("/Users/anpwang/Downloads/trials.csv", "trials");
        //readFile("/Users/anpwang/Dropbox/Private/swimmingdata/senior.txt","national");
        readFile("/Users/anpwang/Dropbox/Private/swimmingdata/junior.txt", "junior");
        // "junior");
    }

    static void readFile(String fileName, String type) {
        try {
            objects.clear();
            BufferedReader reader = new BufferedReader(new FileReader(fileName));
            String line = reader.readLine();
            while (line != null) {
                line = reader.readLine();
                if (line != null) {
                    addObject(line.split(","), type);
                }
            }
            // print(type);
            printEvents(type);
            // System.err.println(type)
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    static String[] strokes = new String[]{"Free", "Fly", "Back", "Breast",
        "IM"};

    static void print(String cut) {
        System.err
                .println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">");
        System.err.println("<plist version=\"1.0\">");
        System.err.println("<dict>");
        for (String stroke : strokes) {
            System.err.println("<key>" + stroke + "</key>\n<array>");
            for (Record object : objects) {
                if (stroke.equals(nameMapping.get(object.style.toLowerCase()))) {
                    System.err.println(object.toString(cut, stroke));
                }
            }
            System.err.println("</array>");
        }
        System.err.println("</dict>");
        System.err.println("</plist>");
    }

    static void printEvents(String standard) {
        System.err
                .println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">");
        System.err.println("<plist version=\"1.0\">");
        System.err.println("<dict>");
        for (String stroke : strokes) {
            System.err.println("<key>" + stroke + "</key>\n<array>");
            for (Record object : objects) {
                if (stroke.equals(nameMapping.get(object.style.toLowerCase()))) {
                    System.err.println(object.toEvents(standard));
                }
            }
            System.err.println("</array>");
        }
        System.err.println("</dict>");
        System.err.println("</plist>");
    }

    static class JuniorRecord extends Record {

        String a, b, jo, fw, prt;

        JuniorRecord(String[] attrs) {
            this.course = attrs[0];
            this.age = attrs[1];
            this.gender = attrs[2];
            this.distance = attrs[3];
            this.style = attrs[4];

            if (attrs.length > 9) {
                this.b = attrs[5];
                this.a = attrs[6];
                this.jo = attrs[7];
                this.fw = attrs[8];
                this.prt = attrs[9];
            } else if ("UN08".equals(age)) {
                this.b = attrs[5];
                this.a = attrs[6];
                this.prt = attrs[7];
            } else if (attrs.length == 6) {
                this.fw = attrs[5];
            } else {
                for (String attr : attrs) {
                    System.err.print(attr + "\t");
                }
                System.err.println("");
            }
        }

        public String toString(String standard, String stroke) {

            StringBuffer buffer = new StringBuffer(
                    "<key>times</key>\n<array>\n");
            if (standard.equals("cba")) {

                buffer.append(getPair("B", "" + getTime(b)))
                        .append(getPair("A", "" + getTime(a)))
                        .append(getPair("PRT", "" + getTime(prt)));

            } else {
                buffer.append(getPair("FW", "" + getTime(fw)))
                        .append(getPair("JO", "" + getTime(jo)))
                        .append(getPair("PRT", "" + getTime(prt)));
            }
            time = buffer.append("</array>\n").toString();
            return super.toString();
        }

        public String toEvents(String standard) {

            StringBuffer buffer = new StringBuffer(
                    "<key>times</key>\n<array>\n");

            if ("cba".equals(standard)) {
                if (a != null && b != null && prt != null) {
                    buffer.append(getPair("A", "" + getTime(a)));
                    buffer.append(getPair("B", "" + getTime(b)));
                    buffer.append(getPair("PRT", "" + getTime(prt)));
                }
            }

            if ("junior".equals(standard)) {
                buffer.append(getPair("JO", "" + getTime(jo)));
                buffer.append(getPair("FW", "" + getTime(fw)));
                buffer.append(getPair("PRT", "" + getTime(prt)));
            }

            time = buffer.append("</array>\n").toString();
            return super.toEvents(standard);
        }
    }

    static class SeniorRecord extends Record {

        String i, ii, iii, iv;

        SeniorRecord(String[] attrs) {
            this.course = attrs[0];
            this.age = attrs[1];
            this.gender = attrs[2];
            this.distance = attrs[3];
            this.style = attrs[4];

            this.i = attrs[5];
            this.ii = attrs[6];
            this.iii = attrs[7];
            this.iv = attrs[8];
        }

        public String toString() {
            StringBuffer buffer = new StringBuffer();
            buffer.append("<dict>\n");
            buffer.append(super.toString());
            buffer.append("<key>").append("Style").append("</key>\n");
            buffer.append("<string>")
                    .append(nameMapping.get(style.toLowerCase()))
                    .append("</string>\n");

            buffer.append("<key>").append("Senior1").append("</key>\n");
            buffer.append("<string>").append(i).append("</string>\n");
            buffer.append("<key>").append("Seniorii").append("</key>\n");
            buffer.append("<string>").append(ii).append("</string>\n");
            buffer.append("<key>").append("Senioriii").append("</key>\n");
            buffer.append("<string>").append(iii).append("</string>\n");
            buffer.append("<key>").append("Senioriv").append("</key>\n");
            buffer.append("<string>").append(iv).append("</string>\n");

            buffer.append("</dict>");
            return buffer.toString();

        }
    }

    static class Trials extends Record {

        Trials(String[] attrs) {
            this.course = attrs[0];
            this.age = attrs[1];
            this.gender = attrs[2];
            this.distance = attrs[3];
            this.style = attrs[4];
            this.time = attrs[5];
        }

        public String toString(String style, String stroke) {

            StringBuffer buffer = new StringBuffer();

            buffer.append("<key>").append("time").append("</key>\n");
            buffer.append("<string>").append(getTime(time))
                    .append("</string>\n");
            time = buffer.toString();
            return super.toString();

        }
    }

    static class Record {

        String course, age, gender, distance, style, time;

        public String toString() {
            if (time == null || time.length() == 0) {
                return "";
            }
            StringBuffer buffer = new StringBuffer();
            buffer.append("<dict>\n");
            buffer.append("<key>").append("c").append("</key>\n");
            buffer.append("<string>").append(courseName(course))
                    .append("</string>\n");
            buffer.append("<key>").append("g").append("</key>\n");
            buffer.append("<string>").append(gender).append("</string>\n");
            buffer.append("<key>").append("age").append("</key>\n");
            buffer.append("<string>").append(age).append("</string>\n");
            buffer.append("<key>").append("d").append("</key>\n");
            buffer.append("<string>").append(distance).append("</string>\n");
            buffer.append(time);
            buffer.append("</dict>\n");
            return buffer.toString();
        }

        public String toEvents(String standard) {

            StringBuffer buffer = new StringBuffer();
            //for junior standard, we don't have un08
            if (standard.equals("junior") && age.equals("UN08")) {
                return "";
            }

            buffer.append("<dict>\n");
            buffer.append("<key>").append("c").append("</key>\n");
            buffer.append("<string>").append(courseName(course))
                    .append("</string>\n");
            buffer.append("<key>").append("g").append("</key>\n");
            buffer.append("<string>").append(gender).append("</string>\n");
            buffer.append("<key>").append("age").append("</key>\n");
            buffer.append("<string>").append(age)// ageMapping.get(age))
                    .append("</string>\n");
            buffer.append("<key>").append("d").append("</key>\n");
            buffer.append("<string>").append(distance).append("</string>\n");
            buffer.append(time);
            buffer.append("</dict>\n");
            return buffer.toString();
        }

        String toString(String cut, String stroke) {

            StringBuffer buffer = new StringBuffer();

            return buffer.toString();
        }
    }

    static String courseName(String course) {
        if ("m".equals(course)) {
            return "LCM";
        }
        if ("y".equals(course)) {
            return "SCY";
        }
        if ("ym".equals(course)) {
            return "SCM";
        }
        return "SCY";
    }

    static class NationalRecord extends Record {

        String national, jNational, sectional, nationalBonus, jNationalBonus;

        NationalRecord(String[] attrs, boolean bonus) {
            this.course = attrs[0];
            this.age = attrs[1];
            if (bonus) {
                this.age = "Bonus";
            }
            this.gender = attrs[2];
            this.distance = attrs[3];
            this.style = attrs[4];

            if (attrs.length > 9) {

                this.national = attrs[5];
                this.nationalBonus = attrs[6];
                this.jNational = attrs[7];
                this.jNationalBonus = attrs[8];
                this.sectional = attrs[9];

            }

        }

        public String toEvents(String standard) {
            if (!age.equals("Bonus")) {
                StringBuffer buffer = new StringBuffer(
                        "<key>times</key>\n<array>\n");
                buffer.append(getPair("National", "" + getTime(national)))
                        .append(getPair("JrNat", "" + getTime(jNational)))
                        .append(getPair("Sectoinal", "" + getTime(sectional)));

                time = buffer.append("</array>\n").toString();
            } else {
                StringBuffer buffer = new StringBuffer("<key>times</key>\n<array>\n")
                        .append(getPair("Sectoinal", "" + getTime(sectional)));
                buffer.append(getPair("National", "" + getTime(nationalBonus)))
                        .append(getPair("JrNat", "" + getTime(jNationalBonus)));

                time = buffer.append("</array>\n").toString();
            }
            return super.toEvents(standard);

        }

        public String toString(String style, String cut) {
            StringBuffer buffer = new StringBuffer(
                    "<key>times</key>\n<array>\n");
            buffer.append(getPair("National", "" + getTime(national)))
                    .append(getPair("JrNat", "" + getTime(jNational)))
                    .append(getPair("Sectoinal", "" + getTime(sectional)));

            time = buffer.append("</array>\n").toString();

            return super.toString();

        }

        public String toString() {
            StringBuffer buffer = new StringBuffer();
            buffer.append(super.toString());
            buffer.append("<key>").append("Style").append("</key>\n");
            buffer.append("<string>")
                    .append(nameMapping.get(style.toLowerCase()))
                    .append("</string>\n");
            buffer.append("<key>").append("National").append("</key>\n");
            buffer.append("<string>").append(national).append("</string>\n");
            buffer.append("<key>").append("jNational").append("</key>\n");
            buffer.append("<string>").append(jNational).append("</string>\n");
            buffer.append("<key>").append("Sectional").append("</key>\n");
            buffer.append("<string>").append(sectional).append("</string>\n");
            buffer.append("</dict>");
            return buffer.toString();
        }
    }

    static StringBuffer getPair(String key, String value) {
        StringBuffer sb = new StringBuffer("<dict>\n<key>name</key>\n<string>")
                .append(key).append("</string>\n")
                .append("<key>time</key>\n<string>").append(value)
                .append("</string>\n</dict>\n");
        return sb;
    }

    static int getTime(String time) {
        if (time == null) {
            return 0;
        }
        time = time.trim();
        if (time.length() == 0) {
            return 0;
        }
        String[] splitted = time.split(":");
        if (splitted.length == 2) {
            int min = 0;
            if (splitted[0].length() > 0) {
                min = Integer.parseInt(splitted[0]);
            }
            splitted = splitted[1].split("\\.");
            int sec = Integer.parseInt(splitted[0]);
            int hundredthsec = Integer.parseInt(splitted[1]);
            return min * 60000 + sec * 1000 + hundredthsec * 10;
        } else {
            int min = 0;
            splitted = splitted[0].split("\\.");
            int sec = Integer.parseInt(splitted[0]);
            int hundredthsec = Integer.parseInt(splitted[1]);
            return min * 60000 + sec * 1000 + hundredthsec * 10;
        }

    }

    static Map<String, String> nameMapping = new HashMap<String, String>();

    static {
        nameMapping.put("fl", "Fly");
        nameMapping.put("br", "Breast");
        nameMapping.put("bk", "Back");
        nameMapping.put("fr", "Free Relay");
        nameMapping.put("mr", "Medley Relay");
        nameMapping.put("im", "IM");
        nameMapping.put("fly", "Fly");
        nameMapping.put("breast", "Breast");
        nameMapping.put("back", "Back");
        nameMapping.put("free", "Free");
    }
    static Map<String, String> ageMapping = new HashMap<String, String>();

    static {
        ageMapping.put("8", "8 &amp; Under");
        ageMapping.put("9", "9 - 10");
        ageMapping.put("11", "11 - 12");
        ageMapping.put("13", "13 - 14");
        ageMapping.put("15", "15 - 16");
        ageMapping.put("17", "17 - 18");
        ageMapping.put("18", "Bonus");
        ageMapping.put("19", "Senior");
    }
    static List<Record> objects = new ArrayList<Record>();

    static void addObject(String[] object, String type) {
        if (type.equals("senior")) {
            objects.add(new SeniorRecord(object));
        } else if (type.equals("cba")) {
            objects.add(new JuniorRecord(object));
        } else if (type.equals("junior")) {
            objects.add(new JuniorRecord(object));
        } else if (type.equals("national")) {

            objects.add(new NationalRecord(object, false));
            objects.add(new NationalRecord(object, true));
        } else if (type.equals("trials")) {
            objects.add(new Trials(object));
        }
    }
}
