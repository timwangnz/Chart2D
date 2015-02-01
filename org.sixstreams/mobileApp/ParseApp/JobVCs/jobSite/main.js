Parse.Cloud.afterSave("org_sixstreams_user_Profile", function(request)
                      {
                      var updatedAt = request.object.get('isUpdate');
                      
                      if (updatedAt)
                      {
                      return;
                      }
                      
                      var email = request.object.get('email');
                      if (!email)
                      {
                      return;
                      }
                      var appName = request.object.get('appName');
                      var welcomeMsg = request.object.get('welcome') ? request.object.get('welcome') : "Thanks you for signup " + appName;
                      var Mailgun = require('mailgun');
                      Mailgun.initialize('lunchbox.mailgun.org', 'key-9z7hykf-ch6qqjxxvz7iqvn5s6i5fms2');
                      Mailgun.sendEmail({
                                        to: email,
                                        from: "registration@lunchbox.mailgun.org",
                                        subject: "Welcome to " + appName + "!",
                                        text:
                                        }, {
                                        success: function(httpResponse) {
                                        console.log(httpResponse);
                                        response.success("Email sent!");
                                        },
                                        error: function(httpResponse) {
                                        console.error(httpResponse);
                                        response.error("Uh oh, something went wrong");
                                        }
                                        });
                      }
                      );

Parse.Cloud.afterSave("org_sixstreams_user_Invitation", function(request)
                      {
                      var updatedAt = request.object.get('isUpdate');
                      
                      if (updatedAt)
                      {
                      return;
                      }
                      
                      var email = request.object.get('email');
                      var appName = request.object.get('appName');
                      var domain = request.object.get('domain');
                      var user = request.object.get('invitedBy');
                      if (!email)
                      {
                      return;
                      }
                      
                      var Mailgun = require('mailgun');
                      Mailgun.initialize('lunchbox.mailgun.org', 'key-9z7hykf-ch6qqjxxvz7iqvn5s6i5fms2');
                      Mailgun.sendEmail({
                                        to: email,
                                        from: "registration@lunchbox.mailgun.org",
                                        subject: "You are Invited!!!",
                                        text:  user +  " would like to invite you to join " + appName + " at " + domain
                                                + ", Please click the link below, and follow the instructions to sign in to " + appName
                                        }, {
                                        success: function(httpResponse) {
                                        console.log(httpResponse);
                                        response.success("Email sent!");
                                        },
                                        error: function(httpResponse) {
                                        console.error(httpResponse);
                                        response.error("Uh oh, something went wrong");
                                        }
                                        });
                      }
                      );


Parse.Cloud.afterSave("org_sixstreams_meetup_Invite", function(request)
                      {
                        var meetId = request.object.get("meetingId");
                        query = new Parse.Query("org_sixstreams_meetup_MeetUp");
                        query.get(meetId,
                            {
                                success: function(meeting)
                                {
                                    var count = meeting.get("attendees");
                                    meeting.set("attendees", count + 1);
                                    meeting.save(null, {
                                             success: function(meeting) {
                                             
                                             },
                                             error: function(meeting, error) {
                                             }
                                        }
                                    );
                                },
                                error: function(object, error) {
                                
                                }
                            }
                          );
                      }
                );

Parse.Cloud.afterDelete("org_sixstreams_meetup_Invite", function(request)
                        {
                            var meetId = request.object.get("meetingId");
                            query = new Parse.Query("org_sixstreams_meetup_MeetUp");
                            query.get(meetId,
                                {
                                  success: function(meeting)
                                  {
                                      var count = meeting.get("attendees");
                                      if (count > 0)
                                      {
                                        meeting.set("attendees", count - 1);
                                        meeting.save(null,
                                           {
                                             success: function(meeting) {
                                               
                                              },
                                            error: function(meeting, error) {
                                            
                                            }
                                           }
                                        );
                                      }
                                  },
                                  error: function(object, error){
                                  }
                              }
                             );
                        }
                        );
