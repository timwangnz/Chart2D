Parse.Cloud.afterSave("org_sixstreams_user_Profile", function(request, response)
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
                      //if user is created from an invitation, update its status
                      var invitationId = request.object.get("invitationId");
                      
                      var appName = request.object.get('appName');
                      var appEmail = request.object.get('appEmail');
                      var message = request.object.get('message') ? request.object.get('message') : "Thanks your for signup " + appName + "!";
                      
                      if (invitationId)
                      {
                      var query = new Parse.Query("org_sixstreams_user_Invitation");
                      query.get(invitationId, {
                                success: function(object) {
                                console.log("Claim invitation " + invitationId);
                                object.set("status", "claimed");
                                object.save();
                                },
                                
                                error: function(object, error) {
                                // error is an instance of Parse.Error.
                                }
                                });
                      }
                      var Mailgun = require('mailgun');
                      Mailgun.initialize('lunchbox.mailgun.org', 'key-9z7hykf-ch6qqjxxvz7iqvn5s6i5fms2');
                      Mailgun.sendEmail({
                                        to: email,
                                        from: appEmail,
                                        subject: "Welcome to " + appName,
                                        text: message,
                                        html: "<html><body><div>" + message + "<div></body></html>"
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


Parse.Cloud.afterSave("org_sixstreams_user_Invitation", function(request, response)
                      {
                      var updatedAt = request.object.get('isUpdate');
                      
                      if (updatedAt)
                      {
                      return;
                      }
                      
                      var email = request.object.get('email');
                      var appName = request.object.get('appName');
                      var domain = request.object.get('domain');
                      var invitationId = request.object.id;
                      var user = request.object.get('invitedBy');
                      if (!email)
                      {
                      return;
                      }
                      var currentUser = Parse.User.current();
                      var Mailgun = require('mailgun');

                      Mailgun.initialize('lunchbox.mailgun.org', 'key-9z7hykf-ch6qqjxxvz7iqvn5s6i5fms2');
                      var msg = user +  " would like to invite you to join network of " + domain + " at " + appName
                                        + ". If you have not installed " + appName + " on your device, please do so http://itunes.com/apps/mypacswim"
                                        + ". After you installed the app, please open this email and click the link below from your mobile device, and follow the instructions to sign in to " + appName
                                        + appName + "://user/invitation?id=" + invitationId;

                      Mailgun.sendEmail({
                                        to: email,
                                        from: currentUser.getEmail(),
                                        subject: "You are Invited to " + appName,
                                        text: msg,
                                        html:  "<html><body><div>" + user +  " would like to invite you to join network of " + domain + " at " + appName
                                        + ". If you have not installed " + appName + " on your device, please do so http://itunes.com/apps/mypacswim"
                                        + ". After you installed the app, please open this email and click the link below from your mobile device, and follow the instructions to sign in to " + appName
                                        + "<p/> <a href='" + appName + "://user/invitation?id=" + invitationId + "''>Accept</a><div></body></html>"
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

Parse.Cloud.afterDelete("org_sixstreams_user_Profile", function(request)
                        {
                        var email = request.object.get('email');
                        query = new Parse.Query(Parse.User);
                        
                        query.equalTo("email", email);
                        
                        console.log("Deleting user " + email);
                        
                        query.find({
                                   success: function(users) {
                                   Parse.Cloud.useMasterKey();
                                   for (var i = 0; i < users.length; i++) {
                                   
                                   users[i].destroy({success: function (user) {
                                                    console.log("User deleted");
                                                    },
                                                    error: function (user, error) {
                                                    console.log(error.toJSON());
                                                    }
                                                    });
                                   }
                                   },
                                   error: function(error) {
                                   console.error("Error finding related user " + error.toJSON());
                                   }
                                   });
                        }
                        );

function logActivity(object, type, action, subject)
{
    var activityClass = Parse.Object.extend("org_sixstreams_social_Activity");
    var activity = new activityClass();
    activity.set("user", object.get("user"));
    activity.set("ss_author", object.get("ss_author"));
    activity.set("action", action);
    activity.set("type", type);
    
    activity.set("object", object);
    if(subject)
    {
        activity.set("subject", subject);
    }
    
    activity.save(null, {
                  success: function (activity) {
                  
                  console.log("Save activity on " + action);
                  },
                  error: function (error) {
                  
                  console.log("Save failed " + error.toJSON());
                  }
                  });
}

function updateObject(objectType, id, attr, value)
{
    var objectType = objectType.replace(/\./g, "_");
    query = new Parse.Query(objectType);
    query.equalTo("objectId", id);
    //add
    console.error("Set attribute " + attr + " = " + value + " for " + id + " of type " + objectType);
    query.each(function(object) {
               object.set(attr, value);
               return object.save();
               }).then(
                       function()
                       {
                       },
                       function(error)
                       {
                       console.error("Uh oh, failed to update followers.");
                       }
                       );
}

function updateProfile(id, attr, value)
{
    updateObject("org_sixstreams_user_Profile", id, attr, value);
}

Parse.Cloud.afterSave("org_sixstreams_file_File", function(request)
                      {
                      var fileId = request.object.id;
                      var objectId = request.object.get("relatedId");
                      var objectType  = request.object.get("relatedType");
                      var type  = request.object.get("type");
                      if(type == "icon")
                      {
                        updateObject(objectType, objectId, "icon", fileId);
                      }
                      });

Parse.Cloud.afterSave("org_sixstreams_jobs_Job", function(request)
                      {
                      
                      if (request.object.get("published"))
                      {
                        logActivity(request.object, request.object.get('isUpdate') ? "updated" : "created", "Job", request.object.get("jobType"));
                      }
                      });

Parse.Cloud.afterSave("org_sixstreams_jobs_Resume", function(request)
                      {                     
                      var authorId = request.object.get("ss_author");
                      updateProfile(authorId, "resume", "Y");
                      
                      });

Parse.Cloud.afterSave("org_sixstreams_social_Follow", function(request)
                      {
                      var objectType = request.object.get("contextType");
                      var objectId = request.object.get("follow");
                      query = new Parse.Query(objectType);
                      query.equalTo("objectId", objectId);
                      //add
                      query.each(function(object) {
                                 var numberOfFollowers = object.get("followers");
                                 if(!numberOfFollowers)
                                 {
                                 numberOfFollowers = 0;
                                 }
                                 object.set("followers", numberOfFollowers + 1);
                                 return object.save();
                                 }).then(function() {
                                         
                                         
                                         }, function(error) {
                                         
                                         console.error("Uh oh, failed to update followers.");
                                         });
                      
                      logActivity(request.object, "create", "follow");
                      }
                      );

Parse.Cloud.afterSave("org_sixstreams_social_Comment", function(request)
                      {
                      var commentOnType = request.object.get("contextType");
                      var commentOnId = request.object.get("commentedOn");
                      var userRating = request.object.get("rating");
                      query = new Parse.Query(commentOnType);
                      query.equalTo("objectId", commentOnId);
                      console.log("comment on " + commentOnId + " " + commentOnType + " "+ userRating);
                      query.each(function(object) {
                                 if(userRating)
                                 {
                                 var numberOfRatings = object.get("ratings");
                                 if(!numberOfRatings)
                                 {
                                 numberOfRatings = 0;
                                 }
                                 
                                 var rating = object.get("rating");
                                 
                                 if(!rating)
                                 {
                                 rating = 0;
                                 }
                                 var newRating = (rating * numberOfRatings + userRating) / (numberOfRatings + 1);
                                 object.set("ratings", numberOfRatings + 1);
                                 object.set("rating", newRating);
                                 console.log("Updated rating for: " + object.id + " " + newRating);
                                 
                                 }
                                 var numberOfComments = object.get("comments");
                                 object.set("comments", numberOfComments ? (numberOfComments + 1) : 1);
                                 return object.save();
                                 }).then(function() {
                                         // Set the job's success status
                                         console.log("Update commentOnId completed successfully.");
                                         }, function(error) {
                                         // Set the job's error status
                                         console.error("Uh oh, failed to update commentOnId.");
                                         });
                      
                      logActivity(request.object, "create", "comment");
                      }
                      );

Parse.Cloud.afterSave("org_sixstreams_meetup_MeetUp", function(request)
                      {
                      var updatedAt = request.object.get('isUpdate');
                      
                      if (!updatedAt)
                      {
                          logActivity(request.object, "create", "Event");
                          return;
                      }
                      /*
                      //when a event is updated, we will update all the invitations
                      query = new Parse.Query("org_sixstreams_meetup_Invite");
                      query.equalTo("meetingId", request.object.id);
                      event = request.object;
                      
                      console.log("Updated " + event.id);
                      
                      query.each(function(invite) {
                                 //we should send notifications here
                                 invite.set("title", event.get("title"));
                                 invite.set("address", event.get("address"));
                                 invite.set("dateFrom", event.get("dateFrom"));
                                 console.log("Updated invite: " + invite.id);
                                 return invite.save(null, {silent:true}
                                  );
                                 }).then(function() {
                                         // Set the job's success status
                                         console.log("Update invites completed successfully.");
                                         }, function(error) {
                                         // Set the job's error status
                                         console.error("Uh oh, failed to update invites.");
                                         });
                      */
                      }
                      );

Parse.Cloud.afterDelete("org_sixstreams_meetup_MeetUp", function(request)
                        {
                        query = new Parse.Query("org_sixstreams_meetup_Invite");
                        query.equalTo("meetingId", request.object.id);
                        query.find({
                                   success: function(invitations) {
                                   Parse.Object.destroyAll(invitations, {
                                                           success: function() {},
                                                           error: function(error) {
                                                           console.error("Error deleting related invitations " + error.code + ": " + error.message);
                                                           }
                                                           });
                                   },
                                   error: function(error) {
                                   console.error("Error finding related invitations " + error.code + ": " + error.message);
                                   }
                                   });
                        }
                        );

Parse.Cloud.afterSave("org_sixstreams_meetup_Invite", function(request)
                      {
                        
                        var updatedAt = request.object.get('isUpdate');
                        if (updatedAt)
                        {
                             logActivity(request.object, "create", "Event");
                             return;
                        }

                        var meetId = request.object.get("meetingId");
                        query = new Parse.Query("org_sixstreams_meetup_MeetUp");
                        query.get(meetId,
                                  {
                                  success: function(meeting)
                                    {
                                      var count = meeting.get("attendees");
                                      meeting.set("attendees", count + 1);
                                      console.log("Increased count by 1 " + count);
                                      meeting.save(null,
                                                          {
                                                              silent: true,
                                                              success: function(meeting) {
                                               
                                                              },
                                                              error: function(meeting, error) {
                                               
                                                              }
                                                          }
                                               );
                                  
                                  },
                                  error: function(object, error){
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
                                  console.log("Decreased count by 1 " + count);
                                  meeting.save(null,
                                               {
                                               silent: true,
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
