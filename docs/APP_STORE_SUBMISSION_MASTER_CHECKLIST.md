# 📋 Camlica360 - App Store Submission Master Checklist

## PHASE 1: VALIDATION ERRORS ✅ (If not done yet)

```
[ ] Phone number format fixed: +905551234567
[ ] Contact information filled:
    [ ] First Name: Abidin
    [ ] Last Name: Ocal
    [ ] Email: abidin.ocal@camlica.com.tr
    [ ] Phone: (saved and green)
[ ] Turkish Description (ASCII-safe) saved
[ ] Turkish Keywords saved
[ ] Turkish Promotional Text saved
[ ] Turkish Support/Marketing URLs saved
[ ] NO RED ERROR MESSAGES on metadata
```

---

## PHASE 2: REQUIRED FIELDS FOR REVIEW (DO THIS FIRST!)

### 2.1 Content Rights Information

```
Location: App Information → Content Rights

[ ] Option selected: "I own worldwide rights to all content"
[ ] Saved (green checkmark)
```

### 2.2 Privacy Policy

```
Location: App Privacy → Privacy Policy

[ ] URL entered: https://crm.cmlc.com.tr/privacy-policy
[ ] URL is LIVE and working
[ ] Contains actual privacy policy text
[ ] Saved (green checkmark)
```

### 2.3 Primary Category

```
Location: App Information → Category

[ ] Primary Category: Business
[ ] Secondary Category: Productivity (optional)
[ ] Saved (green checkmark)
```

### 2.4 Age Rating (Content Description)

```
Location: App Information → Age Rating

[ ] Violent Content: Does Not Require This
[ ] Sexual Content: Does Not Require This
[ ] Profanity: Does Not Require This
[ ] Alcohol/Tobacco: Does Not Require This
[ ] Gambling: Does Not Require This
[ ] Unrestricted Web: Does Not Require This
[ ] User Generated Content: Infrequent/Mild
[ ] Medical: Does Not Require This

Final Rating: 4+
[ ] Saved (green checkmark)
```

### 2.5 Privacy Practices (App Privacy Section)

```
Location: App Privacy → Data Collection & Privacy

[ ] Privacy Policy URL: https://crm.cmlc.com.tr/privacy-policy
[ ] Data Collection: Yes
[ ] Data Types Selected:
    [ ] Contact Info (Name, Email, Phone)
    [ ] User ID
    [ ] User-Generated Content
    [ ] Crash Data (optional)
[ ] Data Retention: Until user deletes account
[ ] Data Sharing: No (or Camlica backend only)
[ ] Encryption: Yes (HTTPS, Keychain, OAuth2)
[ ] Contact Info: abidin.ocal@camlica.com.tr
[ ] Saved (green checkmark)
```

### 2.6 Pricing & Availability

```
Location: Pricing and Availability

[ ] Price Tier: Free
[ ] Availability: All countries/regions
[ ] Availability Date: Immediately after approval
[ ] Saved (green checkmark)
```

---

## PHASE 3: BUILD & TESTFLIGHT

### 3.1 Demo Account Setup

```
In your CRM backend:

[ ] Company Code: DEMO created
[ ] Employee ID: 12345 created
[ ] User: Abidin Ocal created
[ ] Password: Demo@123456 set
[ ] All CRM modules accessible
[ ] OTP delivery tested
[ ] Test data populated (orders, leaves, etc.)
```

### 3.2 Build Preparation

```
Xcode Project:

[ ] Version: 1.0
[ ] Build: 1
[ ] iOS Minimum: 15.0
[ ] Bundle ID: com.camlica.camlica360 (or similar)
[ ] Team selected and provisioning profiles updated
[ ] Ad Hoc signing configured for TestFlight
```

### 3.3 Build Creation & TestFlight Upload

```
[ ] Archive created (Clean build)
[ ] IPA signed correctly
[ ] Upload to TestFlight via:
    [ ] Xcode directly, OR
    [ ] Transporter app
[ ] Wait for processing (5-10 minutes)
[ ] Build shows in TestFlight
[ ] Test on physical device before submitting
```

### 3.4 TestFlight Internal Testing

```
Before submission, test:

[ ] Login with demo credentials
    [ ] Company Code: DEMO
    [ ] Employee ID: 12345
    [ ] Password: Demo@123456
[ ] OTP verification works
[ ] All tabs/menus accessible
[ ] HR/Leave features work
[ ] Vehicle orders accessible
[ ] Inventory working
[ ] Screenshots work
[ ] Turkish language works
[ ] Logout works
[ ] No crashes during navigation
```

---

## PHASE 4: APP STORE METADATA COMPLETION

### 4.1 Basic Information

```
App Information:

[ ] App Name: Camlica360
[ ] Subtitle (EN): Enterprise CRM on Mobile
[ ] Subtitle (TR): Mobil İşletme Yönetimi Sistemi
[ ] Saved
```

### 4.2 Promotional Text

```
English Version:
[ ] Filled with promotional text
[ ] Under 160 characters
[ ] Saved

Turkish Version:
[ ] Filled with Turkish promotional text (ASCII-safe)
[ ] Under 160 characters
[ ] Saved
```

### 4.3 Description

```
English:
[ ] Full description with all features
[ ] Includes system requirements
[ ] Includes key benefits
[ ] Saved

Turkish:
[ ] Full Turkish description (ASCII-safe)
[ ] All features described
[ ] Saved
```

### 4.4 Keywords

```
English:
[ ] 30+ keywords filled
[ ] Separated by commas
[ ] Saved

Turkish:
[ ] 30+ Turkish keywords (ASCII-safe)
[ ] Separated by commas
[ ] Saved
```

### 4.5 Support Information

```
[ ] Support URL: https://crm.cmlc.com.tr/support
[ ] Marketing URL: https://crm.cmlc.com.tr
[ ] Copyright: © 2025 Camlica360. All rights reserved.
[ ] Contact Information:
    [ ] First Name: Abidin
    [ ] Last Name: Ocal
    [ ] Email: abidin.ocal@camlica.com.tr
    [ ] Phone: +905551234567 (correct format)
[ ] All saved
```

---

## PHASE 5: LOCALIZATION (If applicable)

```
English Localization:
[ ] All metadata complete
[ ] Screenshots in English
[ ] Saved

Turkish Localization:
[ ] All metadata complete (ASCII-safe)
[ ] Screenshots in Turkish
[ ] Saved
```

---

## PHASE 6: SCREENSHOTS & MEDIA

### 6.1 Screenshots Preparation

```
Device: iPhone
Resolution: 1280x720 (standard)
Count: Minimum 5 (recommended 3-5 per language)

Screenshots to include:
[ ] Login screen
[ ] OTP verification
[ ] Dashboard/Home
[ ] HR/Leave management
[ ] Vehicle orders (or key feature)
[ ] Settings/Profile
[ ] Turkish version of key screens

Format: PNG
[ ] All screenshots named clearly
[ ] Optimized for file size
```

### 6.2 App Preview Video (Optional but recommended)

```
[ ] 15-30 second video showing:
    [ ] App launch
    [ ] Login flow
    [ ] Key features
    [ ] Navigation
[ ] MP4 format
[ ] Saved with subtitles in English/Turkish
```

### 6.3 App Icon & Images

```
[ ] App Icon: 1024x1024 (required)
[ ] App Preview Images (optional)
[ ] All images follow Apple guidelines
```

---

## PHASE 7: RATINGS & REVIEW INFORMATION

### 7.1 Content Rating

```
[ ] Content Rights: "I own worldwide rights" ✓
[ ] Age Rating: 4+
[ ] All content descriptions: Completed
[ ] Saved
```

### 7.2 Beta App Review Information

```
Location: TestFlight → Test Information

[ ] "Sign-in required" checkbox: CHECKED ✓
[ ] Username: DEMO_12345
[ ] Password: Demo@123456

NOTES section (copy-paste from APP_STORE_FIXED_METADATA.txt):

[ ] App overview description
[ ] Demo account credentials clearly stated
[ ] Feature list
[ ] Testing instructions (5 steps)
[ ] Key features highlighted
[ ] Security information
[ ] System requirements
[ ] Support contact information
[ ] All important info included
[ ] Saved
```

---

## PHASE 8: PRE-SUBMISSION VERIFICATION

### 8.1 Final Metadata Check

```
App Information tab:
[ ] Name: Camlica360
[ ] Bundle ID: Correct
[ ] SKU: Set
[ ] Primary Category: Business
[ ] Secondary Category: Productivity
[ ] Content Rating: 4+
[ ] Version: 1.0
[ ] Build: 1

All metadata:
[ ] English complete
[ ] Turkish complete
[ ] No validation errors (all green)
[ ] All required fields filled
[ ] No red warnings
```

### 8.2 Build Verification

```
[ ] Build 1.0 (1) in TestFlight
[ ] Ready for Distribution
[ ] No pending processing
[ ] Can see in app list
```

### 8.3 Privacy & Compliance

```
[ ] Privacy Policy URL working
[ ] Privacy data filled completely
[ ] GDPR compliant (if applicable)
[ ] Contact info accurate
[ ] Support information valid
```

### 8.4 Content Check

```
[ ] No objectionable content
[ ] No private API usage
[ ] No test data visible
[ ] Demo credentials appropriate
[ ] Screenshots appropriate
```

---

## PHASE 9: SUBMISSION

### 9.1 Pre-Submission Review

```
In App Store Connect:

[ ] "Ready to Submit" button visible (NOT grayed out)
[ ] No missing fields warnings
[ ] All sections complete (green checkmarks)
[ ] Build selected: Correct build (1.0-1)
[ ] TestFlight build has been tested
```

### 9.2 Submission Process

```
1. Go to: App Information → General
2. Scroll to: Version Release Information
3. Select: Automatic Release (recommended)
   OR Manual Release (you choose when)
4. Click: Submit for Review button

[ ] Submission dialog appears
[ ] Review type: "New App Release"
[ ] Submissions type: "Default"
[ ] Click: "Submit" button
[ ] Confirmation appears
```

### 9.3 After Submission

```
[ ] Receive email confirmation
[ ] Status shows: "Pending Review"
[ ] Can see in App Store Connect:
    → Status: Pending Developer Release
    → Build: In Review
[ ] Wait for Apple review (2-24 hours typical)
```

---

## PHASE 10: REVIEW & RESPONSE

### 10.1 During Review

```
[ ] Check email daily for messages
[ ] Check App Store Connect for status
[ ] Be ready to respond to questions within 24 hours
```

### 10.2 If Rejected

```
[ ] Read rejection reason carefully
[ ] Note the specific issues
[ ] Fix the issues
[ ] Prepare updated build
[ ] Resubmit for review

Common reasons:
- Demo account not working
- Missing privacy policy
- Unclear functionality
- Guidelines violations
```

### 10.3 If Approved

```
[ ] Check email confirmation
[ ] App Store Connect shows: "Approved"
[ ] Release option:
    [ ] Automatic (already live)
    [ ] Manual (you choose release date)
[ ] Monitor app in App Store
[ ] Check user reviews
```

---

## CRITICAL TIMELINE

```
Phase 1 (Validation):        5 minutes
Phase 2 (Required fields):   15 minutes
Phase 3 (Build/TestFlight):  30 minutes
Phase 4 (Metadata):          15 minutes
Phase 5 (Localization):      10 minutes
Phase 6 (Screenshots):       20 minutes
Phase 7 (Review Info):       10 minutes
Phase 8 (Verification):      10 minutes
Phase 9 (Submission):        5 minutes
─────────────────────────────────────
TOTAL PREPARATION:          ~120 minutes (2 hours)

Apple Review:               2-24 hours
```

---

## 🎯 NEXT IMMEDIATE ACTION

**PRIORITY ORDER:**

1. **RIGHT NOW** (5 min)
   - [ ] Fix phone number validation error

2. **IMMEDIATELY AFTER** (15 min)
   - [ ] Fill Required Fields for Review:
     - Content Rights
     - Privacy Policy URL
     - Category
     - Age Rating
     - Privacy Practices
     - Pricing

3. **THEN** (next few hours)
   - [ ] Create/test demo account in backend
   - [ ] Prepare build for TestFlight
   - [ ] Take screenshots

4. **BEFORE SUBMISSION** (next day)
   - [ ] Upload build
   - [ ] Fill beta review notes
   - [ ] Final verification

5. **SUBMISSION** (when ready)
   - [ ] Submit for Review

---

**Current Status:** Phase 2 - Fill Required Fields ← YOU ARE HERE
**Blocker:** Phone number & Required fields must be completed FIRST
**Next Steps:** See REQUIRED_FIELDS_FOR_REVIEW.md for detailed instructions
**Document Version:** 1.0
**Last Updated:** October 27, 2025
