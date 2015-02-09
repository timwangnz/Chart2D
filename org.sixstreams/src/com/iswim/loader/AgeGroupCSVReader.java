package com.iswim.loader;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class AgeGroupCSVReader {

    public static void main(String[] args) {
        doFile("/Users/anpwang/Dropbox/Private/swimmingdata/age group standard time.csv");
    }

    public static void doFile(String urlString) {
        try {
            URL url = getFileURL(urlString);
            InputStream steam = url.openStream();
            process(steam);
            System.err.println(stringWithStandard("Pacific Age Group", "A B Times"));
            steam.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static URL getFileURL(String location) throws Exception {
        return new URL("file", "", -1, location);
    }

    static StringBuffer stringWithStandard(String name, String desc) {

        StringBuffer standardString = new StringBuffer("<standard name=\"" + name + "\" desc=\"" + desc + "\" ><events>");

        String[] strokes = new String[]{
            "Fly", "Free", "Breast", "Back", "IM"
        };
        String[] courses = new String[]{
            "SCY", "LCM"
        };
        String[] genders = new String[]{
            "b", "g"
        };

        for (String aStroke : strokes) {
            for (String aCourse : courses) {
                for (String aGender : genders) {
                    standardString.append(stringWithStandardItems(aStroke, aCourse, aGender));
                }
            }
        }
        return standardString.append("</events></standard>");
    }

    static class StandardTime {

        public StandardTime(String name, String time) {
            this.name = name;
            this.time = time;
        }

        String name;
        String time;
    }

    public static String formatTime(long time) {
        if (time <= 0) {
            return "";
        }

        long minutes = time / 60000;
        long seconds = (time - minutes * 60000) / 1000;
        long subsecs = (time - seconds * 1000 - minutes * 60000) / 10;

        return String.format("%02d:%02d.%02d", minutes, seconds, subsecs);

    }

    public static long getTime(String newTime) {
        if (newTime == null || newTime.isEmpty()) {
            return 0;
        }
        if (!newTime.contains(":")) {
            newTime = "0:" + newTime;
        }
        String[] timeComponents = newTime.split(":");
        String[] secondsComponents = timeComponents[1].split("\\.");
        long hundreds = Long.valueOf(secondsComponents[1]);
        long seconds = Long.valueOf(secondsComponents[0]);
        long minutes = Long.valueOf(timeComponents[0]);
        return minutes * 60000 + seconds * 1000 + hundreds * 10;
    }

    static StringBuffer stringWithStandardItems(String inStroke, String inCourse, String inGender) {
        StringBuffer standardString = new StringBuffer("<event><stroke>" + inStroke + "</stroke><gender>" + inGender + "</gender><course>" + inCourse + "</course><items>\r\n");

        for (Record record : items) {
            if (record.stroke.equals(inStroke) && record.course.equals(inCourse) && record.gender.equals(inGender)) {
                StringBuffer timeString = new StringBuffer();
                for (Object time : record) {
                    StandardTime st = (StandardTime) time;
                    timeString.append("<time><name>" + st.name + "</name><value>" + getTime(st.time) + "</value></time>");
                }

                standardString.append("<item><age>" + record.age + "</age><distance>" + record.distance + "</distance><times>" + timeString + "</times></item>\r\n");
            }
        }

        standardString.append("</items></event>\r\n");

		// NSLog(@"%@", standardString);
        return standardString;
    }

    static List<Record> items = new ArrayList<Record>();

    public static void process(InputStream stream) throws Exception {

        BufferedReader br = new BufferedReader(new InputStreamReader(stream));

        while (true) {
            String line = br.readLine();
            if (line == null) {
                break;
            }
            line = line.trim();

            String[] elements = line.split(",");
            String[] ages = new String[]{
                "UN08", "UN10", "1112", "1314", "1516", "1718"
            };

            String dist = elements[0];
            String stroke = elements[1];
            String course = elements[2];
            String gender = elements[3];
            int i = 0;
            // String a = elements[i+2];

            for (String age : ages) {
                if (elements[4 + i].trim().length() > 0) {
                    Record record = new Record(age, gender, course, dist, stroke);
                    record.add(new StandardTime("B", elements[4 + i]));
                    record.add(new StandardTime("A", elements[5 + i]));
                    items.add(record);
                }
                i += 2;
                if (4 + i > elements.length - 1) {
                    break;
                }
            }

        }
    }
}
