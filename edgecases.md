TODO: persist these edgecases in the regression suite, ensure we handle.

---- 
here is one where status=resolved, even though resolved_at was never marked...  

    ➜  lurk_incidents git:(master) ✗ python -m json.tool /tmp/**/*w0b0y82g23fy.json
    {
        "backfilled": true,
        "components": [],
        "created_at": "2016-08-30T12:00:00.000-07:00",
        "id": "w0b0y82g23fy",
        "impact": "none",
        "impact_override": null,
        "incident_updates": [
            {
                "affected_components": [
                    {
                        "name": "No components were affected by this update."
                    }
                ],
                "body": "On August 30th, we identified delays in email notifications due to a service disruption with one of our mail providers. At that time, we routed all mail through another provider, resulting in emails being successfully delivered.\r\n\r\nWe understand these scenarios cause a lot of frustration and you rely on your notifications to be delivered in a timely manner. With this in mind, we'll continue to improve this in the future.\r\n\r\nWe're looking into how we can automate this failover in the future so when one of our mail providers is delayed, we route all mail through another mail provider.",
                "created_at": "2016-09-07T11:01:35.777-07:00",
                "display_at": "2016-08-30T12:00:00.000-07:00",
                "id": "sj2bxd59t9fs",
                "incident_id": "w0b0y82g23fy",
                "status": "investigating",
                "twitter_updated_at": null,
                "updated_at": "2016-09-07T11:01:35.777-07:00",
                "wants_twitter_update": false
            }
        ],
        "monitoring_at": null,
        "name": "Email Delivery Delays",
        "page_id": "y2j98763l56x",
        "postmortem_body": null,
        "postmortem_body_last_updated_at": null,
        "postmortem_ignored": false,
        "postmortem_notified_subscribers": false,
        "postmortem_notified_twitter": false,
        "postmortem_published_at": null,
        "resolved_at": null,
        "scheduled_auto_completed": false,
        "scheduled_auto_in_progress": false,
        "scheduled_for": null,
        "scheduled_remind_prior": false,
        "scheduled_reminded_at": null,
        "scheduled_until": null,
        "shortlink": "http://mstspg.co/Q3V",
        "status": "resolved",
        "updated_at": "2016-09-07T11:01:36.719-07:00"
    }
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
