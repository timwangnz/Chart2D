/*****************************************************************************
 *   Copyright 2005 Tim A Wang
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 ****************************************************************************/

package com.iswim.model;


import java.io.BufferedReader;
import java.io.FileReader;

public class Standards {
    String name;
    String standardBody;
    String gender;
    String ageGroup;
    String course;
    String distance;
    String stroke;
    long time;

    public static String getStandard(String age, Long time, String gender) {
        return "A";
    }

    public void load(String fileName) {
        try {
            BufferedReader in = new BufferedReader(new FileReader(fileName));
            String[] header = null;

            while (true) {
                String ln = in.readLine();

                if (ln == null) {
                    break;
                }

                if (ln.startsWith("Distance")) {
                    header = ln.split(",");

                    continue;
                }

                String[] stds = ln.split(",");

                for (int i = 0; i < (header.length - 5); i++) {
                    Standards standards = new Standards();
                    standards.setAgeGroup(stds[4].trim());
                    standards.setDistance(stds[0].trim());
                    standards.setStroke(stds[1].trim());
                    standards.setCourse(stds[2].trim());
                    standards.setGender(stds[3].trim());
                    //standards.setTime(Meet.stringToTime(stds[i + 5]));
                    standards.setName(header[i + 5].trim());
                   // standards.update();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setStandardBody(String standardBody) {
        this.standardBody = standardBody;
    }

    public String getStandardBody() {
        return standardBody;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getGender() {
        return gender;
    }

    public void setAgeGroup(String ageGroup) {
        this.ageGroup = ageGroup;
    }

    public String getAgeGroup() {
        return ageGroup;
    }

    public void setCourse(String course) {
        this.course = course;
    }

    public String getCourse() {
        return course;
    }

    public void setDistance(String distance) {
        this.distance = distance;
    }

    public String getDistance() {
        return distance;
    }

    public void setStroke(String stroke) {
        this.stroke = stroke;
    }

    public String getStroke() {
        return stroke;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public long getTime() {
        return time;
    }
}
