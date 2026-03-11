codeunit 50055 "PR Notification Mgt. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    // -----------------------------------------------------------------------
    // NotifyApprover
    // -----------------------------------------------------------------------

    [Test]
    procedure NotifyApprover_EmailNotificationsDisabled_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email Notifications off (CreateSetup default) → guard exits immediately
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Approver ID" := 'APPROVER01';
        PRHeader.Modify();

        // Act — must complete without error
        NotificationMgt.NotifyApprover(PRHeader);
    end;

    [Test]
    procedure NotifyApprover_EmptyApproverID_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRSetup: Record "PR Purchase Requisition Setup";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email Notifications on, Approver ID blank → second guard exits early
        PRTestLib.CreateSetup('APPROVER01');
        PRSetup.GetRecordOnce();
        PRSetup."Email Notifications" := true;
        PRSetup.Modify();

        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Approver ID" := '';
        PRHeader.Modify();

        // Act — must complete without error
        NotificationMgt.NotifyApprover(PRHeader);
    end;

    [Test]
    procedure NotifyApprover_UserNotFound_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRSetup: Record "PR Purchase Requisition Setup";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email on, ApproverID has no matching User record → FindUserByName false
        PRTestLib.CreateSetup('APPROVER01');
        PRSetup.GetRecordOnce();
        PRSetup."Email Notifications" := true;
        PRSetup.Modify();

        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Approver ID" := 'GHOST-USER-99';
        PRHeader.Modify();

        // Act — procedure exits without error (no User record found)
        NotificationMgt.NotifyApprover(PRHeader);
    end;

    // -----------------------------------------------------------------------
    // NotifyRequestorApproved
    // -----------------------------------------------------------------------

    [Test]
    procedure NotifyRequestorApproved_EmailNotificationsDisabled_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email Notifications off → guard exits immediately
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Act
        NotificationMgt.NotifyRequestorApproved(PRHeader);
    end;

    [Test]
    procedure NotifyRequestorApproved_EmptyRequestedBy_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRSetup: Record "PR Purchase Requisition Setup";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email on, Requested By blank → second guard exits early
        PRTestLib.CreateSetup('APPROVER01');
        PRSetup.GetRecordOnce();
        PRSetup."Email Notifications" := true;
        PRSetup.Modify();

        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Requested By" := '';   // override the UserId set by OnInsert
        PRHeader.Modify();

        // Act
        NotificationMgt.NotifyRequestorApproved(PRHeader);
    end;

    [Test]
    procedure NotifyRequestorApproved_UserNotFound_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRSetup: Record "PR Purchase Requisition Setup";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email on, Requested By has no matching User record
        PRTestLib.CreateSetup('APPROVER01');
        PRSetup.GetRecordOnce();
        PRSetup."Email Notifications" := true;
        PRSetup.Modify();

        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Requested By" := 'GHOST-USER-99';
        PRHeader.Modify();

        // Act — FindUserByName returns false; procedure exits without error
        NotificationMgt.NotifyRequestorApproved(PRHeader);
    end;

    // -----------------------------------------------------------------------
    // NotifyRequestorRejected
    // -----------------------------------------------------------------------

    [Test]
    procedure NotifyRequestorRejected_EmailNotificationsDisabled_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email Notifications off → guard exits immediately
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Rejection Reason" := 'Budget exceeded';
        PRHeader.Modify();

        // Act
        NotificationMgt.NotifyRequestorRejected(PRHeader);
    end;

    [Test]
    procedure NotifyRequestorRejected_EmptyRequestedBy_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRSetup: Record "PR Purchase Requisition Setup";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email on, Requested By blank → second guard exits early
        PRTestLib.CreateSetup('APPROVER01');
        PRSetup.GetRecordOnce();
        PRSetup."Email Notifications" := true;
        PRSetup.Modify();

        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Requested By" := '';   // override the UserId set by OnInsert
        PRHeader."Rejection Reason" := 'Budget exceeded';
        PRHeader.Modify();

        // Act
        NotificationMgt.NotifyRequestorRejected(PRHeader);
    end;

    [Test]
    procedure NotifyRequestorRejected_UserNotFound_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRSetup: Record "PR Purchase Requisition Setup";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email on, Requested By has no matching User record
        PRTestLib.CreateSetup('APPROVER01');
        PRSetup.GetRecordOnce();
        PRSetup."Email Notifications" := true;
        PRSetup.Modify();

        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Requested By" := 'GHOST-USER-99';
        PRHeader."Rejection Reason" := 'Budget exceeded';
        PRHeader.Modify();

        // Act — FindUserByName returns false; procedure exits without error
        NotificationMgt.NotifyRequestorRejected(PRHeader);
    end;

    // -----------------------------------------------------------------------
    // NotifyConvertedToPO
    // -----------------------------------------------------------------------

    [Test]
    procedure NotifyConvertedToPO_EmailNotificationsDisabled_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email Notifications off → guard exits immediately
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Created PO No." := 'PO-0001';
        PRHeader.Modify();

        // Act
        NotificationMgt.NotifyConvertedToPO(PRHeader);
    end;

    [Test]
    procedure NotifyConvertedToPO_EmptyRequestedBy_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRSetup: Record "PR Purchase Requisition Setup";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email on, Requested By blank → combined condition short-circuits (false AND …)
        PRTestLib.CreateSetup('APPROVER01');
        PRSetup.GetRecordOnce();
        PRSetup."Email Notifications" := true;
        PRSetup.Modify();

        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Requested By" := '';   // override the UserId set by OnInsert
        PRHeader."Created PO No." := 'PO-0001';
        PRHeader.Modify();

        // Act — condition ('' <> '') evaluates to false; no email attempted
        NotificationMgt.NotifyConvertedToPO(PRHeader);
    end;

    [Test]
    procedure NotifyConvertedToPO_UserNotFound_DoesNotError()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRSetup: Record "PR Purchase Requisition Setup";
        NotificationMgt: Codeunit "PR Notification Management";
    begin
        // Arrange — Email on, Requested By has no matching User record
        PRTestLib.CreateSetup('APPROVER01');
        PRSetup.GetRecordOnce();
        PRSetup."Email Notifications" := true;
        PRSetup.Modify();

        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Requested By" := 'GHOST-USER-99';
        PRHeader."Created PO No." := 'PO-0001';
        PRHeader.Modify();

        // Act — FindUserByName returns false; combined condition false; no email attempted
        NotificationMgt.NotifyConvertedToPO(PRHeader);
    end;

    // -----------------------------------------------------------------------
    // Fixtures
    // -----------------------------------------------------------------------
    var
        PRTestLib: Codeunit "PR Test Library";
}
