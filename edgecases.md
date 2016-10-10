TODO: persist these edgecases in the regression suite, ensure we handle.

---- 

# metastatuspage

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


okee here's an oddity :P TODO how could it have a negative duration? their error, or mine? how to handle - treat as 0, or treat as borked and throw away?

    Incident(uuid: s63kkmc97nxw, status: resolved, started_at: 2016-04-16T12:04:06-07:00, ended_at: 2016-04-16T12:04:00-07:00, duration_seconds: -6, ...)

and here are some with really low durations. I want to look at them together and decide, should I ignore these when doing charts?

    Incident(uuid: sdg7b972cx37, status: resolved, started_at: 2013-06-07T10:39:38-07:00, ended_at: 2013-06-07T10:39:38-07:00, duration_seconds: 0, ...)
    Incident(uuid: 6q8fqxh54j3j, status: resolved, started_at: 2013-07-10T08:26:27-07:00, ended_at: 2013-07-10T08:26:28-07:00, duration_seconds: 1, ...)
                                                                                
    Incident(uuid: vq35wc4kb9k4, status: resolved, started_at: 2013-10-16T07:10:23-07:00, ended_at: 2013-10-16T07:10:25-07:00, duration_seconds: 2, ...)
    Incident(uuid: fbg1hr31lty8, status: resolved, started_at: 2013-10-01T21:45:00-07:00, ended_at: 2013-10-01T21:45:02-07:00, duration_seconds: 1, ...)
