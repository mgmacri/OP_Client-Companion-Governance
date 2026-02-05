# Canadian Provincial Health Information Compliance Gates
## Mental Health Client Logging Application - Engineering Requirements

**Document Version:** 3.0  
**Date:** February 4, 2026  
**Classification:** Compliance Engineering Analysis  
**Disclaimer:** This document provides compliance engineering analysis, not legal advice. Consult qualified legal counsel for authoritative interpretation.

---

## Table of Contents

### Phase 0: Privacy-by-Design Foundation
0. [Patient/Vulnerable-Persons-First Safety Foundation](#0-patientvulnerable-persons-first-safety-foundation)
   - 0.1 [Data Promise](#01-data-promise)
   - 0.2 [Data Inventory & Flows](#02-data-inventory--flows)
   - 0.3 [Minimization Plan](#03-minimization-plan)
   - 0.4 [Threat Model (STRIDE + Safety)](#04-threat-model-stride--safety)
   - 0.5 [No-Human-Access Posture](#05-no-human-access-posture)

### Phase 1: Legislative Compliance
1. [Source Inventory & Coverage Assessment](#1-source-inventory--coverage-assessment)
2. [Applicability Summary (Per Province)](#2-applicability-summary-per-province)
3. [Harmonized National Baseline](#3-harmonized-national-baseline)
4. [Compliance Gates by Province](#4-compliance-gates-by-province)
   - 4.16 [G16: Practitioner Credentialing & Verification](#416-g16-practitioner-credentialing--verification) ⭐ NEW
   - 4.17 [G17: Clinical Safety & Emergency Redirects](#417-g17-clinical-safety--emergency-redirects) ⭐ NEW
5. [Engineering & Ops Tickets](#5-engineering--ops-tickets)
6. [BDD Acceptance Criteria](#6-bdd-acceptance-criteria)
7. [Missing Sources & Ambiguities](#7-missing-sources--ambiguities)

---

# PHASE 0: PRIVACY-BY-DESIGN FOUNDATION

> **Critical:** Execute this phase BEFORE proceeding to legislative compliance gates. These outputs establish the safety foundation that protects vulnerable persons and enforces "only patient + practitioner" data use principles.

---

## 0. Patient/Vulnerable-Persons-First Safety Foundation

---

## 0.1 Data Promise

### Our Promise to You: How We Protect Your Mental Health Information

*Plain Language Summary for Patients*

---

#### What We Collect

When you use the Mental Health Companion App, we collect only the information necessary to help you track your mental health and share with your care provider:

| What We Collect | Why We Need It |
|----------------|----------------|
| **Your log entries** (mood, anxiety, triggers, symptoms, sleep, safety notes) | So you can track patterns and share with your practitioner |
| **Your account information** (name, email, phone number) | So you can log in and we can contact you about your account |
| **Your consent records** | To prove you agreed to share your information and when |
| **Which practitioner(s) you choose to share with** | So only the practitioners you select can see your entries |
| **Technical information** (device type, app version, crash data) | To fix bugs and improve the app — this is NOT linked to your health entries |

#### Why We Collect It

We collect your information for ONE purpose: **to help you manage your mental health by allowing you to track your experiences and securely share them with the healthcare providers you choose.**

We do NOT collect information for advertising, selling, or any purpose other than your care.

#### Who Can See Your Information

| Who | What They Can See | Why |
|-----|-------------------|-----|
| **You** | Everything about you | It's your information |
| **Your chosen practitioner(s)** | Only the entries you choose to share with them | To support your care |
| **Our systems (automated)** | Encrypted data for storage and transmission | Technical necessity only |

**No one else.** Not our staff. Not advertisers. Not researchers (unless you specifically consent). Not government (unless required by law with proper legal process).

#### What We NEVER Do

❌ **We NEVER sell your information** — not to advertisers, data brokers, or anyone else  
❌ **We NEVER use your health entries to show you ads** — the app has no advertising  
❌ **We NEVER train AI/machine learning on your personal health entries** — your private thoughts stay private  
❌ **We NEVER share with data brokers** — your information is not a commodity  
❌ **We NEVER allow our staff to browse your entries** — there is no "back door" for curiosity  
❌ **We NEVER share with your employer, insurer, or others** — unless you direct us to and provide explicit consent  

#### How Support Works Without Accessing Your Health Data

If you contact us for help, our support team can:
- ✅ See your account status (active, locked, subscription)
- ✅ See technical information (app version, device type, error codes)
- ✅ Reset your password
- ✅ Help you regain access to your account

Our support team CANNOT:
- ❌ Read your mood entries
- ❌ See what you've shared with practitioners
- ❌ Access your health information

**If a technical problem requires looking at data that might include health information:**
- You will be asked for explicit permission first
- Access is time-limited (maximum 4 hours)
- Two senior staff must approve
- Everything is logged
- You will be notified what was accessed and when

#### Your Rights

- **See it:** You can view all your information anytime in the app
- **Export it:** You can download your data in PDF or digital format
- **Correct it:** You can ask us to fix inaccuracies
- **Delete it:** You can ask us to delete your information (subject to legal retention requirements)
- **Withdraw consent:** You can stop sharing with a practitioner anytime — it takes effect immediately for future sharing
- **Complain:** You can complain to your provincial Privacy Commissioner if we don't meet our promises

#### Implementation-Dependent Promises

*The following promises depend on our technical implementation remaining as designed:*

| Promise | What Must Be True |
|---------|-------------------|
| "Staff cannot read your entries" | Role-based access controls enforced; no admin override for PHI |
| "Encryption protects your data" | AES-256 encryption at rest; TLS 1.2+ in transit; keys in HSM |
| "Only your chosen practitioner sees shared entries" | Patient-practitioner relationship verified before data access |
| "Your data is in Canada" | All servers and backups in Canadian data centers |

We regularly test and audit these systems to ensure these promises remain true.

---

*Questions? Contact our Privacy Officer at privacy@[company].ca*

*Last Updated: February 4, 2026*

---

## 0.2 Data Inventory & Flows

### 0.2.1 Data Element Inventory

| Data Element | Sensitivity | Source | Where Stored | Where Transmitted | Who Accesses | Retention | Deletion Path | Notes |
|-------------|-------------|--------|--------------|-------------------|--------------|-----------|---------------|-------|
| **Mood Log Entries** | HIGH (PHI) | Patient input | Primary DB (encrypted), Encrypted offline queue | Patient device ↔ API ↔ DB; Practitioner portal (if shared) | Patient (own); Practitioner (if consent granted) | 10 years from last service | Patient deletion request → soft delete → hard delete after retention | Core PHI; includes free-text |
| **Anxiety/Trigger Logs** | HIGH (PHI) | Patient input | Primary DB (encrypted), Encrypted offline queue | Same as mood logs | Same as mood logs | 10 years | Same as mood logs | May contain highly sensitive details |
| **Sleep Logs** | MEDIUM-HIGH (PHI) | Patient input | Primary DB (encrypted) | Same as mood logs | Same as mood logs | 10 years | Same as mood logs | Health-related but less sensitive |
| **Safety Notes** | CRITICAL (PHI) | Patient input | Primary DB (encrypted), Flagged for clinical review | Same as mood logs; May trigger practitioner alert | Same as mood logs; Clinical review if flagged | 10 years | Same; special handling for flagged entries | May indicate self-harm risk |
| **CBT Exercise Responses** | HIGH (PHI) | Patient input | Primary DB (encrypted) | Same as mood logs | Same as mood logs | 10 years | Same as mood logs | Therapeutic content |
| **Consent Records** | HIGH (Legal) | Patient action | Primary DB, Audit log (append-only) | API ↔ DB | Patient (view); System (enforcement); Auditors | Duration of relationship + 10 years | Generally not deleted; archived | Immutable; required for legal compliance |
| **Consent Withdrawal Records** | HIGH (Legal) | Patient action | Primary DB, Audit log | API ↔ DB | Same as consent records | Same as consent records | Not deleted | Documents withdrawal date/scope |
| **Practitioner Linkage** | MEDIUM (Identifying) | Patient selection | Primary DB | API ↔ DB | Patient; Practitioner; System | Duration of relationship | Patient removes linkage | Enables sharing relationship |
| **Patient Account Info** | MEDIUM (PII) | Patient registration | Primary DB, Auth system | Registration ↔ API; Auth flows | Patient; Support (limited); System | Account lifetime + 7 years | Account deletion request | Name, email, phone |
| **Practitioner Account Info** | LOW-MEDIUM | Practitioner registration | Primary DB, Auth system | Same as patient | Practitioner; Support; System | Account lifetime + 7 years | Account deletion | Professional info |
| **Authentication Data** | HIGH (Security) | System-generated | Auth system (hashed passwords, MFA secrets) | Auth flows only | System only | Account lifetime | With account deletion | Never stored in plaintext |
| **Session Tokens** | MEDIUM (Security) | System-generated | Session store (Redis/memory) | All authenticated requests | System only | Session duration (30 min idle) | Auto-expiry | Short-lived |
| **Device Identifiers** | LOW-MEDIUM | Device | Device storage, Server logs | App ↔ API | System only | 90 days in logs | Log rotation | For push notifications, fraud detection |
| **IP Addresses** | LOW (Metadata) | Network | Access logs, Audit logs | All requests | System; Security team | 90 days (access logs); 10 years (audit logs where required) | Log rotation / Not deleted for audit | Logged for security |
| **Audit Logs** | HIGH (Legal/Security) | System-generated | Append-only log store | Internal only | Security team; Auditors; Commissioner (on request) | 10 years minimum | Not deleted; archived | Immutable |
| **Error Logs** | LOW-MEDIUM | System-generated | Log aggregation system | Internal only | Engineering (anonymized); On-call | 90 days | Log rotation | PHI redacted before logging |
| **Analytics Events** | LOW | App instrumentation | Analytics platform | App → Analytics | Product team (aggregate only) | 2 years | Platform retention | De-identified; no PHI |
| **Backups** | HIGH (contains PHI) | System-generated | Encrypted backup storage (Canada) | Internal replication | Disaster recovery (automated); Break-glass only | 90 days rolling | Auto-rotation | Same encryption as primary |
| **Exported Data** | HIGH (PHI) | Patient-initiated | Temporary (patient device) | API → Patient device | Patient only | Patient controls | Patient deletes from device | Patient's responsibility after export |
| **Practitioner Notes** (if feature exists) | HIGH (PHI) | Practitioner input | Primary DB (encrypted) | Practitioner portal ↔ API | Practitioner (author); Patient (if shared back) | Per professional regulations (typically 10+ years) | Practitioner/institution policy | Separate from patient entries |

### 0.2.2 Flow Narrative

#### Patient Entry Flow

```
1. ENTRY CREATION
   Patient → Opens app → Selects log type (mood/anxiety/sleep/CBT/safety)
   
2. DATA INPUT
   Patient → Fills form → Data held in local Redux state (encrypted in memory)
   
3. CONSENT GATE
   System → Checks: Has patient consented to collection?
   - If NO: Block submission, prompt consent
   - If YES: Proceed
   
4. LOCAL QUEUE (Offline-First)
   App → Encrypts entry with device key → Stores in IndexedDB queue
   Entry state: "pending"
   
5. SYNC CHECK
   Saga → Monitors connectivity
   - If OFFLINE: Entry remains in queue, retry with backoff
   - If ONLINE: Proceed to transmission
   
6. TRANSMISSION
   App → Decrypts from queue → Re-encrypts with TLS → Sends to API
   API → Validates request → Validates consent → Applies server timestamp (UTC)
   
7. STORAGE
   API → Encrypts with AES-256 → Writes to primary DB
   API → Creates audit log entry (who, what, when, action)
   
8. CONFIRMATION
   API → Returns success with queue_id
   App → Marks queue item as "synced" → Removes from local queue
   
9. BACKUP
   System → Encrypted replication to backup storage (automated, no human access)
```

#### Patient-to-Practitioner Sharing Flow

```
1. SHARING SETUP
   Patient → Opens sharing settings → Selects practitioner
   
2. EXPRESS CONSENT
   System → Displays consent prompt: "Allow [Practitioner Name] to see [selected log types]?"
   Patient → Confirms (express consent captured)
   
3. CONSENT RECORD
   System → Creates consent record: patient_id, practitioner_id, scope, timestamp_utc, consent_version
   System → Stores in DB and audit log (immutable)
   
4. PRACTITIONER ACCESS
   Practitioner → Logs into portal → MFA challenge → Session created
   
5. PATIENT LIST
   Portal → Queries: "Which patients have active consent for this practitioner?"
   System → Returns only patients with valid, non-withdrawn consent
   
6. ENTRY VIEW
   Practitioner → Selects patient → Requests entries
   System → Checks: Is consent active? Is scope valid for requested entries?
   - If NO: Deny access, log denial
   - If YES: Return entries within consent scope
   
7. AUDIT
   System → Logs: practitioner_id, patient_id, entries_accessed, timestamp_utc
```

#### Data Export Flow

```
1. REQUEST
   Patient → Requests data export → Selects format (JSON/PDF)
   
2. COMPILATION
   System → Gathers all patient data: entries, consent records, disclosure log
   
3. GENERATION
   System → Generates export file → Does NOT store copy on server
   
4. DELIVERY
   System → Streams to patient device via TLS
   Patient → Saves locally
   
5. AUDIT
   System → Logs: export_requested, patient_id, timestamp_utc
```

#### Deletion Flow

```
1. REQUEST
   Patient → Requests account deletion
   
2. VERIFICATION
   System → Confirms identity → Documents request
   
3. RETENTION CHECK
   System → Checks: Are there legal holds or retention requirements?
   - If YES: Document exception, notify patient, delay deletion
   - If NO: Proceed
   
4. SOFT DELETE
   System → Marks records as "deleted" → Removes from active queries
   
5. HARD DELETE (after retention period)
   System → Cryptographically erases data → Removes from backups as they rotate
   
6. CONFIRMATION
   System → Notifies patient of completion
   System → Audit log entry (deletion event is retained for accountability)
```

---

## 0.3 Minimization Plan

### 0.3.1 Minimization Principles Applied

| Principle | Application |
|-----------|-------------|
| **Collect only what's necessary** | Every field must justify its necessity for care |
| **Prefer structured over free-text** | Reduces inadvertent sensitive disclosure |
| **Separate PHI from telemetry** | Analytics cannot access identifiable health data |
| **Time-limit metadata retention** | IP addresses, device IDs expire after 90 days |
| **No nice-to-have PHI** | Remove fields that are "interesting" but not essential |

### 0.3.2 Field-by-Field Minimization Analysis

| Field/Element | Currently Collected? | Strictly Required? | Minimization Action | UX Impact | Safety Impact | Effort |
|--------------|---------------------|-------------------|---------------------|-----------|---------------|--------|
| **Full Name** | Yes | Yes (account identity) | None needed | N/A | N/A | N/A |
| **Email** | Yes | Yes (account recovery, notifications) | None needed | N/A | N/A | N/A |
| **Phone Number** | Yes | Maybe (MFA, critical alerts) | Make optional OR use only for MFA | Minor (users prefer options) | Low (alternative recovery exists) | Low |
| **Date of Birth** | Yes | Partial (age verification for minors) | Collect year only OR age range | Minor | Low | Low |
| **Postal Code** | Maybe | No (unless location-based services) | Remove OR collect first 3 chars only | None | None | Low |
| **Health Card Number** | No | No (not needed for app function) | Do NOT collect | N/A | Reduces breach risk | N/A |
| **Mood Score** | Yes | Yes (core feature) | None needed | N/A | N/A | N/A |
| **Mood Free-Text Notes** | Yes | Partial | Replace with structured prompts + optional free-text (default hidden) | Moderate (less expressive) | Low (structured captures key info) | Medium |
| **Anxiety Triggers (Free-Text)** | Yes | Partial | Offer common triggers as checkboxes; free-text as "Other" | Moderate | Low | Medium |
| **Sleep Duration** | Yes | Yes (valuable health metric) | None needed | N/A | N/A | N/A |
| **Sleep Notes (Free-Text)** | Yes | Partial | Replace with structured quality options | Low | None | Low |
| **Safety/Crisis Notes** | Yes | Yes (clinical importance) | Keep but add: clear labeling, practitioner alert option | N/A | HIGH (critical for safety) | N/A |
| **Medication Info** | Maybe | Partial (if feature exists) | Structured selection from formulary; avoid free-text | Low | Low | Medium |
| **Location Data** | No | No | Do NOT collect | N/A | Eliminates stalking risk | N/A |
| **Precise Timestamps** | Yes | Partial | Retain date + hour; avoid minute/second precision in UI | Very low | None | Low |
| **Device Contacts** | No | No | Do NOT access | N/A | N/A | N/A |
| **Device Photos** | No | No (unless attachment feature) | If attachments: strip EXIF metadata | N/A | Reduces location leak | Medium |
| **Browsing History** | No | No | Do NOT access | N/A | N/A | N/A |
| **IP Address** | Yes (logs) | Partial (security) | Retain 90 days max; hash after 7 days | None | Low | Low |
| **Device ID** | Yes | Partial (fraud detection) | Rotate/hash after 90 days | None | Low | Low |
| **Full User Agent** | Yes (logs) | Partial | Retain device type + OS + app version only | None | None | Low |
| **Analytics User ID** | Maybe | No | Use anonymous session ID; no link to patient ID | None | Eliminates analytics-to-PHI link | Medium |

### 0.3.3 Recommended Minimization Implementations

#### MINIMIZE-001: Replace Free-Text with Structured Options

**Current State:** Mood notes, anxiety triggers, and sleep notes allow unlimited free-text input.

**Risk:** Patients may inadvertently disclose highly sensitive information (names, addresses, incidents involving others).

**Recommended Change:**
```
BEFORE: 
[Free-text field: "Describe how you're feeling..."]

AFTER:
[Checkbox grid of common emotions: Anxious, Sad, Hopeful, etc.]
[Checkbox grid of common triggers: Work stress, Relationship, Health concern, etc.]
[Optional toggle: "Add a personal note" → reveals limited free-text (500 char max)]
[Soft warning: "Avoid including names, addresses, or details about others"]
```

**UX Impact:** Moderate — some users prefer free expression  
**Safety Impact:** Positive — reduces inadvertent sensitive disclosure  
**Implementation Effort:** Medium (UI redesign + data model update)

#### MINIMIZE-002: Isolate PHI from Telemetry

**Current State:** Analytics may have technical access to PHI database.

**Risk:** Analytics vendor or internal analytics team could theoretically access PHI.

**Recommended Change:**
- Analytics database is separate system, physically isolated from PHI database
- Analytics events contain only: anonymous_session_id, event_type, timestamp, app_version, device_type
- No patient_id, no health data, no identifiers flow to analytics
- Architectural firewall: analytics services cannot query PHI services

**UX Impact:** None  
**Safety Impact:** Positive — eliminates analytics as PHI breach vector  
**Implementation Effort:** Medium (architecture change if not already isolated)

#### MINIMIZE-003: Metadata Retention Limits

**Current State:** IP addresses and device identifiers retained indefinitely.

**Risk:** Long-term metadata creates surveillance risk; attractive target.

**Recommended Change:**
- IP addresses: Hash after 7 days, delete after 90 days
- Device identifiers: Rotate/hash after 90 days
- Exception: Audit logs retain metadata where required for compliance (10 years)

**UX Impact:** None  
**Safety Impact:** Positive — reduces value of metadata exfiltration  
**Implementation Effort:** Low (log rotation configuration)

#### MINIMIZE-004: Age Verification Without Full DOB

**Current State:** Full date of birth collected.

**Risk:** DOB is a key identifier for identity theft.

**Recommended Change:**
- Collect birth year only for age calculation
- OR collect age range (under 16, 16-18, 19+) for minor/capacity determination
- If full DOB needed for specific verification, collect but do not store beyond verification

**UX Impact:** Low  
**Safety Impact:** Positive — reduces identity theft value  
**Implementation Effort:** Low

---

## 0.4 Threat Model (STRIDE + Safety)

### 0.4.1 System Context

**System:** Mental Health Client Logging Application  
**Assets:**  
- Patient PHI (mood logs, anxiety logs, safety notes, etc.)
- Patient PII (name, email, phone)
- Consent records
- Authentication credentials
- Practitioner-patient relationships
- Audit logs

**Threat Actors:**
- External attackers (opportunistic, targeted)
- Malicious insider (staff with access)
- Compromised practitioner account
- Abusive partner / stalker with device access
- Law enforcement (legal, questionable)
- Researchers seeking unauthorized data
- Cloud provider insider
- Rogue administrator

### 0.4.2 STRIDE Threat Analysis

#### SPOOFING

| Threat ID | Asset | Attack Path | Likelihood | Impact | Mitigations | Residual Risk | Detection | Evidence |
|-----------|-------|-------------|------------|--------|-------------|---------------|-----------|----------|
| S-001 | Patient Account | Attacker guesses weak password | Medium | High (PHI exposure) | MFA for patients (optional but encouraged), Password strength requirements, Account lockout | Low | Failed login alerts, Anomalous location login | Auth logs |
| S-002 | Practitioner Account | Credential phishing | Medium | Critical (many patients' PHI) | MFA required (mandatory), Phishing-resistant MFA (FIDO2 preferred), Security awareness training | Low | MFA enrollment monitoring, Phishing attempt reporting | Auth logs, MFA logs |
| S-003 | API Endpoint | Forged API requests | Low | High | API authentication required, Request signing, Rate limiting | Low | Invalid request monitoring | API logs |
| S-004 | Patient Identity | Attacker creates account impersonating victim | Low | Medium (fake entries) | Email verification, Identity proofing for sensitive actions | Low | Duplicate account detection | Registration logs |

#### TAMPERING

| Threat ID | Asset | Attack Path | Likelihood | Impact | Mitigations | Residual Risk | Detection | Evidence |
|-----------|-------|-------------|------------|--------|-------------|---------------|-----------|----------|
| T-001 | Mood Entries | Attacker modifies entries in transit | Low | High (clinical integrity) | TLS 1.2+ encryption, Certificate pinning on mobile | Very Low | Certificate validation failure alerts | Network logs |
| T-002 | Audit Logs | Insider modifies logs to hide access | Low | Critical (accountability loss) | Append-only log storage, Log signing, Off-site replication | Very Low | Log integrity verification | Signed log hashes |
| T-003 | Consent Records | Attacker modifies consent to gain access | Low | Critical | Consent records immutable, Cryptographic integrity | Very Low | Consent hash verification | Audit trail |
| T-004 | Database Records | SQL injection modifies data | Low | Critical | Parameterized queries, WAF, Input validation | Very Low | SQL error monitoring, WAF alerts | App logs, WAF logs |

#### REPUDIATION

| Threat ID | Asset | Attack Path | Likelihood | Impact | Mitigations | Residual Risk | Detection | Evidence |
|-----------|-------|-------------|------------|--------|-------------|---------------|-----------|----------|
| R-001 | Consent | Patient claims they never consented | Medium | High (legal exposure) | Timestamped consent records, Consent version tracking, IP/device logging | Low | N/A (evidence exists) | Consent audit trail |
| R-002 | Practitioner Access | Practitioner denies accessing record | Medium | High (HIPAA/PHIPA violation) | Comprehensive audit logging, Session tracking | Low | N/A (evidence exists) | Audit logs |
| R-003 | Entry Submission | Patient claims they didn't submit entry | Low | Medium | Entry signing with device key, Timestamp verification | Low | Signature verification | Entry metadata |

#### INFORMATION DISCLOSURE

| Threat ID | Asset | Attack Path | Likelihood | Impact | Mitigations | Residual Risk | Detection | Evidence |
|-----------|-------|-------------|------------|--------|-------------|---------------|-----------|----------|
| I-001 | PHI Database | Database breach via SQL injection | Low | Critical | Encryption at rest, Parameterized queries, WAF, Principle of least privilege | Low | Query anomaly detection | DB logs, WAF |
| I-002 | PHI in Transit | Network interception | Low | Critical | TLS 1.2+, Certificate pinning, HSTS | Very Low | Certificate errors | Network logs |
| I-003 | Backup Data | Backup storage breach | Low | Critical | Encrypted backups, Access controls, Canadian residency | Low | Backup access monitoring | Backup logs |
| I-004 | Audit Logs | Log data exposure | Low | High | Log access controls, Encryption, Need-to-know access | Low | Log access monitoring | Access logs |
| I-005 | Patient Device | Device theft/loss with local data | Medium | High | Device encryption, App PIN/biometric, Remote wipe capability, Session expiry | Medium | N/A (device lost) | N/A |
| I-006 | Error Messages | Verbose errors expose system info | Medium | Medium | Generic error messages to users, Detailed logs internal only | Low | Error response review | Pentest reports |
| I-007 | Practitioner Overbroad Access | Practitioner accesses patients without consent | Low | Critical | Consent-gated access, Access logging, Anomaly detection | Low | Access pattern monitoring | Audit logs |

#### DENIAL OF SERVICE

| Threat ID | Asset | Attack Path | Likelihood | Impact | Mitigations | Residual Risk | Detection | Evidence |
|-----------|-------|-------------|------------|--------|-------------|---------------|-----------|----------|
| D-001 | API Availability | DDoS attack | Medium | High (service disruption) | CDN/DDoS protection, Rate limiting, Auto-scaling | Medium | Traffic monitoring | Infrastructure logs |
| D-002 | Patient Access | Account lockout abuse | Low | Medium | CAPTCHA, Progressive lockout, Lockout notification | Low | Lockout rate monitoring | Auth logs |
| D-003 | Database | Resource exhaustion attack | Low | High | Query timeouts, Connection limits, Read replicas | Low | Performance monitoring | DB metrics |

#### ELEVATION OF PRIVILEGE

| Threat ID | Asset | Attack Path | Likelihood | Impact | Mitigations | Residual Risk | Detection | Evidence |
|-----------|-------|-------------|------------|--------|-------------|---------------|-----------|----------|
| E-001 | Admin Access | Attacker gains admin privileges | Low | Critical | MFA for all admin, Principle of least privilege, Privileged access management | Low | Admin action monitoring | Admin logs |
| E-002 | Patient to Practitioner | Patient manipulates role | Very Low | Critical | Server-side role enforcement, Role verification | Very Low | Role change monitoring | Audit logs |
| E-003 | Practitioner Scope | Practitioner accesses other practitioners' patients | Low | Critical | Consent-gated access only, No "all patients" access | Low | Cross-practitioner access alerts | Audit logs |

### 0.4.3 Safety-Specific Threat Analysis

| Threat ID | Scenario | Asset at Risk | Attack Path | Likelihood | Impact | Mitigations | Residual Risk | Detection | Evidence |
|-----------|----------|---------------|-------------|------------|--------|-------------|---------------|-----------|----------|
| SAFE-001 | **Abusive Partner Coercion** | Patient's PHI, Safety | Partner forces patient to reveal entries or share access | High (DV context) | Critical (physical danger) | No "share with non-practitioner" feature; Duress PIN option (shows sanitized data); Safety planning in-app resources; Hotline integration | Medium (social risk remains) | Cannot technically detect coercion | Support contact records |
| SAFE-002 | **Stalking via App** | Patient's location/patterns | Stalker monitors entries to track victim's state/patterns | Medium | High (safety risk) | No location collection; Encourage patient not to share temporal patterns; No real-time entry notification to practitioners | Medium | N/A | N/A |
| SAFE-003 | **Device Seizure** | PHI on device | Abuser/attacker seizes unlocked phone | Medium | Critical | App requires PIN/biometric; Session timeout (5 min for sensitive); Device wipe capability; No persistent login | Medium | N/A | N/A |
| SAFE-004 | **Practitioner Account Compromise** | Many patients' PHI | Phishing, credential stuffing, insider | Low-Medium | Critical | MFA mandatory; Phishing-resistant MFA; Access anomaly detection; Immediate revocation capability | Low | Anomalous access patterns | Auth logs, Access logs |
| SAFE-005 | **Insider Curiosity (Staff)** | Patient PHI | Staff browses patient data without authorization | Medium (common in healthcare) | High | No-human-access architecture; No staff access to PHI by default; Break-glass with dual approval | Very Low | All access logged; Random audits | Audit logs |
| SAFE-006 | **Rogue Administrator** | All data | Admin abuses privileges to access/exfiltrate data | Low | Critical | PAM with dual approval; Admin actions logged to immutable external log; Separation of duties; Background checks | Low | Admin action monitoring | PAM logs, External audit logs |
| SAFE-007 | **Misdirected Sharing** | Patient PHI | Patient accidentally shares with wrong practitioner | Medium | High (wrong person sees PHI) | Confirmation prompt with practitioner name; "Undo" window (5 min); Sharing review in settings | Medium | Patient reports; Sharing logs | Consent records |
| SAFE-008 | **Export Leakage** | Exported PHI file | Patient exports data, file is lost/shared/stolen | Medium | High | Encryption option for export; Warning about file handling; No server copy of export | High (patient's control) | N/A | Export request logs |
| SAFE-009 | **Cloud Misconfiguration** | PHI in cloud storage | S3 bucket public, DB exposed, etc. | Low (if well-managed) | Critical | IaC with security defaults; Cloud security posture management; No public endpoints for data; Regular audits | Low | CSPM alerts | Config audit logs |
| SAFE-010 | **Child/Minor Safety** | Minor's PHI | Parent/guardian misuses access to minor's data | Medium | High (trust violation) | Age-appropriate consent; Mature minor provisions (ON PHIPA s.23); Confidential teen entries option | Medium | N/A | Consent records |

### 0.4.4 Threagile YAML Model

*Reference: See [docs/threagile.md](../threagile.md) for Threagile documentation.*

```yaml
# Threagile Threat Model for Mental Health Client Logging Application
# Version: 1.0
# Date: 2026-02-04

threagile_version: 1.0.0

title: Mental Health Client Logging App - Threat Model

business_criticality: critical

description: |
  Threat model for a mental health client logging application that allows patients
  to log mood, anxiety, triggers, and safety notes, and share with healthcare practitioners.
  Contains highly sensitive PHI including mental health information.

author:
  name: Privacy Engineering Team

technical_assets:

  patient_mobile_app:
    id: patient-mobile-app
    title: Patient Mobile Application
    description: React Native mobile app for patients to log mental health entries
    type: process
    usage: business
    confidentiality: confidential
    integrity: critical
    availability: important
    encryption: transparent
    data_assets_stored:
      - patient-phi
      - consent-records
    data_assets_processed:
      - patient-phi
      - consent-records
    technologies:
      - mobile
      - react-native
      - encryption

  practitioner_web_portal:
    id: practitioner-portal
    title: Practitioner Web Portal
    description: React web application for practitioners to view patient entries
    type: process
    usage: business
    confidentiality: confidential
    integrity: critical
    availability: important
    encryption: transparent
    data_assets_stored: []
    data_assets_processed:
      - patient-phi
      - consent-records
    technologies:
      - web-application
      - react

  api_backend:
    id: api-backend
    title: Backend API Service
    description: REST API handling all data operations
    type: process
    usage: business
    confidentiality: strictly-confidential
    integrity: critical
    availability: critical
    encryption: transparent
    data_assets_stored: []
    data_assets_processed:
      - patient-phi
      - consent-records
      - audit-logs
    technologies:
      - web-service-rest
      - nodejs

  primary_database:
    id: primary-database
    title: Primary Database (PostgreSQL)
    description: Encrypted database storing all PHI
    type: datastore
    usage: business
    confidentiality: strictly-confidential
    integrity: critical
    availability: critical
    encryption: data-with-symmetric-shared-key
    data_assets_stored:
      - patient-phi
      - consent-records
      - patient-pii
    technologies:
      - database
      - postgresql

  audit_log_store:
    id: audit-log-store
    title: Audit Log Store
    description: Append-only storage for audit logs
    type: datastore
    usage: business
    confidentiality: confidential
    integrity: mission-critical
    availability: important
    encryption: data-with-symmetric-shared-key
    data_assets_stored:
      - audit-logs
    technologies:
      - logging

  backup_storage:
    id: backup-storage
    title: Backup Storage
    description: Encrypted backup storage in Canadian data center
    type: datastore
    usage: business
    confidentiality: strictly-confidential
    integrity: critical
    availability: important
    encryption: data-with-symmetric-shared-key
    data_assets_stored:
      - patient-phi
      - patient-pii
    technologies:
      - file-server
      - block-storage

data_assets:

  patient-phi:
    id: patient-phi
    title: Patient PHI (Protected Health Information)
    description: Mood logs, anxiety logs, triggers, sleep data, safety notes, CBT responses
    usage: business
    quantity: many
    confidentiality: strictly-confidential
    integrity: critical
    availability: important

  consent-records:
    id: consent-records
    title: Consent Records
    description: Records of patient consent for collection, use, and disclosure
    usage: business
    quantity: many
    confidentiality: confidential
    integrity: mission-critical
    availability: critical

  patient-pii:
    id: patient-pii
    title: Patient PII
    description: Name, email, phone number
    usage: business
    quantity: many
    confidentiality: confidential
    integrity: important
    availability: important

  audit-logs:
    id: audit-logs
    title: Audit Logs
    description: Immutable logs of all PHI access and system events
    usage: business
    quantity: very-many
    confidentiality: confidential
    integrity: mission-critical
    availability: important

trust_boundaries:

  patient_device:
    id: patient-device-boundary
    title: Patient Device
    description: The patient's mobile device
    type: network-dedicated-hoster

  practitioner_browser:
    id: practitioner-browser-boundary
    title: Practitioner Browser
    description: The practitioner's web browser
    type: network-dedicated-hoster

  cloud_infrastructure:
    id: cloud-infra-boundary
    title: Cloud Infrastructure
    description: Canadian cloud hosting environment
    type: network-cloud-provider

communication_links:

  patient_app_to_api:
    source: patient-mobile-app
    target: api-backend
    description: Patient app submitting and retrieving entries
    protocol: https
    authentication: token
    authorization: consent-based
    vpn: false
    data_assets_sent:
      - patient-phi
      - consent-records
    data_assets_received:
      - patient-phi

  practitioner_portal_to_api:
    source: practitioner-portal
    target: api-backend
    description: Practitioner viewing patient entries
    protocol: https
    authentication: token-mfa
    authorization: consent-based
    vpn: false
    data_assets_sent: []
    data_assets_received:
      - patient-phi

  api_to_database:
    source: api-backend
    target: primary-database
    description: API read/write to database
    protocol: tcp-encrypted
    authentication: credentials
    authorization: role-based
    vpn: false
    data_assets_sent:
      - patient-phi
      - consent-records
    data_assets_received:
      - patient-phi
      - consent-records

  api_to_audit_logs:
    source: api-backend
    target: audit-log-store
    description: API writing audit events
    protocol: tcp-encrypted
    authentication: credentials
    authorization: write-only
    vpn: false
    data_assets_sent:
      - audit-logs
    data_assets_received: []

individual_risk_categories:
  safety-domestic-violence:
    title: Domestic Violence / Abusive Partner Risk
    description: Risk that an abusive partner could coerce or deceive the patient to gain access to PHI
    
  safety-stalking:
    title: Stalking Risk
    description: Risk that a stalker could use app data to monitor or track the patient
    
  safety-self-harm:
    title: Self-Harm Disclosure Risk
    description: Risk that safety notes revealing self-harm intent could be misused or mishandled
```

---

## 0.5 No-Human-Access Posture

### 0.5.1 Operating Model: No Human Access by Default

**Principle:** No employee of the app company shall have routine access to patient PHI. The system is designed to operate without any human ever needing to view patient health entries.

#### Support Flows Without PHI Access

| Support Scenario | How It Works Without PHI Access |
|-----------------|--------------------------------|
| "I can't log in" | Support views: account status, last login attempt, MFA status, error codes. No PHI needed. |
| "The app crashed" | Support views: crash logs (PHI-redacted), device info, app version. No PHI needed. |
| "My entries aren't syncing" | Support views: sync status, queue depth, error codes, connectivity logs. Entry content NOT viewed. |
| "I want to delete my account" | Support verifies identity, initiates deletion workflow. No PHI viewing required. |
| "I shared with wrong practitioner" | Support can revoke sharing via consent management interface. Consent record viewed (not entry content). |
| "I need to export my data" | Patient self-serves via app. If assistance needed, support guides through UI. No viewing. |

#### Technical Enforcement

| Control | Implementation |
|---------|----------------|
| **RBAC with no PHI role** | Default support role has zero PHI table access |
| **Database segmentation** | PHI tables in separate schema; support credentials cannot query |
| **API gateway restrictions** | Support APIs do not expose PHI endpoints |
| **Logging without PHI** | Support-accessible logs have PHI redacted/masked |
| **No admin backdoor** | No "view as patient" or "impersonate" functionality |

### 0.5.2 Break-Glass Procedure (If Unavoidable)

**When Break-Glass May Be Required:**
- Critical bug affecting data integrity that cannot be diagnosed without seeing affected data
- Legal subpoena requiring data retrieval where patient cannot self-serve
- Security incident investigation requiring data forensics

**Break-Glass Requirements:**

| Requirement | Implementation |
|-------------|----------------|
| **Dual Approval** | Two designated Privacy Officers must approve (one cannot be requestor) |
| **Written Justification** | Document: what data, why needed, alternatives considered |
| **Time-Boxing** | Access granted for maximum 4 hours; extension requires re-approval |
| **Minimum Necessary** | Access limited to specific patient(s) / record(s) identified |
| **Logging** | All actions during break-glass logged to immutable external system |
| **Customer Notification** | Affected patient(s) notified within 72 hours of what was accessed and why |
| **Post-Incident Review** | Mandatory review within 7 days; document lessons learned |

#### Break-Glass Workflow

```
1. REQUEST
   - Staff member documents need in ticketing system
   - Specifies: patient ID(s), data needed, purpose, alternatives rejected
   
2. FIRST APPROVAL
   - Privacy Officer #1 reviews request
   - Verifies: necessity, scope, time limit
   - Approves or denies with documented rationale
   
3. SECOND APPROVAL
   - Privacy Officer #2 (different person) reviews
   - Confirms first approval rationale
   - Approves or denies
   
4. ACCESS GRANT
   - PAM system grants time-limited access
   - Clock starts (4 hours max)
   - All actions logged to external system
   
5. WORK PERFORMED
   - Staff accesses only approved data
   - Documents findings
   - Completes task
   
6. ACCESS REVOCATION
   - Access auto-revokes at time limit
   - Or staff manually revokes when done
   
7. NOTIFICATION
   - Within 72 hours: patient notified
   - Notification includes: date, what accessed, purpose, who accessed
   
8. POST-REVIEW
   - Within 7 days: incident reviewed
   - Document: was break-glass necessary? Could it be prevented? Process improvements?
```

### 0.5.3 No-Human-Access Acceptance Criteria

**Pass/Fail Checklist:**

| Criterion | Pass | Fail | Evidence Required |
|-----------|------|------|-------------------|
| Support role cannot query PHI tables | ☐ | ☐ | RBAC configuration export |
| Support-accessible logs have PHI redacted | ☐ | ☐ | Sample log review |
| No "view as patient" functionality exists | ☐ | ☐ | Code review attestation |
| No API endpoint exposes PHI to support role | ☐ | ☐ | API authorization matrix |
| Break-glass requires dual approval | ☐ | ☐ | PAM configuration |
| Break-glass is time-limited | ☐ | ☐ | PAM configuration |
| Break-glass logging is immutable and external | ☐ | ☐ | Log architecture diagram |
| Patient notification procedure documented | ☐ | ☐ | Procedure document |
| No break-glass events in last 90 days OR all properly documented | ☐ | ☐ | Break-glass log review |

**Required Evidence Artifacts:**
- [ ] RBAC configuration showing support role permissions
- [ ] Sample support-accessible logs demonstrating PHI redaction
- [ ] Code review attestation for no-backdoor
- [ ] API authorization matrix
- [ ] PAM configuration for break-glass
- [ ] Break-glass procedure document
- [ ] Patient notification template
- [ ] Break-glass audit log (if any events occurred)

---

## G0: Privacy-by-Design Compliance Gates

> **Implementation Best Practice (Non-statutory):** The following gates (G0.x series) represent privacy-by-design best practices that go beyond minimum statutory requirements. They are designed to protect vulnerable persons and demonstrate accountability.

### G0.1 Patient-First Data Promise & Governance Alignment

**Gate ID:** G0.1  
**Type:** Implementation Best Practice (Non-statutory)

**Requirement:**  
A patient-facing Data Promise must exist, be published, and be aligned with actual technical implementation.

**Acceptance Criteria:**

```gherkin
Feature: G0.1 Data Promise Governance

  Scenario: Data Promise is published and accessible
    Given the application is deployed
    When a patient accesses privacy information
    Then a Data Promise document SHALL be accessible within 2 clicks from any screen
    And the Data Promise SHALL be written at grade 8 reading level
    And the Data Promise SHALL be available in English and French

  Scenario: Data Promise aligns with implementation
    Given the Data Promise makes specific commitments
    When the technical implementation is reviewed
    Then every commitment in the Data Promise SHALL be technically enforced
    And any "Implementation-Dependent Promise" SHALL have verification evidence

  Scenario: Data Promise is reviewed regularly
    Given the Data Promise is published
    When 12 months have passed
    Then the Data Promise SHALL be reviewed for accuracy
    And any changes SHALL be communicated to patients
```

**Evidence Artifacts:**
- [ ] Published Data Promise document
- [ ] Reading level assessment
- [ ] Technical verification report
- [ ] Review schedule and records

---

### G0.2 Data Inventory & Flow Completeness

**Gate ID:** G0.2  
**Type:** Implementation Best Practice (Non-statutory)

**Requirement:**  
A complete data inventory and flow documentation must exist and be maintained.

**Acceptance Criteria:**

```gherkin
Feature: G0.2 Data Inventory Completeness

  Scenario: All PHI elements are inventoried
    Given the data inventory document exists
    When I review the inventory
    Then every field/element containing PHI SHALL be listed
    And each element SHALL have: sensitivity, source, storage, transmission, access, retention, deletion path

  Scenario: Data flows are documented
    Given data flow documentation exists
    When I review the flows
    Then every PHI transmission path SHALL be documented
    And each flow SHALL indicate encryption status
    And each flow SHALL indicate authorization method

  Scenario: Inventory is current
    Given a new feature is deployed
    When the feature involves PHI
    Then the data inventory SHALL be updated within 7 days
    And the data flow documentation SHALL be updated within 7 days
```

**Evidence Artifacts:**
- [ ] Data inventory document
- [ ] Data flow diagrams
- [ ] Update log showing maintenance

---

### G0.3 Minimization-by-Default Controls

**Gate ID:** G0.3  
**Type:** Implementation Best Practice (Non-statutory)

**Requirement:**  
Data collection must follow minimization principles with documented justification for each field.

**Acceptance Criteria:**

```gherkin
Feature: G0.3 Minimization Controls

  Scenario: Every PHI field has necessity justification
    Given the data necessity matrix exists
    When I review the matrix
    Then every PHI field SHALL have documented necessity justification
    And fields marked "not strictly required" SHALL have mitigation or removal plan

  Scenario: Free-text is minimized
    Given forms collect patient input
    When free-text fields are reviewed
    Then structured alternatives SHALL be offered where possible
    And free-text SHALL have character limits
    And guidance against including third-party information SHALL be provided

  Scenario: PHI is segregated from analytics
    Given analytics are collected
    When analytics data stores are examined
    Then NO PHI or direct identifiers SHALL be present in analytics
    And analytics systems SHALL NOT have access to PHI databases
```

**Evidence Artifacts:**
- [ ] Data necessity matrix
- [ ] Form design documentation
- [ ] Analytics architecture diagram showing PHI isolation

---

### G0.4 Threat Model Coverage & Mitigation Tracking

**Gate ID:** G0.4  
**Type:** Implementation Best Practice (Non-statutory)

**Requirement:**  
A threat model must exist covering STRIDE categories and safety-specific threats, with tracked mitigations.

**Acceptance Criteria:**

```gherkin
Feature: G0.4 Threat Model Coverage

  Scenario: STRIDE categories are covered
    Given the threat model exists
    When I review threat coverage
    Then Spoofing threats SHALL be documented with mitigations
    And Tampering threats SHALL be documented with mitigations
    And Repudiation threats SHALL be documented with mitigations
    And Information Disclosure threats SHALL be documented with mitigations
    And Denial of Service threats SHALL be documented with mitigations
    And Elevation of Privilege threats SHALL be documented with mitigations

  Scenario: Safety-specific threats are covered
    Given vulnerable populations use the app
    When I review safety threats
    Then Abusive partner coercion SHALL be documented with mitigations
    And Device seizure/theft SHALL be documented with mitigations
    And Practitioner account compromise SHALL be documented with mitigations
    And Insider curiosity SHALL be documented with mitigations

  Scenario: Mitigations are tracked
    Given mitigations are identified
    When I review mitigation status
    Then each mitigation SHALL have implementation status
    And each mitigation SHALL have an owner
    And open mitigations SHALL have target completion dates
```

**Evidence Artifacts:**
- [ ] Threat model document (Threagile YAML or equivalent)
- [ ] Mitigation tracking spreadsheet/tickets
- [ ] Threat model review records

---

### G0.5 No-Human-Access Operating Model

**Gate ID:** G0.5  
**Type:** Implementation Best Practice (Non-statutory)

**Requirement:**  
The system must operate without routine human access to PHI, with documented break-glass procedures if access is ever required.

**Acceptance Criteria:**

```gherkin
Feature: G0.5 No-Human-Access Model

  Scenario: Default support roles have no PHI access
    Given support staff are provisioned
    When their access is examined
    Then support role SHALL NOT have query access to PHI tables
    And support-accessible logs SHALL have PHI redacted

  Scenario: Break-glass requires dual approval
    Given PHI access is required for exceptional circumstance
    When break-glass is requested
    Then two independent approvers SHALL be required
    And written justification SHALL be documented
    And access SHALL be time-limited (max 4 hours)

  Scenario: Break-glass is logged and patients notified
    Given break-glass access occurred
    When post-access review occurs
    Then all actions SHALL be logged to immutable external system
    And affected patients SHALL be notified within 72 hours
    And post-incident review SHALL occur within 7 days
```

**Evidence Artifacts:**
- [ ] RBAC configuration
- [ ] PAM configuration
- [ ] Break-glass procedure document
- [ ] Break-glass audit logs (if any)
- [ ] Patient notification records (if any)

---

---

## 1. Source Inventory & Coverage Assessment

### 1.1 Provided Legislation Files

| Province/Jurisdiction | Act/Document | Coverage | Key Role Definitions |
|----------|--------------|----------|---------------------|
| **Federal (Canada)** | Personal Information Protection and Electronic Documents Act (PIPEDA) S.C. 2000, c. 5 | Full Act (current to Jan 19, 2026) | Organization (s.2), Individual (s.2), Personal Information (Schedule 1) |
| **Ontario** | Personal Health Information Protection Act, 2004 (PHIPA) S.O. 2004, c. 3 | Full Act (consolidated to Jan 1, 2026) | Health Information Custodian (s.3), Agent (s.2), Substitute Decision-Maker (s.5) |
| **Alberta** | Health Information Act (HIA) RSA 2000, c. H-5 | Full Act (current to Dec 31, 2021) + Guidelines Manual | Custodian (s.1(1)(f)), Affiliate (s.1(1)(a)), Agent (s.1(1)(b)) |
| **Manitoba** | Personal Health Information Act (PHIA) C.C.S.M. c. P33.5 | Full Act (current to Feb 2026) | Trustee (s.1), Information Manager (s.1), Health Professional (s.1) |
| **Saskatchewan** | Health Information Protection Act (HIPA) c. H-0.021 | Full Act | Trustee (s.2(t)), Information Management Service Provider (s.2(j)), Subject Individual (s.2(s)) |
| **British Columbia** | E-Health Act [SBC 2008] c. 38 + Personal Information Protection Act (PIPA) [SBC 2003] c. 63 | Full Acts (current to Feb 2026) | Organization (PIPA s.1), Administrator (E-Health s.1), Health Care Body (E-Health s.1) |
| **New Brunswick** | Personal Health Information Privacy and Access Act (PHIPAA) c. P-7.05 | Full Act | Custodian (s.1), Agent (s.1), Information Manager (s.1), Substitute Decision-Maker (s.1) |
| **Nova Scotia** | Personal Health Information Act, Chapter 41 of the Acts of 2010 | Full Act (current to Jun 30, 2025) | Custodian (s.3), Agent (s.3), Substitute Decision-Maker (s.21) |
| **Prince Edward Island** | Health Information Act c. H-1.41 | Full Act (current to Nov 2025) | Custodian (s.1(e)), Agent (s.1(a)), Information Manager (s.1(q)) |
| **Newfoundland & Labrador** | Personal Health Information Act SNL2008 c. P-7.01 | Full Act + Policy Manual | Custodian (s.4), Agent (s.2(a)), Representative (s.7), Information Manager (s.22) |
| **Quebec** | Act Respecting the Sharing of Certain Health Information P-9.0001 + Act Respecting the Protection of Personal Information in the Private Sector P-39.1 | Full Acts (current to Oct 24, 2025) | Access Authorization Manager (P-9.0001), Enterprise (P-39.1 s.1) |

### 1.2 Defined Terms Index

| Term | ON (PHIPA) | AB (HIA) | MB (PHIA) | SK (HIPA) | BC (PIPA/E-Health) | NB (PHIPAA) | NS (PHIA) | PE (HIA) | NL (PHIA) | Federal (PIPEDA) |
|------|------------|----------|-----------|-----------|---------------|-------------|-------------|----------|----------|------------------|
| **Personal Health Information** | s.4(1) - identifying info re: health, health care, payments, donations, health number | s.1(1)(k) - diagnostic/treatment/care info + registration info | s.1 - info re: health, health care, payments, eligibility, PHIN | s.2(m) - physical/mental health, health services, donations, registration | PIPA s.1 - personal info; E-Health s.1 - health info in banks | s.1 - info re: health, health care, health care provider, payments, health number | s.4 - info re: physical/mental health, health services, health number | s.1 - per regulations, health/care related | s.5 - identifying info re: health, health services, donations, payments | Schedule 1 - personal info (health is sensitive subset) |
| **Consent (Express)** | s.18(3) - required for disclosure to non-custodian | s.34 - required except where exceptions apply | s.19.1 - elements specified | s.6 - written/oral, revocable | PIPA s.6-8 - consent required; s.7 explicit or implicit | s.17-19 - express required for certain disclosures | s.16 - express consent requirements | s.13 - criteria specified | s.23-25 - elements, express or implied | s.6.1 - valid consent, Schedule 1 Principle 3 |
| **Consent (Implied)** | s.18(2), s.20(2) - for health care purposes within circle of care | Permitted for health services | s.22 - for certain disclosures | s.5-6 - permitted in certain contexts | PIPA s.8 - implicit consent | s.18 - knowledgeable and continuing | s.12-15 - knowledgeable implied consent | Not explicit | s.24 - implied for care purposes | Schedule 1 - implied where appropriate |
| **Breach Notification** | s.12(2)(3) - notify individual + Commissioner | s.60.1 - notify Commissioner, Minister, affected individuals if risk of harm | s.19.0.1 - action if privacy breach | Not in provided text | PIPA s.34 - protection required | Not in provided text | s.38 - disclosure without consent procedures | s.74 - disclosure to Commissioner | s.15 - security, s.20 - duty to notify | s.10.1-10.3 - mandatory breach notification |
| **De-identification** | s.2 - remove info that identifies or could identify | s.1(1)(r.1) - non-identifying health info | Not defined | s.2(d) - info from which identifying info removed | PIPA - personal info definition | s.1 - identifying info suppressed | s.3 - de-identified PHI | s.1(g) - stripped/encoded/transformed | s.21 - power to transform PHI | Schedule 1 - limited to purposes |
| **Minor Capacity** | s.23(1)2 - under 16, parent may consent unless re: treatment child decided on own | s.104 - reference to other acts | s.60 - parent/guardian for children | s.56 - exercise of rights by other persons | PIPA s.1 - refers to common law | s.5, s.23-25 - Medical Consent of Minors Act applies | s.18-19 - ability to consent | s.14 - capability assessment | s.7 - representative provisions | Common law capacity |
| **Retention** | s.13 - secure manner, prescribed requirements | s.64 - retention and destruction | s.17 - restrictions on retention/destruction | s.17 - retention and destruction policy | PIPA s.35 - retention | s.55 - retention, storage, secure destruction | s.35 - retention | s.34-46 - management of PHI | Part II - practices to protect PHI | Schedule 1 Principle 5 - limiting use |
| **Cross-Border** | s.50 - disclosure outside Ontario permitted in certain cases | s.70-71 - addresses extra-provincial disclosure | Not in provided text | Not in provided text | PIPA s.34 - protection; E-Health s.5(c) - disclosure inside/outside Canada | Not in provided text | s.37 - disclosure outside NS | s.35 - disclosure outside province | s.47 - disclosure outside province | s.5(1) - applies to transborder data flows |

---

## 2. Applicability Summary (Per Province)

### 2.1 Ontario - PHIPA

**Regulated Entities in This Scenario:**

| Entity | Regulated Under PHIPA? | Legal Basis |
|--------|------------------------|-------------|
| Practitioner (psychologist/therapist/counselor) | **YES** - Health Information Custodian | s.3(1) para 1: "A health care practitioner or a person who operates a group practice of health care practitioners" |
| App Company | **YES** - Likely Agent or Electronic Service Provider | s.2 "agent" definition + s.17 (agents and information) + s.54.1 (consumer electronic service providers) |
| Hosting/Subprocessors | **YES** - As agents of custodian | s.17(1) - custodian responsible for agents |

**PHI Definition Applicability:**
> "personal health information" means identifying information about an individual in oral or recorded form, if the information, (a) relates to the physical or mental health of the individual... (b) relates to the providing of health care to the individual" - PHIPA s.4(1)

**Conclusion:** Mental health log entries (anxiety episodes, triggers, symptoms, mood, safety notes) are PHI under s.4(1)(a). Practitioner identity in relation to care is PHI under s.4(1)(b).

### 2.2 Alberta - HIA

**Regulated Entities:**

| Entity | Regulated Under HIA? | Legal Basis |
|--------|---------------------|-------------|
| Practitioner | **YES** - Custodian | HIA s.1(1)(f) - designated health service providers |
| App Company | **YES** - Affiliate or Information Manager | HIA s.1(1)(a) - "affiliate" includes any person performing a service for a custodian |
| Hosting/Subprocessors | **YES** - As affiliates | Same as above |

**Key Distinction:** Alberta HIA distinguishes between "diagnostic, treatment and care information" and "registration information" with different disclosure rules.

### 2.3 Manitoba - PHIA

**Regulated Entities:**

| Entity | Regulated Under PHIA? | Legal Basis |
|--------|----------------------|-------------|
| Practitioner | **YES** - Trustee | s.1 "trustee" - health professional, health care facility, public body, health services agency |
| App Company | **YES** - Information Manager | s.1 "information manager" - processes, stores, or destroys PHI for trustee |
| Hosting/Subprocessors | **YES** - Through information manager provisions | s.25 - duties of information managers |

### 2.4 Saskatchewan - HIPA

**Regulated Entities:**

| Entity | Regulated Under HIPA? | Legal Basis |
|--------|----------------------|-------------|
| Practitioner | **YES** - Trustee | s.2(t)(xii) - "a health professional licensed or registered pursuant to an Act" |
| App Company | **YES** - Information Management Service Provider | s.2(j) - "processes, stores, archives or destroys records of a trustee" |
| Hosting/Subprocessors | **YES** - Through IMSP provisions | s.18 - Information management service provider duties |

### 2.5 British Columbia - E-Health Act & PIPA

**Note:** BC E-Health Act applies to designated health information banks. General PHI for private sector entities is covered under PIPA (Personal Information Protection Act).

**Regulated Entities:**

| Entity | Regulated Under PIPA / E-Health Act? | Legal Basis |
|--------|------------------------------|-------------|
| Practitioner | **YES** - Organization under PIPA | PIPA s.1 "organization" includes a person carrying on business |
| App Company | **YES** - Organization under PIPA | PIPA s.1 - organization that collects, uses or discloses personal information |
| Hosting/Subprocessors | **YES** - Through PIPA provisions | PIPA s.34 - protection of personal information |

**PIPA Key Requirements:**
- **Consent:** PIPA s.6-8 - consent required for collection, use, disclosure; may be express or implicit
- **Collection:** PIPA s.10-11 - required notification, limitations on collection
- **Use:** PIPA s.14-16 - limitations on use, use without consent provisions
- **Disclosure:** PIPA s.17-22 - limitations, disclosure without consent, research purposes
- **Access Rights:** PIPA s.23-32 - individual's right to access and correct
- **Safeguards:** PIPA s.34 - protection of personal information
- **Retention:** PIPA s.35 - retention requirements

### 2.6 New Brunswick - PHIPAA

**Regulated Entities:**

| Entity | Regulated Under PHIPAA? | Legal Basis |
|--------|------------------------|-------------|
| Practitioner | **YES** - Custodian | s.1 "custodian" - individual or organization that collects, maintains or uses PHI for providing health care |
| App Company | **YES** - Agent or Information Manager | s.1 "agent" + "information manager" definitions |
| Hosting/Subprocessors | **YES** - As agents | s.52 - agents and information managers |

### 2.7 Prince Edward Island - HIA

**Regulated Entities:**

| Entity | Regulated Under PE HIA? | Legal Basis |
|--------|------------------------|-------------|
| Practitioner | **YES** - Custodian | s.1(e) - "health care provider, when not acting as an agent of a custodian" |
| App Company | **YES** - Agent or Information Manager | s.1(a) agent, s.1(q) information manager |
| Hosting/Subprocessors | **YES** - Through agent/IM provisions | s.41-43 - written agreements required |

### 2.8 Nova Scotia - PHIA

**Regulated Entities:**

| Entity | Regulated Under NS PHIA? | Legal Basis |
|--------|------------------------|-------------|
| Practitioner | **YES** - Custodian | s.3(d) - "a health care provider who operates a health care practice" |
| App Company | **YES** - Agent | s.3(a) - "agent" includes information manager acting on behalf of custodian |
| Hosting/Subprocessors | **YES** - Through agent provisions | s.28-29 - custodian's responsibility for agents |

**NS PHIA Key Sections:**
- **Consent:** s.11-20 - comprehensive consent framework with knowledgeable implied consent provisions
- **Substitute Decision-Maker:** s.21-23 - detailed SDM hierarchy
- **Collection:** s.30-32 - collection requirements
- **Use:** s.33-35 - use of PHI provisions
- **Disclosure:** s.36-41 - disclosure provisions including without consent
- **Security:** s.28 - custodian's responsibility for safeguards

### 2.9 Newfoundland & Labrador - PHIA

**Regulated Entities:**

| Entity | Regulated Under NL PHIA? | Legal Basis |
|--------|------------------------|-------------|
| Practitioner | **YES** - Custodian | s.4(1) - includes health care providers |
| App Company | **YES** - Agent or Information Manager | s.2(a) agent, s.22 information manager provisions |
| Hosting/Subprocessors | **YES** - Through information manager provisions | s.22 - information manager requirements |

**NL PHIA Key Sections:**
- **Consent:** Part III (s.23-28) - elements of consent, express/implied, withdrawal
- **Collection/Use/Disclosure:** Part IV (s.29-50) - comprehensive provisions
- **Access/Correction:** Part V (s.51-64) - individual's rights
- **Security:** s.15 - security requirements
- **Information Manager:** s.22 - written agreement requirements
- **Cross-Border:** s.47 - disclosure outside the province

### 2.10 Federal - PIPEDA

**Application Note:** PIPEDA applies to private sector organizations in provinces that have not enacted substantially similar provincial legislation. For health information:
- BC PIPA is deemed substantially similar
- Alberta PIPA (private sector) is deemed substantially similar  
- Quebec P-39.1 is deemed substantially similar
- Ontario PHIPA is deemed substantially similar for health custodians

**However, PIPEDA continues to apply:**
- To federally regulated organizations (banks, telecoms, interprovincial transport)
- To interprovincial and international transfers of personal information
- As a baseline where provincial legislation does not apply

**Key PIPEDA Provisions:**
- **Consent:** s.6.1 - valid consent requirements; Schedule 1 Principle 3
- **Breach Notification:** s.10.1-10.3 - mandatory breach notification to Commissioner and affected individuals
- **Accountability:** Schedule 1 Principle 1 - organization is responsible
- **Safeguards:** Schedule 1 Principle 7 - appropriate security safeguards

---

## 3. Harmonized National Baseline

The following baseline applies the **strictest common requirements** across all provinces with provided legislation.

### 3.1 Baseline Consent Requirements

| Requirement | Strictest Standard | Source |
|-------------|-------------------|--------|
| Consent must be knowledgeable | Individual must understand purpose and right to withhold | ON PHIPA s.18(5), NB PHIPAA s.17, NS PHIA s.12-13, PIPEDA Schedule 1 Principle 3 |
| Consent must not be obtained through deception/coercion | All provinces + federal | ON PHIPA s.18(1)(d), MB PHIA s.19.1, NL PHIA s.23, PIPEDA s.6.1 |
| Express consent required for disclosure to non-custodians | Cannot rely on implied consent | ON PHIPA s.18(3), BC PIPA s.6 |
| Consent withdrawal must be permitted | Non-retroactive effect | ON PHIPA s.19(1), MB PHIA s.19.2, SK HIPA s.7, NL PHIA s.28, BC PIPA s.9 |
| Record of consent must be maintained | Document consent obtained | AB HIA s.34, ON PHIPA s.16(2), NL PHIA Part III |

### 3.2 Baseline Collection Requirements

| Requirement | Strictest Standard | Source |
|-------------|-------------------|--------|
| Collect only what is necessary | Minimum necessary principle | ON PHIPA s.30(2), SK HIPA s.23, NS PHIA s.25, BC PIPA s.11, PIPEDA Schedule 1 Principle 4 |
| Direct collection from individual preferred | Unless authorized exception | MB PHIA s.14, SK HIPA s.25, NL PHIA s.30, NS PHIA s.31 |
| Provide notice of collection purposes | At time of collection | MB PHIA s.15, NB PHIPAA s.31, ON PHIPA s.16, BC PIPA s.10 |
| Collect for lawful purpose only | Must have authorized purpose | ON PHIPA s.29(a), SK HIPA s.24, NL PHIA s.29, PIPEDA Schedule 1 Principle 2 |

### 3.3 Baseline Security Requirements

| Requirement | Strictest Standard | Source |
|-------------|-------------------|--------|
| Administrative safeguards | Policies, procedures, training | MB PHIA s.18, ON PHIPA s.12(1), PE HIA s.39, NL PHIA s.13, BC PIPA s.34 |
| Technical safeguards | Encryption, access controls, audit logs | ON PHIPA s.10.1 (electronic audit log), SK HIPA s.16, AB HIA s.60, PIPEDA Schedule 1 Principle 7 |
| Physical safeguards | Secure storage, disposal | All provinces + PIPEDA |
| Reasonable steps against theft/loss/unauthorized access | Must take protective measures | ON PHIPA s.12(1), MB PHIA s.18, NL PHIA s.15, NS PHIA s.28, BC PIPA s.34 |

### 3.4 Baseline Breach Notification Requirements

| Requirement | Strictest Standard | Source |
|-------------|-------------------|--------|
| Notify affected individual | At first reasonable opportunity | ON PHIPA s.12(2), AB HIA s.60.1, NL PHIA s.20, PIPEDA s.10.1 |
| Notify regulator/Commissioner | When prescribed thresholds met | ON PHIPA s.12(3), AB HIA s.60.1, PIPEDA s.10.1(1) - real risk of significant harm |
| Include complaint rights in notice | Inform of right to complain | ON PHIPA s.12(2)(b), PIPEDA s.10.1(4) |
| Risk of harm assessment | Required before determining notification | AB HIA s.60.1, PIPEDA s.10.1 - "real risk of significant harm" test |
| Maintain breach records | Record keeping for breaches | PIPEDA s.10.3 - retain records for 24 months |

---

## 4. Compliance Gates by Province

### GATE G1: Data Mapping & Classification

**Legal Requirement (Plain Language):**  
Before collecting or processing PHI, you must identify and classify all personal health information in the system, understanding what data elements constitute PHI under each provincial act.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.4(1): Definition of personal health information
- PHIPA s.30(1-2): Collection limitation principles

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Create data dictionary mapping all fields to PHI categories | Document PHI classification policy |
| Tag database columns with PHI sensitivity levels | Train staff on PHI identification |
| Implement data flow diagrams showing PHI movement | Annual review of data classification |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G1-ON Data Mapping and Classification

  Scenario: All PHI fields are identified and classified
    Given the application collects user data
    When I review the data dictionary
    Then every field containing information relating to physical or mental health SHALL be tagged as "PHI-Health"
    And every field containing information relating to health care provision SHALL be tagged as "PHI-Care"
    And every field containing health numbers SHALL be tagged as "PHI-HealthNumber"
    And the classification SHALL reference PHIPA s.4(1)

  Scenario: Data flow documentation exists
    Given PHI is processed by the application
    When I request data flow documentation
    Then a diagram SHALL exist showing all PHI collection points
    And a diagram SHALL exist showing all PHI storage locations
    And a diagram SHALL exist showing all PHI disclosure paths
    And each flow SHALL indicate the legal authority (consent or statutory)

  Scenario: Non-PHI data is segregated
    Given the application processes both PHI and non-PHI data
    When data is stored
    Then PHI SHALL be logically or physically segregated from non-PHI
    And segregation boundaries SHALL be documented
```

**Evidence Artifacts:**
- [ ] Data dictionary with PHI tags
- [ ] Data flow diagrams
- [ ] PHI classification policy document
- [ ] Training records

**Risk Level:** HIGH  
**Rationale:** Failure to properly classify PHI can result in unauthorized disclosures and regulatory violations.

---

### GATE G2: Lawful Authority / Consent

**Legal Requirement (Plain Language):**  
You must obtain valid consent before collecting, using, or disclosing PHI, unless a statutory exception applies. Consent must be knowledgeable, not obtained through deception, and the individual must be able to withdraw it.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.18: Elements of consent
- PHIPA s.19: Withdrawal of consent
- PHIPA s.20: Assumption of validity / implied consent
- PHIPA s.29: Requirement for consent

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Consent capture UI with clear purpose statement | Consent policy document |
| Consent withdrawal mechanism | Staff training on consent validity |
| Consent versioning and audit trail | Consent form review process |
| Timestamp all consent events (UTC) | Record retention for consent records |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G2-ON Consent Management

  Scenario: Patient provides knowledgeable consent
    Given a patient is registering for the app
    When the consent screen is displayed
    Then the screen SHALL clearly state the purposes of collection per PHIPA s.18(5)
    And the screen SHALL state the patient may give or withhold consent
    And consent SHALL NOT be pre-checked or assumed
    And the consent language SHALL be in plain language readable at grade 8 level

  Scenario: Express consent for sharing with practitioner
    Given a patient wants to share log entries with their practitioner
    When the sharing feature is accessed
    Then express consent SHALL be obtained per PHIPA s.18(3)
    And the consent SHALL specify which practitioner receives the data
    And the consent SHALL specify what information is shared
    And a record of consent SHALL be stored with timestamp

  Scenario: Patient withdraws consent
    Given a patient has previously consented to data sharing
    When the patient accesses privacy settings
    Then a clear "Withdraw Consent" option SHALL be available
    And upon withdrawal, the system SHALL stop future disclosures immediately
    And the system SHALL NOT retroactively delete already-shared information per PHIPA s.19(1)
    And a record of withdrawal SHALL be stored with timestamp

  Scenario: Consent record integrity
    Given consent has been obtained
    When the consent record is examined
    Then it SHALL include: individual identifier, timestamp (UTC), version of consent text, method of consent
    And the record SHALL be immutable (append-only)
    And the record SHALL be retained for the prescribed period
```

#### Alberta (HIA)

**Source References:**
- HIA s.34: Consent required for disclosure
- HIA s.35-40: Exceptions to consent requirement
- HIA Guidelines Chapter 8: Disclosure

**Additional Requirements for Alberta:**

```gherkin
  Scenario: Consent distinguishes registration vs diagnostic/treatment info
    Given Alberta HIA applies
    When consent is obtained
    Then the consent SHALL distinguish between "registration information" and "diagnostic, treatment and care information"
    And separate consent MAY be obtained for each category per HIA structure
```

#### Manitoba (PHIA)

**Source References:**
- PHIA s.19.1: Elements of consent
- PHIA s.19.2: Consent may be withdrawn
- PHIA s.22: Restrictions on disclosure (consent of individual)

**Acceptance Criteria (BDD):**

```gherkin
Feature: G2-MB Consent Management

  Scenario: Consent meets Manitoba requirements
    Given Manitoba PHIA applies
    When consent is obtained
    Then consent SHALL relate to the information per PHIA s.19.1(a)
    And consent SHALL relate to the purpose per PHIA s.19.1(b)
    And consent SHALL be given by individual or authorized person per PHIA s.19.1(c)
    And consent SHALL be informed per PHIA s.19.1(d)
    And consent SHALL be given voluntarily per PHIA s.19.1(e)
    And consent SHALL NOT be obtained through misrepresentation per PHIA s.19.1(f)
```

**Evidence Artifacts:**
- [ ] Consent UI screenshots
- [ ] Consent text versions (all)
- [ ] Consent withdrawal UI screenshots
- [ ] Consent database schema showing audit fields
- [ ] Sample consent records
- [ ] Consent policy document

**Risk Level:** HIGH  
**Rationale:** Invalid consent undermines legal authority for all data processing.

---

### GATE G3: Collection Limitation & Purpose Specification

**Legal Requirement (Plain Language):**  
Collect only the minimum PHI necessary for the specified purpose. Do not collect more than needed. Document and communicate the purposes.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.29: Collection only for lawful purpose with consent
- PHIPA s.30(1): Do not collect PHI if other information will serve the purpose
- PHIPA s.30(2): Do not collect more than reasonably necessary
- PHIPA s.36: Indirect collection restrictions

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Field-level necessity review for all forms | Purpose specification document |
| Optional vs mandatory field distinction | Data minimization review process |
| Block collection of unnecessary fields | Staff training on minimum necessary |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G3-ON Collection Limitation

  Scenario: Only necessary fields are collected
    Given the mood log form is designed
    When a product manager reviews the form
    Then every field SHALL have documented necessity justification
    And fields not necessary for the stated purpose SHALL be removed or made optional
    And optional fields SHALL be clearly marked as optional

  Scenario: Purpose is specified at collection
    Given a patient submits a mood log entry
    When the entry is collected
    Then the patient SHALL have been informed of the purpose (providing mental health support)
    And the purpose SHALL be recorded with the data

  Scenario: No collection of unnecessary PHI
    Given the app collects PHI
    When I audit the data schema
    Then fields like social insurance number SHALL NOT be collected
    And fields like financial information (unless required for care) SHALL NOT be collected
    And each collected field SHALL map to a defined purpose
```

#### Saskatchewan (HIPA)

**Source References:**
- HIPA s.23: Collection, use and disclosure on need-to-know basis
- HIPA s.24: Restrictions on collection
- HIPA s.25: Manner of collection

**Acceptance Criteria (BDD):**

```gherkin
Feature: G3-SK Collection Limitation

  Scenario: Need-to-know collection
    Given Saskatchewan HIPA applies
    When PHI is collected
    Then collection SHALL be limited to what is reasonably necessary per HIPA s.23
    And direct collection from individual SHALL be preferred per HIPA s.25

  Scenario: Collection notice provided
    Given PHI is collected directly from the individual
    When collection occurs
    Then the individual SHALL be informed of the purpose per HIPA s.9
    And the individual SHALL be informed of any consequences of refusal
```

**Evidence Artifacts:**
- [ ] Data necessity justification matrix
- [ ] Collection notice/privacy statement
- [ ] Form designs showing optional vs mandatory
- [ ] Purpose specification document

**Risk Level:** MEDIUM  
**Rationale:** Over-collection increases breach risk and regulatory exposure.

---

### GATE G4: Use & Disclosure Controls

**Legal Requirement (Plain Language):**  
PHI may only be used for the purpose for which it was collected (or compatible purposes). Disclosure requires consent or statutory authority. Patient-directed sharing must be honored. Minimum necessary principle applies.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.29: Requirement for consent
- PHIPA s.30: Minimum necessary
- PHIPA s.31: Cannot use/disclose if collected in contravention
- PHIPA s.37: Permitted use
- PHIPA s.38: Disclosures related to providing health care
- PHIPA s.50: Disclosure outside Ontario

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Role-based access control (RBAC) | Access control policy |
| Purpose-of-access logging | Disclosure logging procedure |
| Patient sharing controls (granular) | Staff training on authorized disclosures |
| Practitioner access audit | Disclosure review process |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G4-ON Use and Disclosure Controls

  Scenario: Practitioner access is limited to their patients
    Given a practitioner is logged into the portal
    When they search for patient records
    Then they SHALL only see patients who have consented to share with them
    And access attempts to other patients SHALL be denied
    And denied access attempts SHALL be logged

  Scenario: Patient controls what is shared
    Given a patient wants to share with their practitioner
    When accessing sharing settings
    Then the patient SHALL be able to select which log types to share
    And the patient SHALL be able to select date ranges
    And the patient SHALL be able to revoke sharing at any time

  Scenario: Use is limited to purpose
    Given PHI was collected for providing mental health care
    When the PHI is used
    Then it SHALL only be used for providing mental health care per PHIPA s.37
    And it SHALL NOT be used for marketing per PHIPA s.33
    And it SHALL NOT be used for fundraising without express consent per PHIPA s.32

  Scenario: Disclosure outside Ontario
    Given a practitioner is located outside Ontario
    When the patient shares PHI with them
    Then the system SHALL assess whether disclosure outside Ontario is permitted per PHIPA s.50
    And consent SHALL be explicit for cross-border disclosure
    And the receiving jurisdiction SHALL provide comparable protection
```

#### Alberta (HIA)

**Source References:**
- HIA s.27: Authorized purposes for use
- HIA s.34-40: Disclosure provisions
- HIA s.57-58: Least amount of information, highest degree of anonymity

**Acceptance Criteria (BDD):**

```gherkin
Feature: G4-AB Use and Disclosure Controls

  Scenario: Minimum necessary and maximum anonymity
    Given Alberta HIA applies
    When PHI is used or disclosed
    Then only the least amount of information necessary SHALL be used per HIA s.57
    And the highest degree of anonymity possible SHALL be maintained per HIA s.58

  Scenario: Disclosure requires consent or exception
    Given PHI is to be disclosed
    When no consent has been obtained
    Then disclosure SHALL only occur if an exception in HIA s.35-40 applies
    And the specific exception SHALL be documented
```

**Evidence Artifacts:**
- [ ] RBAC configuration documentation
- [ ] Access control matrix
- [ ] Patient sharing UI screenshots
- [ ] Disclosure log samples
- [ ] Cross-border disclosure assessment template

**Risk Level:** HIGH  
**Rationale:** Unauthorized disclosure is a primary compliance violation risk.

---

### GATE G5: Patient Rights (Access, Correction, Accounting)

**Legal Requirement (Plain Language):**  
Patients have the right to access their PHI, request corrections, and in some jurisdictions, receive an accounting of disclosures made without consent.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.52: Individual's right of access
- PHIPA s.53: Request for access
- PHIPA s.54: Response of health information custodian
- PHIPA s.55: Correction
- PHIPA s.16(2): Notation of disclosures outside information practices

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Patient data export feature | Access request procedure |
| Correction request workflow | Response timeline tracking (30 days) |
| Disclosure log viewable by patient | Correction decision documentation |
| Audit trail of all access | Fee schedule (if applicable) |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G5-ON Patient Rights

  Scenario: Patient accesses their PHI
    Given a patient wants to access their information
    When they navigate to their profile/data section
    Then they SHALL be able to view all their log entries
    And they SHALL be able to view their account information
    And they SHALL be able to export their data in a readable format

  Scenario: Patient requests correction
    Given a patient believes their information is inaccurate
    When they submit a correction request
    Then the system SHALL acknowledge receipt
    And the custodian SHALL respond within 30 days per PHIPA s.55
    And if granted, the correction SHALL be made and linked records notified
    And if denied, the patient's statement of disagreement SHALL be attached

  Scenario: Patient views disclosure log
    Given disclosures without consent have occurred
    When the patient accesses their disclosure history
    Then they SHALL see a record of disclosures made without consent per PHIPA s.16(2)
    And each record SHALL include: date, recipient type, purpose
```

#### Manitoba (PHIA)

**Source References:**
- PHIA s.5: Right to examine and copy health information
- PHIA s.6-7: Trustee response requirements
- PHIA s.12: Correction of health information

**Acceptance Criteria (BDD):**

```gherkin
Feature: G5-MB Patient Rights

  Scenario: Access request response time
    Given Manitoba PHIA applies
    When a patient requests access to their PHI
    Then the trustee SHALL respond within 30 days per PHIA s.6
    And an extension of up to 30 additional days MAY be taken with notice per PHIA s.7
```

**Evidence Artifacts:**
- [ ] Patient data access UI screenshots
- [ ] Data export sample
- [ ] Correction request workflow documentation
- [ ] Disclosure log UI screenshots
- [ ] Response time tracking reports

**Risk Level:** MEDIUM  
**Rationale:** Patient rights are fundamental; failure results in complaints to Commissioner.

---

### GATE G6: Safeguards (Administrative, Technical, Physical)

**Legal Requirement (Plain Language):**  
Take reasonable steps to protect PHI against theft, loss, unauthorized use or disclosure, and unauthorized copying, modification, or disposal.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.12(1): Security measures required
- PHIPA s.10: Information practices
- PHIPA s.10.1: Electronic audit log (when in force)
- PHIPA s.13: Handling of records

**Implementation Requirements:**

| Administrative | Technical | Physical |
|---------------|-----------|----------|
| Information security policy | Encryption at rest (AES-256) | Secure data centers |
| Staff training program | Encryption in transit (TLS 1.2+) | Access controls to facilities |
| Background checks | Multi-factor authentication | Visitor logs |
| Incident response plan | Role-based access control | Device security |
| Vendor management policy | Intrusion detection/prevention | Media disposal procedures |
| Privacy impact assessments | Audit logging | |
| | Vulnerability scanning | |
| | Secure coding practices | |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G6-ON Security Safeguards

  Scenario: Encryption at rest
    Given PHI is stored in the database
    When the storage is examined
    Then all PHI fields SHALL be encrypted using AES-256 or equivalent
    And encryption keys SHALL be managed securely (HSM or equivalent)
    And key rotation SHALL occur at least annually

  Scenario: Encryption in transit
    Given PHI is transmitted between components
    When transmission occurs
    Then TLS 1.2 or higher SHALL be used
    And weak cipher suites SHALL be disabled
    And certificate validity SHALL be verified

  Scenario: Access control
    Given users access the system
    When authentication occurs
    Then multi-factor authentication SHALL be required for practitioners
    And session timeouts SHALL be enforced (max 30 minutes idle)
    And failed login attempts SHALL trigger lockout after 5 attempts

  Scenario: Electronic audit log per PHIPA s.10.1
    Given PHI records are accessed electronically
    When any access, modification, or handling occurs
    Then an audit log entry SHALL be created
    And the entry SHALL include: timestamp, user identity, action, record identifier, individual identifier
    And logs SHALL be immutable (append-only)
    And logs SHALL be retained for prescribed period
    And logs SHALL be available to Commissioner upon request

  Scenario: Vulnerability management
    Given the application is in production
    When security scanning occurs
    Then vulnerability scans SHALL run at least monthly
    And critical vulnerabilities SHALL be remediated within 72 hours
    And high vulnerabilities SHALL be remediated within 30 days
```

#### Manitoba (PHIA)

**Source References:**
- PHIA s.18: Duty to establish security safeguards
- PHIA s.19: Safeguards for sensitive information

**Acceptance Criteria (BDD):**

```gherkin
Feature: G6-MB Security Safeguards

  Scenario: Reasonable security safeguards
    Given Manitoba PHIA applies
    When security controls are implemented
    Then administrative safeguards SHALL protect against unauthorized access per PHIA s.18
    And technical safeguards SHALL protect against unauthorized access per PHIA s.18
    And physical safeguards SHALL protect against unauthorized access per PHIA s.18

  Scenario: Sensitive information safeguards
    Given mental health information is particularly sensitive
    When such information is handled
    Then additional safeguards SHALL be applied per PHIA s.19
    And access SHALL be limited to minimum necessary personnel
```

**Evidence Artifacts:**
- [ ] Security policy document
- [ ] Encryption configuration evidence
- [ ] Penetration test reports
- [ ] Vulnerability scan reports
- [ ] Audit log samples
- [ ] MFA configuration evidence
- [ ] Training completion records
- [ ] SOC 2 Type II report (if available)

**Risk Level:** HIGH  
**Rationale:** Security breaches result in harm to individuals and significant penalties.

---

### GATE G7: Breach & Incident Response

**Legal Requirement (Plain Language):**  
If PHI is stolen, lost, or subject to unauthorized access or disclosure, notify affected individuals and the Commissioner/regulator according to statutory requirements.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.12(2): Notice to individual of theft, loss, unauthorized use/disclosure
- PHIPA s.12(3): Notice to Commissioner when prescribed requirements met
- PHIPA s.17(4)(b): Agent must notify custodian of breach

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Breach detection capabilities | Incident response plan |
| Incident ticketing system | Notification templates |
| Communication channels for notification | Escalation procedures |
| Forensic investigation tools | Regulatory reporting procedures |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G7-ON Breach Response

  Scenario: Breach detected and contained
    Given a potential breach is identified
    When the incident response plan is activated
    Then the breach SHALL be contained within 4 hours of detection
    And affected systems SHALL be isolated
    And evidence SHALL be preserved for investigation

  Scenario: Individual notification
    Given a breach involving PHI has occurred
    When notification requirements are assessed
    Then affected individuals SHALL be notified at first reasonable opportunity per PHIPA s.12(2)(a)
    And notification SHALL include: description of breach, date/time, types of PHI affected
    And notification SHALL include statement of right to complain to Commissioner per PHIPA s.12(2)(b)

  Scenario: Commissioner notification
    Given a breach meets prescribed thresholds
    When notification is sent
    Then the Commissioner SHALL be notified per PHIPA s.12(3)
    And notification SHALL be sent within prescribed timeframe
    And notification SHALL include prescribed content

  Scenario: Agent notifies custodian
    Given the app company (as agent) detects a breach
    When the breach is confirmed
    Then the custodian (practitioner) SHALL be notified at first reasonable opportunity per PHIPA s.17(4)(b)
    And the notification SHALL include all relevant details
```

#### Alberta (HIA)

**Source References:**
- HIA s.60.1: Duty to notify
- HIA Chapter 14 Guidelines: Duty to Notify detailed procedures

**Acceptance Criteria (BDD):**

```gherkin
Feature: G7-AB Breach Response

  Scenario: Risk of harm assessment
    Given Alberta HIA applies and a breach has occurred
    When the custodian assesses the breach
    Then a risk of harm assessment SHALL be conducted per HIA s.60.1
    And factors per HIA Chapter 14 SHALL be considered
    And the assessment SHALL be documented

  Scenario: Notification required if risk of harm exists
    Given a risk of harm assessment determines notification is required
    When notification is prepared
    Then the Commissioner SHALL be notified per HIA s.60.1
    And the Minister of Health SHALL be notified per HIA s.60.1
    And affected individuals SHALL be notified per HIA s.60.1
    And notification SHALL be made "as soon as practicable"

  Scenario: Affiliate duty to notify custodian
    Given an affiliate (app company) detects a breach
    When the breach is confirmed
    Then the affiliate SHALL notify the custodian as soon as practicable per HIA s.60.1
    And notification SHALL be in accordance with regulations (HIA Regulation s.8.2)
```

**Evidence Artifacts:**
- [ ] Incident response plan document
- [ ] Breach notification templates
- [ ] Risk of harm assessment template (AB)
- [ ] Incident log samples
- [ ] Commissioner notification template
- [ ] Tabletop exercise records

**Risk Level:** HIGH  
**Rationale:** Breach response failures result in penalties and loss of trust.

---

### GATE G8: Retention, Destruction, and Record-Keeping

**Legal Requirement (Plain Language):**  
Retain records of PHI for the prescribed period and dispose of them securely when retention requirements expire.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.13(1): Secure retention, transfer, disposal
- PHIPA s.13(2): Retention during access request

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Automated retention tagging | Retention schedule document |
| Secure deletion procedures | Destruction certification |
| Backup retention alignment | Record-keeping policy |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G8-ON Retention and Destruction

  Scenario: Retention period applied
    Given PHI records are created
    When retention is determined
    Then records SHALL be retained for the prescribed period (typically 10 years for health records in ON)
    And retention SHALL be measured from last contact/service date
    And retention period SHALL be documented per record type

  Scenario: Secure destruction
    Given the retention period has expired
    When destruction is authorized
    Then electronic records SHALL be securely deleted using approved methods (e.g., cryptographic erasure)
    And deletion SHALL be verified
    And a certificate of destruction SHALL be issued

  Scenario: No destruction during access request
    Given an access request is pending per PHIPA s.53
    When the retention period would otherwise expire
    Then the record SHALL NOT be destroyed per PHIPA s.13(2)
    And retention SHALL continue until recourse is exhausted
```

#### Saskatchewan (HIPA)

**Source References:**
- HIPA s.17: Retention and destruction policy required

**Acceptance Criteria (BDD):**

```gherkin
Feature: G8-SK Retention and Destruction

  Scenario: Retention policy exists
    Given Saskatchewan HIPA applies
    When the trustee's policies are examined
    Then a written retention and destruction policy SHALL exist per HIPA s.17
    And the policy SHALL specify retention periods by record type
    And the policy SHALL specify destruction methods
```

**Evidence Artifacts:**
- [ ] Retention schedule document
- [ ] Retention policy document
- [ ] Destruction procedure document
- [ ] Certificates of destruction (samples)
- [ ] Backup retention alignment evidence

**Risk Level:** MEDIUM  
**Rationale:** Improper retention or destruction exposes unnecessary risk.

---

### GATE G9: Third Parties & Service Providers

**Legal Requirement (Plain Language):**  
Written agreements must govern relationships with agents, information managers, and service providers who access PHI. The custodian remains responsible.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.17: Agents and information
- PHIPA s.10(4): Providers to custodians using electronic means

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Vendor inventory | Data processing agreements |
| Vendor access controls | Vendor due diligence procedure |
| Vendor audit capabilities | Annual vendor review |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G9-ON Third Party Management

  Scenario: Agent relationship documented
    Given the app company acts as agent for practitioners
    When the relationship is established
    Then a written agreement SHALL exist per PHIPA s.17
    And the agreement SHALL specify permitted uses and disclosures
    And the agreement SHALL require compliance with PHIPA
    And the agreement SHALL require breach notification

  Scenario: Custodian remains responsible
    Given agents process PHI on behalf of custodian
    When a compliance issue arises
    Then the custodian remains responsible per PHIPA s.17(3)(b)
    And the custodian SHALL take reasonable steps to ensure agent compliance per PHIPA s.17(3)(a)

  Scenario: Sub-processor agreements
    Given the app company uses cloud hosting providers
    When such relationships exist
    Then written agreements SHALL govern PHI handling
    And sub-processors SHALL be disclosed to custodians
    And sub-processors SHALL meet same security requirements
```

#### Saskatchewan (HIPA)

**Source References:**
- HIPA s.18: Information management service provider requirements

**Acceptance Criteria (BDD):**

```gherkin
Feature: G9-SK Third Party Management

  Scenario: IMSP agreement required
    Given the app company is an Information Management Service Provider per HIPA s.2(j)
    When PHI is processed
    Then a written agreement SHALL exist per HIPA s.18
    And the agreement SHALL specify permitted purposes
    And the agreement SHALL require confidentiality
    And the agreement SHALL require security safeguards
    And the agreement SHALL require breach notification to trustee
```

#### Prince Edward Island (HIA)

**Source References:**
- PE HIA s.41: Written agreement with agent of custodian
- PE HIA s.42: Provision of PHI to information manager
- PE HIA s.43: Requirement to comply

**Acceptance Criteria (BDD):**

```gherkin
Feature: G9-PE Third Party Management

  Scenario: Agent agreement requirements
    Given PEI HIA applies
    When an agent relationship is established
    Then a written agreement SHALL exist per PE HIA s.41
    And the agreement SHALL restrict PHI use to purposes specified
    And the agreement SHALL require security safeguards
    And the agreement SHALL require notification of privacy breaches

  Scenario: Information manager agreement
    Given the app company acts as information manager
    When PHI is provided to the information manager
    Then requirements of PE HIA s.42 SHALL be met
    And confidentiality requirements SHALL be specified
    And the custodian's instructions SHALL be documented
```

**Evidence Artifacts:**
- [ ] Data processing agreement templates
- [ ] Executed agreements with all vendors
- [ ] Vendor inventory
- [ ] Vendor security assessments
- [ ] Sub-processor list

**Risk Level:** HIGH  
**Rationale:** Third-party breaches are attributed to the custodian.

---

### GATE G10: Cross-Border Transfers / Storage

**Legal Requirement (Plain Language):**  
If PHI is stored or disclosed outside the province or Canada, specific requirements apply.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.50: Disclosure outside Ontario

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Data residency configuration | Cross-border transfer assessment |
| Geo-fencing capabilities | Consent for cross-border disclosure |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G10-ON Cross-Border

  Scenario: Data residency documented
    Given the application stores PHI
    When data center locations are examined
    Then all primary PHI storage locations SHALL be documented
    And Canadian data residency SHALL be preferred
    And any non-Canadian storage SHALL trigger cross-border assessment

  Scenario: Disclosure outside Ontario with consent
    Given PHI will be disclosed to a recipient outside Ontario
    When the disclosure occurs
    Then consent SHALL be obtained per PHIPA s.50(1)(e)
    And the individual SHALL be informed of the risks
```

#### Prince Edward Island (HIA)

**Source References:**
- PE HIA s.35: Disclosure outside province

**Acceptance Criteria (BDD):**

```gherkin
Feature: G10-PE Cross-Border

  Scenario: Disclosure outside PEI
    Given PHI will be disclosed outside Prince Edward Island
    When disclosure requirements are assessed
    Then requirements of PE HIA s.35 SHALL be met
    And comparable protection SHALL be ensured
```

**Evidence Artifacts:**
- [ ] Data residency documentation
- [ ] Cross-border transfer impact assessment
- [ ] Consent records for cross-border disclosure

**Risk Level:** MEDIUM  
**Rationale:** Cross-border issues add jurisdictional complexity.

---

### GATE G11: De-identification / Anonymization

**Legal Requirement (Plain Language):**  
When de-identified information will serve the purpose, use de-identified rather than identifiable PHI. Re-identification is generally prohibited.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.2: Definition of "de-identify"
- PHIPA s.11.2: Limits on use of de-identified information

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| De-identification algorithms | De-identification policy |
| Re-identification risk assessment | Analytics data handling procedures |
| Segregated analytics databases | |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G11-ON De-identification

  Scenario: De-identification method
    Given PHI needs to be de-identified
    When de-identification is performed
    Then all direct identifiers SHALL be removed per PHIPA s.2 "de-identify"
    And indirect identifiers SHALL be assessed for re-identification risk
    And the method SHALL be documented

  Scenario: Re-identification prohibited
    Given de-identified information exists
    When the information is used
    Then no person SHALL attempt to re-identify individuals per PHIPA s.11.2(1)
    And exceptions per PHIPA s.11.2(2) SHALL be documented if applicable

  Scenario: Analytics uses de-identified data
    Given the application performs analytics
    When analytics data is processed
    Then de-identified or aggregate data SHALL be used where possible
    And identifiable PHI SHALL NOT be used for analytics without specific authorization
```

**Evidence Artifacts:**
- [ ] De-identification methodology document
- [ ] Re-identification risk assessment
- [ ] Analytics data flow documentation

**Risk Level:** LOW-MEDIUM  
**Rationale:** Proper de-identification reduces compliance burden.

---

### GATE G12: Minors / Capacity / Substitute Decision-Makers

**Legal Requirement (Plain Language):**  
Special rules apply when the individual is a minor or lacks capacity. Substitute decision-makers may consent on behalf of incapable individuals.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.21: Capacity to consent
- PHIPA s.22: Determination of incapacity
- PHIPA s.23: Persons who may consent (including minors under 16)
- PHIPA s.26: Incapable individual - persons who may consent

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Age verification at registration | Minor consent policy |
| Substitute decision-maker workflow | Capacity assessment guidelines |
| Parental/guardian access controls | SDM verification procedure |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G12-ON Minors and Capacity

  Scenario: Minor under 16 - parent may consent
    Given a user is under 16 years of age
    When consent is required
    Then a parent or guardian MAY consent per PHIPA s.23(1)2
    EXCEPT where the information relates to treatment the child decided on their own per PHIPA s.23(1)2(i)
    And the app SHALL implement age verification

  Scenario: Capable minor's decision prevails
    Given a minor under 16 is capable of consenting
    When the minor and parent disagree
    Then the minor's decision SHALL prevail per PHIPA s.23(3)

  Scenario: Substitute decision-maker for incapable adult
    Given an adult user lacks capacity to consent
    When consent is required
    Then a substitute decision-maker per PHIPA s.26 hierarchy SHALL consent
    And SDM identity SHALL be verified
    And SDM SHALL consider the individual's wishes per PHIPA s.24

  Scenario: Presumption of capacity
    Given an individual uses the app
    When capacity is assessed
    Then the individual SHALL be presumed capable per PHIPA s.21(4)
    And capacity challenges require reasonable grounds per PHIPA s.21(5)
```

**Evidence Artifacts:**
- [ ] Minor consent workflow documentation
- [ ] SDM verification procedures
- [ ] Age verification implementation evidence

**Risk Level:** MEDIUM  
**Rationale:** Mental health apps often serve minors; proper handling is essential.

---

### GATE G13: Research / Secondary Use

**Legal Requirement (Plain Language):**  
Research use of PHI requires ethics board approval and specific safeguards. Block research use by default.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.44: Disclosure for research

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Research data access controls | Research request procedure |
| De-identification for research | Ethics board approval verification |
| Research audit logging | Research agreement template |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G13-ON Research Use

  Scenario: Research use blocked by default
    Given PHI is collected for care purposes
    When research access is requested
    Then access SHALL be denied by default
    And research use SHALL require explicit authorization pathway

  Scenario: Research disclosure requirements
    Given research access is authorized
    When disclosure occurs per PHIPA s.44
    Then research ethics board approval SHALL be verified
    And a written research agreement SHALL exist
    And the researcher SHALL agree to conditions per PHIPA s.44
    And de-identified data SHALL be used where possible
```

**Evidence Artifacts:**
- [ ] Research data policy
- [ ] Research request procedure
- [ ] Ethics board approval verification process
- [ ] Research agreement template

**Risk Level:** LOW (if research not conducted)  
**Rationale:** Research is a specialized use case with strict requirements.

---

### GATE G14: Marketing / Non-care Use Prohibitions

**Legal Requirement (Plain Language):**  
Marketing and fundraising use of PHI is restricted and requires express consent.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.32: Fundraising - requires consent
- PHIPA s.33: Marketing - requires express consent

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Marketing preference controls | Marketing consent policy |
| Separate marketing consent flag | Opt-out mechanisms |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G14-ON Marketing Prohibitions

  Scenario: No marketing without express consent
    Given PHI is in the system
    When marketing communications are considered
    Then PHI SHALL NOT be used for marketing without express consent per PHIPA s.33
    And marketing consent SHALL be separate from care consent
    And users SHALL be able to opt out at any time

  Scenario: Fundraising restrictions
    Given the custodian considers fundraising activities
    When PHI use for fundraising is considered
    Then express consent OR implied consent with limited info per PHIPA s.32 SHALL be required
    And fundraising SHALL comply with prescribed requirements
```

**Evidence Artifacts:**
- [ ] Marketing consent mechanism
- [ ] Marketing opt-out evidence
- [ ] Policy prohibiting unauthorized marketing use

**Risk Level:** LOW  
**Rationale:** Marketing is not a primary use case for this app.

---

### GATE G15: Logging, Monitoring, and Auditability

**Legal Requirement (Plain Language):**  
Maintain records of PHI access and processing for accountability.

#### Ontario (PHIPA)

**Source References:**
- PHIPA s.10.1: Electronic audit log (when in force)
- PHIPA s.16(2): Notation of disclosures outside information practices

**Implementation Requirements:**

| Technical | Policy/Ops |
|-----------|------------|
| Comprehensive audit logging | Log review procedures |
| Log integrity protection | Anomaly investigation process |
| Log retention | Commissioner access procedures |
| SIEM integration | |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G15-ON Logging and Auditability

  Scenario: Comprehensive audit logging
    Given PHI is accessed or processed
    When any access, modification, or disclosure occurs
    Then an audit log entry SHALL be created
    And the entry SHALL include: timestamp (UTC), user/system identity, action type, record identifier, success/failure
    And logs SHALL be protected from tampering
    And logs SHALL be retained for at least 10 years

  Scenario: Audit log monitoring
    Given audit logs are collected
    When monitoring occurs
    Then logs SHALL be reviewed regularly (at least weekly)
    And anomalous access patterns SHALL trigger alerts
    And alerts SHALL be investigated within 24 hours

  Scenario: Commissioner access to logs
    Given the Commissioner requests audit logs
    When the request is received
    Then logs SHALL be provided per PHIPA s.10.1(2)
    And provision SHALL occur within prescribed timeframe

  Scenario: Disclosure tracking
    Given a disclosure without consent occurs
    When the disclosure is made
    Then a notation SHALL be made per PHIPA s.16(2)
    And the notation SHALL be available to the individual
```

**Evidence Artifacts:**
- [ ] Audit log schema documentation
- [ ] Log samples
- [ ] Log monitoring procedures
- [ ] Anomaly investigation records
- [ ] Log retention evidence

**Risk Level:** MEDIUM  
**Rationale:** Logging enables accountability and incident investigation.

---

### GATE G16: Practitioner Credentialing & Verification ⭐ NEW

**Legal Requirement (Plain Language):**  
Before practitioners can access patient PHI, their professional credentials must be verified to confirm they qualify as "custodians" (or equivalent) under provincial health information legislation. The "Agent of Custodian" model that allows the app company to process PHI depends entirely on practitioners being licensed healthcare providers.

**Risk Level:** 🔴 CRITICAL  
**Rationale:** Without verification, unauthorized individuals may pose as practitioners and gain access to PHI. This breaks the legal authority chain, exposes the company to unauthorized disclosure liability, and invalidates the "agent" defense.

#### Multi-Provincial

**Source References:**
- ON PHIPA s.3(1): Definition of "health information custodian"
- ON PHIPA s.17: Agent must act on behalf of custodian
- AB HIA s.1(1)(f): Definition of "custodian"
- SK HIPA s.2(t): Definition of "trustee"
- MB PHIA s.1: Definition of "trustee"
- BC E-Health Act s.1: Definition of health care body

**Implementation Requirements:**

| Technical | Operational | Policy |
|-----------|-------------|--------|
| Practitioner registration captures: full name, license number, licensing body, province | Manual verification workflow: operator checks public registry | Practitioner Verification Policy document |
| verification_status field: 'pending' \| 'verified' \| 'rejected' \| 'suspended' | Verification SLA: 2 business days | Acceptable evidence types documented |
| PHI API endpoints check verification_status before returning data | Re-verification: annual | Rejection/suspension criteria |
| Verification log table (immutable) | Verification tracking (spreadsheet for MVP) | Appeal process |
| Invite code system for patient onboarding (recommended) | | |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G16 Practitioner Credentialing & Verification

  Scenario: New practitioner cannot access PHI until verified
    Given a practitioner registers for the portal
    When they attempt to view patient entries
    Then the system SHALL return HTTP 403 with message "Account pending verification"
    And the practitioner SHALL see status "Pending Verification" in their dashboard
    And an audit log entry SHALL record the denied access attempt

  Scenario: Verification captures required evidence
    Given an operator verifies a practitioner
    When verification is performed
    Then the operator SHALL confirm license number against public registry
    And the verification log SHALL record: practitioner_id, verifier_id, timestamp_utc, evidence_type, registry_checked, decision
    And the practitioner's verification_status SHALL change to "verified"

  Scenario: Verified practitioner can access consented patient PHI
    Given a practitioner has verification_status = "verified"
    When they query a patient's entries
    Then the system SHALL check consent relationship
    And if consent exists, entries SHALL be returned
    And if no consent, HTTP 403 SHALL be returned

  Scenario: Suspended practitioner loses PHI access
    Given a practitioner's verification_status changes to "suspended"
    When they attempt to access PHI
    Then the system SHALL return HTTP 403
    And existing sessions SHALL be terminated
    And the practitioner SHALL be notified via email

  Scenario: Invite-only patient onboarding (recommended)
    Given the "Prescription" architecture is enabled
    When a patient attempts to register
    Then registration SHALL require a valid invite code
    And the invite code SHALL link the patient to the issuing practitioner
    And invite codes SHALL expire after 7 days or single use
```

**Provincial Registry URLs for Verification:**

| Province | Registry URL |
|----------|--------------|
| Ontario | https://doctors.cpso.on.ca/ |
| Alberta | https://search.cpsa.ca/ |
| British Columbia | https://www.cpsbc.ca/public/registrant-directory |
| Saskatchewan | https://www.cps.sk.ca/imis/CPSS/Registry/CPSS/Registry.aspx |
| Manitoba | https://cpsm.mb.ca/member-search |
| New Brunswick | https://cpsnb.org/en/physician-search |
| Nova Scotia | https://cpsns.ns.ca/physician-search/ |
| Prince Edward Island | https://cpspei.ca/find-a-physician/ |
| Newfoundland & Labrador | https://www.cpsnl.ca/default.asp?com=PublicRegister |

**Evidence Artifacts:**
- [ ] Practitioner registration form showing required fields
- [ ] Database schema with verification_status field
- [ ] API access control code showing verification check
- [ ] Sample verification log entries
- [ ] Verification policy document
- [ ] Public registry lookup procedure (checklist)
- [ ] Verification tracking spreadsheet template

**Failure Mode:**  
Without G16: An attacker creates a "practitioner" account, a patient shares PHI with them, and sensitive mental health information is disclosed to an unauthorized person. The company cannot claim "agent" defense because the recipient was never a custodian. Breach notification required; Commissioner investigation likely; civil liability for unauthorized disclosure.

---

### GATE G17: Clinical Safety & Emergency Redirects ⭐ NEW

**Legal Requirement (Plain Language):**  
Implement passive safety mechanisms that redirect users to crisis resources without implying real-time monitoring. This gate balances two risks: (1) duty-to-warn exposure if users believe the app monitors content, and (2) duty-of-care exposure if crisis content is ignored entirely.

**Risk Level:** HIGH  
**Rationale:** The app collects Safety Notes which may contain crisis content (suicidal ideation, self-harm). The solution is PASSIVE INTERRUPTION: detect potential crisis keywords client-side, display a modal with crisis resources and explicit disclaimers, then allow user to proceed. This positions the app as a redirector, not a monitor.

#### Legal Basis

While no specific statute mandates this pattern, it derives from:
- Duty of care principles (common law)
- Product liability risk mitigation
- Professional guidelines for digital mental health tools
- Expectation management to avoid negligent misrepresentation

**Implementation Requirements:**

| Technical | Policy |
|-----------|--------|
| Client-side keyword detection (regex list) for crisis terms | Crisis keyword list (clinical review recommended) |
| Crisis modal component with: disclaimer, crisis line numbers, "Continue" button | In-app disclaimer text |
| Static SOS button accessible from all log entry screens | Terms of Service: "Not real-time monitoring" clause |
| NO server-side transmission of crisis detection events (privacy) | Safety Notes labeling in UI |
| NO automated alerts to practitioners (avoids monitoring implication) | |

**Acceptance Criteria (BDD):**

```gherkin
Feature: G17 Clinical Safety & Emergency Redirects

  Scenario: Crisis keyword triggers passive modal
    Given a patient enters text containing crisis keywords (e.g., "kill myself", "end it all")
    When the user attempts to submit or navigates away
    Then a modal SHALL appear before submission
    And the modal SHALL display: "We noticed you may be going through a difficult time."
    And the modal SHALL display: "This app is NOT monitored in real time."
    And the modal SHALL display crisis line numbers (Talk Suicide Canada: 1-833-456-4566, Crisis Text Line: text HOME to 686868)
    And the modal SHALL have a "Continue" button to proceed
    And the modal SHALL NOT block submission
    And the detection SHALL NOT be logged to the server

  Scenario: Static SOS button is always accessible
    Given a patient is on any log entry screen
    When they look for emergency resources
    Then a visible SOS/crisis button SHALL be present
    And tapping SHALL display crisis resources immediately (no login required)
    And resources SHALL include: national crisis line, text line, 911 guidance

  Scenario: Safety Notes have explicit labeling
    Given a patient accesses the Safety Notes feature
    When the feature loads
    Then a banner SHALL display: "Your practitioner may review this on their next login. This is not monitored in real time."
    And the banner SHALL NOT imply immediate notification

  Scenario: In-app disclaimer at onboarding
    Given a new patient completes registration
    When they first access the app
    Then an onboarding screen SHALL include: "This app helps you track your mental health. It is NOT a crisis service and is not monitored in real time. If you are in crisis, call 911 or a crisis line."
    And the user SHALL acknowledge before proceeding

  Scenario: No affirmative alerts that imply monitoring
    Given the app is designed
    When design decisions are made
    Then the app SHALL NOT send push notifications saying "Your practitioner has been alerted"
    And the app SHALL NOT display "Help is on the way"
    And the app SHALL NOT promise response times to safety content
```

**Canadian Crisis Resources (to display in app):**

| Resource | Contact |
|----------|---------|
| Talk Suicide Canada | 1-833-456-4566 (24/7) |
| Crisis Text Line Canada | Text HOME to 686868 |
| Emergency Services | 911 |
| Kids Help Phone | 1-800-668-6868 |

**Evidence Artifacts:**
- [ ] Crisis modal UI screenshots
- [ ] SOS button UI screenshots
- [ ] Crisis keyword list (documented)
- [ ] Terms of Service section: "Not Real-Time Monitoring"
- [ ] Onboarding disclaimer screenshots
- [ ] Code review showing no server-side crisis detection logging

**Failure Mode:**  
Without G17: A patient enters safety notes expecting intervention, no intervention occurs, harm results. Plaintiff argues app design implied monitoring. OR: app sends automated crisis alerts, practitioner does not respond, app company argued to have assumed duty to intervene.

With G17: App explicitly disclaims monitoring, provides crisis resources, does not promise intervention. User has been informed and redirected to appropriate resources. Liability posture significantly improved.

---

## 5. Engineering & Ops Tickets

### 5.0 Phase 0: Privacy-by-Design Tickets (G0 Series)

> **Implementation Best Practice (Non-statutory):** These tickets implement the privacy-by-design foundation from Phase 0.

#### PBD-001: Publish Patient Data Promise
**Gate Reference:** G0.1  
**Priority:** P0 - Critical  
**Legal Citation:** N/A (Best Practice - supports accountability principle under PIPEDA Schedule 1 Principle 1)

**Description:**  
Create and publish a patient-facing Data Promise document that clearly communicates data practices.

**Requirements:**
1. Write Data Promise at grade 8 reading level
2. Cover: what collected, why, who sees, what's never done
3. Include Implementation-Dependent Promises with verification notes
4. Publish in app (accessible within 2 clicks) and on website
5. Provide in English and French

**Acceptance Criteria:**
- Readability score at grade 8 or below (Flesch-Kincaid)
- Legal/privacy review completed
- Technical verification that all promises are enforceable
- Published in app and on website

---

#### PBD-002: Create and Maintain Data Inventory
**Gate Reference:** G0.2  
**Priority:** P1 - High  
**Legal Citation:** N/A (Best Practice - supports data mapping requirements across all provinces)

**Description:**  
Create comprehensive data inventory documenting all PHI elements and data flows.

**Requirements:**
1. Inventory all PHI fields with: sensitivity, source, storage, transmission, access, retention, deletion path
2. Document all data flows with encryption and authorization status
3. Establish update process for new features
4. Review quarterly

**Acceptance Criteria:**
- Complete inventory table exists
- Data flow diagrams exist for all PHI paths
- Update process documented
- First quarterly review scheduled

---

#### PBD-003: Implement Data Minimization Controls
**Gate Reference:** G0.3  
**Priority:** P1 - High  
**Legal Citation:** ON PHIPA s.30(2), SK HIPA s.23, BC PIPA s.11 (statutory minimization requirements)

**Description:**  
Implement data minimization by removing unnecessary fields and replacing free-text with structured options.

**Requirements:**
1. Review all PHI fields; document necessity justification
2. Convert free-text fields to structured options where safe
3. Add character limits to remaining free-text
4. Isolate PHI from analytics systems

**Acceptance Criteria:**
- Data necessity matrix completed
- Free-text fields reduced by 50%+
- Analytics system has no access to PHI database
- PHI fields have documented justification

---

#### PBD-004: Complete Threat Model and Mitigation Tracking
**Gate Reference:** G0.4  
**Priority:** P1 - High  
**Legal Citation:** N/A (Best Practice - supports security safeguard requirements)

**Description:**  
Complete STRIDE + safety-specific threat model and establish mitigation tracking.

**Requirements:**
1. Document all STRIDE category threats
2. Document safety-specific threats (DV, stalking, device seizure, etc.)
3. Track mitigations with owner and status
4. Review threat model with each major release

**Acceptance Criteria:**
- Threat model document complete (Threagile YAML)
- All identified mitigations have tickets
- Critical mitigations implemented before launch
- Review cadence established

---

#### PBD-005: Implement No-Human-Access Architecture
**Gate Reference:** G0.5  
**Priority:** P0 - Critical  
**Legal Citation:** N/A (Best Practice - supports safeguard requirements, insider threat mitigation)

**Description:**  
Configure systems so support staff cannot access PHI by default, with documented break-glass procedure.

**Requirements:**
1. Configure RBAC: support role has no PHI table access
2. Redact PHI from support-accessible logs
3. Remove any "view as patient" functionality
4. Implement break-glass with dual approval, time-boxing, logging
5. Create patient notification procedure for break-glass

**Acceptance Criteria:**
- Support role query test: PHI queries fail with permission denied
- Log sample review: no PHI visible in support logs
- PAM configured for break-glass
- Break-glass procedure documented
- Patient notification template created

---

#### PBD-006: PHI Isolation from Analytics
**Gate Reference:** G0.3, G0.5  
**Priority:** P0 - Critical  
**Legal Citation:** N/A (Best Practice - supports minimization and no-human-access)

**Description:**  
Architect analytics system to have zero access to PHI.

**Requirements:**
1. Analytics database separate from PHI database
2. No patient_id in analytics events (use anonymous session_id)
3. No health data in analytics events
4. Network-level isolation between analytics and PHI services

**Acceptance Criteria:**
- Architecture diagram shows isolation
- Analytics event schema has no PII/PHI fields
- Network firewall rules prevent analytics → PHI database traffic
- Penetration test confirms isolation

---

### 5.1 Backend Engineering Tickets

#### BE-001: Implement Consent Management System
**Gate Reference:** G2  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.18-19, AB HIA s.34, MB PHIA s.19.1-19.2, SK HIPA s.5-7

**Description:**  
Build a consent management system that captures, stores, and manages patient consent for PHI collection, use, and disclosure.

**Requirements:**
1. Consent capture with purpose statement display
2. Consent versioning (track which version was agreed to)
3. Timestamp all consent events in UTC
4. Consent withdrawal mechanism (non-retroactive)
5. Consent audit trail (immutable)
6. Province-specific consent text variations

**Acceptance Criteria:**
- Consent record includes: user_id, consent_type, consent_version, timestamp_utc, ip_address, method
- Withdrawal does not delete historical data
- API returns consent status for any user

---

#### BE-002: Implement Role-Based Access Control for Practitioners
**Gate Reference:** G4, G6  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.17, s.30, SK HIPA s.23

**Description:**  
Implement RBAC ensuring practitioners can only access PHI for patients who have consented to share with them.

**Requirements:**
1. Practitioner-patient relationship table
2. Access check on every PHI query
3. Denied access logging
4. Session management with timeout

**Acceptance Criteria:**
- Practitioner query for patient without consent relationship returns 403
- All access attempts are logged
- Session expires after 30 minutes idle

---

#### BE-003: Implement Comprehensive Audit Logging
**Gate Reference:** G15  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.10.1, s.16(2)

**Description:**  
Build comprehensive audit logging for all PHI access and processing.

**Requirements:**
1. Log all: reads, writes, updates, deletes, exports, disclosures
2. Log fields: timestamp_utc, user_id, action, resource_type, resource_id, patient_id, success, ip_address, user_agent
3. Immutable log storage (append-only)
4. Log retention: minimum 10 years
5. Log export capability for Commissioner requests

**Acceptance Criteria:**
- Every API call touching PHI creates audit log entry
- Logs cannot be modified or deleted
- Log export produces Commissioner-ready format

---

#### BE-004: Implement Breach Detection and Response System
**Gate Reference:** G7  
**Priority:** P1 - High  
**Legal Citation:** ON PHIPA s.12(2-3), AB HIA s.60.1

**Description:**  
Build system for detecting potential breaches and managing incident response.

**Requirements:**
1. Anomaly detection for access patterns
2. Failed authentication monitoring
3. Incident ticket creation workflow
4. Notification queue for affected individuals
5. Regulatory notification templates

**Acceptance Criteria:**
- Anomalous access triggers alert within 1 hour
- Incident creates ticket with required fields
- Notification templates include all required content

---

#### BE-005: Implement Patient Data Export (Access Rights)
**Gate Reference:** G5  
**Priority:** P1 - High  
**Legal Citation:** ON PHIPA s.52-54, MB PHIA s.5-7

**Description:**  
Enable patients to export all their PHI in a portable format.

**Requirements:**
1. Export all log entries for patient
2. Export account information
3. Export consent history
4. Export disclosure log
5. Formats: JSON, PDF

**Acceptance Criteria:**
- Export includes all PHI for patient
- Export completes within 30 seconds
- PDF is human-readable

---

#### BE-006: Implement Encryption at Rest
**Gate Reference:** G6  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.12(1), MB PHIA s.18

**Description:**  
Encrypt all PHI at rest in the database.

**Requirements:**
1. AES-256 encryption for PHI columns
2. Key management via HSM or cloud KMS
3. Key rotation capability (annual minimum)
4. Encryption verification

**Acceptance Criteria:**
- PHI columns are encrypted in storage
- Keys are not stored in application code
- Key rotation does not cause downtime

---

#### BE-G16-001: Add verification_status to practitioners table ⭐ NEW
**Gate Reference:** G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.3(1), s.17

**Description:**  
Add verification status field to practitioners table to track credentialing state.

**Requirements:**
1. Add enum field: pending, verified, rejected, suspended
2. Default value: 'pending'
3. Add verification_date timestamp
4. Add verified_by field (operator ID)

**Acceptance Criteria:**
- Field exists with correct enum values
- New practitioner accounts default to 'pending'
- Migration runs without data loss

---

#### BE-G16-002: PHI API verification status middleware ⭐ NEW
**Gate Reference:** G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.3(1), s.17

**Description:**  
Block PHI queries from practitioners who are not verified.

**Requirements:**
1. Middleware checks verification_status on all PHI endpoints
2. Return HTTP 403 for non-verified practitioners
3. Include clear error message: "Account pending verification"
4. Log all denied access attempts

**Acceptance Criteria:**
- GET /api/logs returns 403 for unverified practitioner
- GET /api/patients returns 403 for unverified practitioner
- Audit log entry created on denial
- Verified practitioner can access consented data

---

#### BE-G16-003: Practitioner verification log table ⭐ NEW
**Gate Reference:** G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.3(1), s.17

**Description:**  
Create audit table for practitioner verification events.

**Requirements:**
1. Fields: id, practitioner_id, verifier_id, timestamp_utc, evidence_type, registry_checked, decision, notes
2. Immutable (no updates/deletes)
3. Foreign key to practitioners table

**Acceptance Criteria:**
- Table created with all required fields
- Verification creates log entry
- Cannot update or delete existing entries

---

#### BE-G16-004: Invite code system for patient onboarding ⭐ NEW
**Gate Reference:** G16  
**Priority:** P1 - High  
**Legal Citation:** ON PHIPA s.17

**Description:**  
Generate invite codes linked to practitioners for patient registration (recommended "Prescription" model).

**Requirements:**
1. Generate unique invite codes
2. Link code to issuing practitioner
3. Expiry after 7 days or single use
4. Validate code on patient registration

**Acceptance Criteria:**
- Practitioner can generate invite codes
- Patient registration accepts valid code
- Expired/used codes rejected
- Patient auto-linked to practitioner on registration

---

#### BE-G16-005: Practitioner suspension workflow ⭐ NEW
**Gate Reference:** G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.3(1), s.17

**Description:**  
Implement immediate suspension of practitioner access when verification status changes.

**Requirements:**
1. API endpoint to suspend practitioner
2. Terminate all active sessions on suspension
3. Send notification email to practitioner
4. Log suspension event

**Acceptance Criteria:**
- Suspended practitioner immediately loses access
- Active sessions terminated within 1 minute
- Email notification sent
- Audit log records suspension

---

#### BE-G17-001: Verify no server-side crisis keyword logging ⭐ NEW
**Gate Reference:** G17  
**Priority:** P0 - Critical  
**Legal Citation:** Privacy by design principles

**Description:**  
Ensure crisis keyword detection is client-side only and not logged to server.

**Requirements:**
1. Review all API endpoints for crisis-related logging
2. Confirm no endpoint captures crisis detection events
3. Document architecture decision

**Acceptance Criteria:**
- Code review confirms no crisis detection logging
- API audit shows no crisis-related parameters
- Architecture decision record created

---

### 5.2 Frontend Engineering Tickets

#### FE-001: Consent Capture UI
**Gate Reference:** G2  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.18(5-6)

**Description:**  
Build consent capture screens with clear purpose statements and opt-in controls.

**Requirements:**
1. Display consent text clearly
2. Link to full privacy policy
3. No pre-checked boxes
4. Clear "I Agree" / "I Do Not Agree" buttons
5. Province-specific text loading

**Acceptance Criteria:**
- Consent text is visible without scrolling
- Checkboxes are unchecked by default
- Both agree and disagree paths work

---

#### FE-002: Patient Sharing Controls
**Gate Reference:** G4  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.18(3), s.19

**Description:**  
Build UI for patients to control what they share with practitioners.

**Requirements:**
1. Practitioner selection
2. Log type selection
3. Date range selection
4. Revoke sharing button
5. Sharing status display

**Acceptance Criteria:**
- Patient can select specific practitioners
- Patient can limit to specific log types
- Revocation is immediate

---

#### FE-003: Patient Data Access and Export UI
**Gate Reference:** G5  
**Priority:** P1 - High  
**Legal Citation:** ON PHIPA s.52

**Description:**  
Build UI for patients to view and export their data.

**Requirements:**
1. View all log entries
2. View consent history
3. View disclosure log
4. Export button (JSON/PDF)

**Acceptance Criteria:**
- All patient data is visible
- Export downloads within 30 seconds

---

#### FE-004: Correction Request UI
**Gate Reference:** G5  
**Priority:** P2 - Medium  
**Legal Citation:** ON PHIPA s.55

**Description:**  
Build UI for patients to request corrections to their PHI.

**Requirements:**
1. Identify record to correct
2. Describe requested correction
3. Submit request
4. Track request status

**Acceptance Criteria:**
- Request creates ticket in system
- Patient sees status updates

---

#### FE-G16-001: Practitioner pending verification UI ⭐ NEW
**Gate Reference:** G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.3(1), s.17

**Description:**  
Show pending verification status to unverified practitioners.

**Requirements:**
1. Banner showing "Account Pending Verification" status
2. Disable patient list and PHI views
3. Show estimated verification timeline
4. Provide contact for questions

**Acceptance Criteria:**
- Banner visible on all portal pages for pending accounts
- Patient queries blocked in UI layer
- Clear messaging about verification process

---

#### FE-G16-002: Practitioner registration credential fields ⭐ NEW
**Gate Reference:** G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.3(1)

**Description:**  
Capture required credential information during practitioner registration.

**Requirements:**
1. License number field (required)
2. Licensing body dropdown (e.g., CPSO, CPSA, CPSBC)
3. Province of licensure
4. Professional designation

**Acceptance Criteria:**
- Cannot submit without license number
- Licensing body validated against province
- Data saved to practitioner profile

---

#### FE-G17-001: Crisis modal component ⭐ NEW
**Gate Reference:** G17  
**Priority:** P0 - Critical  
**Legal Citation:** Duty of care principles

**Description:**  
Build modal that appears when crisis keywords are detected in text input.

**Requirements:**
1. Modal displays empathetic message
2. Modal displays "NOT monitored in real time" disclaimer
3. Modal displays crisis line numbers (Talk Suicide Canada, Crisis Text Line)
4. "Continue" button to proceed with submission
5. Modal does not block submission
6. No server-side logging of trigger event

**Acceptance Criteria:**
- Modal appears on keyword match
- All required content displayed
- Continue button works
- No network request on modal trigger

---

#### FE-G17-002: Crisis keyword regex list ⭐ NEW
**Gate Reference:** G17  
**Priority:** P0 - Critical  
**Legal Citation:** Duty of care principles

**Description:**  
Maintain and document list of crisis-indicative keywords for client-side detection.

**Requirements:**
1. Regex patterns for crisis terms
2. Include: suicidal ideation, self-harm, harm to others indicators
3. Document patterns and rationale
4. Clinical review recommended

**Acceptance Criteria:**
- Keyword list documented
- Regex patterns tested
- False positive rate acceptable

---

#### FE-G17-003: Static SOS button ⭐ NEW
**Gate Reference:** G17  
**Priority:** P0 - Critical  
**Legal Citation:** Duty of care principles

**Description:**  
Always-visible button linking to crisis resources on all log entry screens.

**Requirements:**
1. Visible on all log entry forms
2. Works without login
3. Displays crisis resources immediately
4. Includes national crisis line, text line, 911 guidance

**Acceptance Criteria:**
- Button visible on mood, anxiety, sleep, safety note forms
- Tap displays resources without delay
- Resources accurate and up-to-date

---

#### FE-G17-004: Safety Notes disclaimer banner ⭐ NEW
**Gate Reference:** G17  
**Priority:** P0 - Critical  
**Legal Citation:** Duty of care principles

**Description:**  
Display disclaimer banner on Safety Notes entry screen.

**Requirements:**
1. Banner text: "Your practitioner may review this on their next login. This is not monitored in real time."
2. Visible at top of Safety Notes form
3. Cannot be dismissed

**Acceptance Criteria:**
- Banner visible on Safety Notes screen
- Text matches requirement exactly
- Banner persists during entry

---

#### FE-G17-005: Onboarding disclaimer screen ⭐ NEW
**Gate Reference:** G17  
**Priority:** P0 - Critical  
**Legal Citation:** Duty of care principles

**Description:**  
Display crisis disclaimer during new patient onboarding.

**Requirements:**
1. Screen during first-time user flow
2. Text: "This app helps you track your mental health. It is NOT a crisis service and is not monitored in real time. If you are in crisis, call 911 or a crisis line."
3. User must acknowledge to proceed
4. Record acknowledgment timestamp

**Acceptance Criteria:**
- Screen appears on first launch after registration
- Cannot proceed without acknowledgment
- Acknowledgment logged with timestamp

---

### 5.3 Infrastructure / DevOps Tickets

#### INFRA-001: Configure TLS 1.2+ Only
**Gate Reference:** G6  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.12(1)

**Description:**  
Configure all endpoints to use TLS 1.2 or higher only.

**Requirements:**
1. Disable TLS 1.0, 1.1
2. Disable weak cipher suites
3. Configure HSTS
4. Implement certificate monitoring

**Acceptance Criteria:**
- SSL Labs score of A or higher
- No weak protocols or ciphers

---

#### INFRA-002: Implement Log Aggregation and Retention
**Gate Reference:** G15  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.10.1

**Description:**  
Set up centralized log aggregation with long-term retention.

**Requirements:**
1. Aggregate all audit logs
2. Immutable storage (e.g., S3 with Object Lock)
3. 10-year retention
4. Log integrity verification

**Acceptance Criteria:**
- All audit logs flow to central system
- Logs cannot be deleted for 10 years
- Integrity hash is computed

---

#### INFRA-003: Configure Data Residency
**Gate Reference:** G10  
**Priority:** P1 - High  
**Legal Citation:** ON PHIPA s.50, PE HIA s.35

**Description:**  
Ensure PHI is stored in Canadian data centers.

**Requirements:**
1. Primary database in Canada
2. Backups in Canada
3. Document all storage locations
4. Prevent accidental non-Canadian replication

**Acceptance Criteria:**
- All PHI storage is in Canadian regions
- Documentation lists all locations

---

### 5.4 Security Tickets

#### SEC-001: Implement Multi-Factor Authentication for Practitioners
**Gate Reference:** G6  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.12(1)

**Description:**  
Require MFA for all practitioner accounts.

**Requirements:**
1. TOTP or hardware key support
2. MFA enrollment workflow
3. Recovery flow
4. MFA enforcement policy

**Acceptance Criteria:**
- Practitioners cannot access portal without MFA
- MFA recovery does not bypass security

---

#### SEC-002: Implement Vulnerability Scanning
**Gate Reference:** G6  
**Priority:** P1 - High  
**Legal Citation:** ON PHIPA s.12(1)

**Description:**  
Set up automated vulnerability scanning.

**Requirements:**
1. Monthly automated scans
2. Integration with ticketing
3. SLA for remediation
4. Scan reports retained

**Acceptance Criteria:**
- Scans run monthly
- Critical vulns create P0 tickets

---

### 5.5 Operations Tickets ⭐ NEW

#### OPS-G16-001: Practitioner verification procedure
**Gate Reference:** G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.3(1), s.17

**Description:**  
Document manual verification steps for practitioner credentialing.

**Requirements:**
1. Step-by-step verification checklist
2. Public registry lookup procedure for each province
3. Decision criteria for approval/rejection
4. Escalation path for unclear cases

**Acceptance Criteria:**
- Written procedure document exists
- Checklist covers all required verifications
- Registry URLs documented for each licensing body

---

#### OPS-G16-002: Verification tracking spreadsheet
**Gate Reference:** G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.3(1), s.17

**Description:**  
Create spreadsheet to track verification status (MVP approach).

**Requirements:**
1. Columns: practitioner_id, name, license_number, licensing_body, registry_url, verified_by, date, evidence, decision
2. Template ready for immediate use
3. Secure storage (access controlled)

**Acceptance Criteria:**
- Spreadsheet created with required columns
- First verification logged successfully
- Access limited to authorized operators

---

#### OPS-G16-003: Verification SLA monitoring
**Gate Reference:** G16  
**Priority:** P1 - High  
**Legal Citation:** ON PHIPA s.3(1), s.17

**Description:**  
Monitor verification completion within 2 business day SLA.

**Requirements:**
1. Track time from registration to verification
2. Alert if approaching SLA breach
3. Weekly report on verification metrics

**Acceptance Criteria:**
- SLA compliance tracked
- Report shows average verification time

---

### 5.6 Policy Tickets ⭐ NEW

#### POL-G16-001: Practitioner Verification Policy
**Gate Reference:** G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.3(1), s.17

**Description:**  
Document practitioner verification policy.

**Requirements:**
1. Purpose statement
2. Verification process description
3. Acceptable evidence types
4. Rejection/suspension criteria
5. Re-verification requirements (annual)
6. Appeal process

**Acceptance Criteria:**
- Policy document published
- Covers all required elements
- Reviewed by legal (recommended)

---

#### POL-G17-001: Terms of Service update - Not Real-Time Monitoring
**Gate Reference:** G17  
**Priority:** P0 - Critical  
**Legal Citation:** Duty of care principles

**Description:**  
Add section to Terms of Service disclaiming real-time monitoring.

**Requirements:**
1. Clear statement app is not monitored in real time
2. Statement app is not a crisis service
3. Crisis line numbers and 911 guidance
4. User acknowledgment required

**Acceptance Criteria:**
- ToS updated with new section
- Legal review completed
- Users prompted to accept updated ToS

---

#### POL-G09-001: Practitioner Agreement template
**Gate Reference:** G9, G16  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA s.17

**Description:**  
Create click-wrap agreement for practitioners establishing agent relationship.

**Requirements:**
1. Custodian role acknowledgment
2. Agent relationship description
3. Compliance obligations
4. Breach notification requirements
5. Verification consent

**Acceptance Criteria:**
- Agreement template ready
- Click-wrap acceptance flow implemented
- Acceptance logged with timestamp

---

#### POL-G02-001: Privacy Policy - Privacy Officer contact
**Gate Reference:** G2, G7  
**Priority:** P0 - Critical  
**Legal Citation:** ON PHIPA, AB HIA, all provincial acts

**Description:**  
Publish Privacy Officer contact information in privacy policy and in-app.

**Requirements:**
1. Designate Privacy Officer
2. Email address for privacy inquiries
3. Physical mailing address
4. Provincial commissioner contact links

**Acceptance Criteria:**
- Privacy policy updated
- In-app "Privacy Questions" link added
- Contact info accurate and monitored

---

### 5.7 Operational Runbooks

#### OPS-RUNBOOK-001: Breach Response Playbook
**Gate Reference:** G7  
**Legal Citation:** ON PHIPA s.12, AB HIA s.60.1

**Trigger:** Suspected or confirmed privacy breach

**Steps:**
1. **Detection** (0-1 hour)
   - Verify breach is real
   - Document initial findings
   - Escalate to Privacy Officer

2. **Containment** (1-4 hours)
   - Isolate affected systems
   - Revoke compromised credentials
   - Preserve evidence

3. **Investigation** (4-48 hours)
   - Determine scope (which patients, what data)
   - Determine cause
   - Assess risk of harm (use AB HIA Chapter 14 factors)

4. **Notification Assessment** (48-72 hours)
   - Determine if notification required
   - Prepare notification content
   - Identify notification recipients

5. **Notification Execution** (72+ hours)
   - Notify affected individuals (first reasonable opportunity)
   - Notify Commissioner (if thresholds met)
   - Notify Minister (AB only)
   - Notify custodian clients

6. **Remediation**
   - Fix root cause
   - Update controls
   - Document lessons learned

**Templates:**
- Individual notification letter
- Commissioner notification form
- Risk of harm assessment worksheet

---

#### OPS-RUNBOOK-002: Patient Access Request Handling
**Gate Reference:** G5  
**Legal Citation:** ON PHIPA s.52-54, MB PHIA s.5-7

**Trigger:** Patient requests access to their PHI

**Steps:**
1. **Receive Request** (Day 0)
   - Log request in tracking system
   - Verify patient identity
   - Acknowledge receipt

2. **Gather Records** (Days 1-20)
   - Query all patient data
   - Include consent records
   - Include disclosure log

3. **Review for Exceptions** (Days 20-25)
   - Check if any exceptions apply (risk of harm, third party info)
   - Consult legal if needed

4. **Prepare Response** (Days 25-28)
   - Compile data export
   - Prepare cover letter
   - Document any redactions

5. **Deliver Response** (Day 30 max)
   - Send data to patient via secure method
   - Log completion

**SLA:** 30 calendar days

---

#### OPS-RUNBOOK-003: Patient Correction Request Handling
**Gate Reference:** G5  
**Legal Citation:** ON PHIPA s.55

**Trigger:** Patient requests correction of their PHI

**Steps:**
1. **Receive Request**
   - Log request
   - Verify identity
   - Acknowledge receipt

2. **Investigate**
   - Review original record
   - Assess accuracy of original vs requested correction
   - Consult source if needed

3. **Decision**
   - If granted: Make correction, notify linked parties
   - If denied: Prepare reasons, attach patient's statement of disagreement

4. **Respond**
   - Notify patient of decision
   - Provide reasons if denied

**SLA:** 30 calendar days

---

#### OPS-RUNBOOK-004: Practitioner Verification Playbook ⭐ NEW
**Gate Reference:** G16  
**Legal Citation:** Multiple provincial health profession acts

**Trigger:** New practitioner registration received

**Steps:**

1. **Receive Registration**
   - Log registration timestamp (UTC)
   - Extract: Full legal name, License number, Province, Profession type
   - Set practitioner status to `pending_verification`

2. **Credential Lookup**
   - Access provincial registry (see table below)
   - Search by license number + name
   - Capture: License status, Expiry date, Discipline history, Practice restrictions

   | Province | Registry URL | Profession |
   |----------|--------------|------------|
   | ON | https://doctors.cpso.on.ca | Physicians |
   | ON | https://portal.cpo.on.ca | Psychologists |
   | AB | https://search.cpsa.ca | Physicians |
   | AB | https://cap.ab.ca/find-a-psychologist | Psychologists |
   | BC | https://www.cpsbc.ca/physician_search | Physicians |
   | BC | https://www.collegeofpsychologists.bc.ca | Psychologists |
   | MB | https://cpsm.mb.ca/physician-search | Physicians |
   | SK | https://www.cps.sk.ca/imis/web/Find%20a%20Doctor | Physicians |
   | NB | https://cpsnb.org/find-a-physician | Physicians |
   | NS | https://cpsns.ns.ca/find-a-physician | Physicians |
   | NL | https://cpsnl.ca/find-a-physician | Physicians |
   | PE | https://cpspei.ca/find-a-physician | Physicians |
   | QC | https://www.cmq.org/en/trouver-un-medecin | Physicians |

3. **Decision**
   - **PASS:** Active license, no restrictions blocking mental health practice → Set status to `verified`
   - **PENDING:** Unable to locate in registry → Request additional documentation, extend SLA
   - **FAIL:** License expired/suspended/revoked, or active restrictions → Set status to `rejected`, notify practitioner

4. **Completion**
   - Record verification outcome with evidence (screenshot/export timestamp)
   - If verified: Grant platform access, enable patient linkage
   - If rejected: Provide appeal instructions, retain evidence for 7 years

**SLA:** 2 business days from registration

---

#### OPS-RUNBOOK-005: Practitioner Suspension Playbook ⭐ NEW
**Gate Reference:** G16  
**Legal Citation:** Multiple provincial health profession acts

**Trigger:** Any of:
- College notification of license status change
- Patient complaint regarding practitioner credentials
- Periodic re-verification failure
- Practitioner self-report of status change

**Steps:**

1. **Trigger Assessment**
   - Log trigger source and timestamp
   - Categorize: Routine re-verification vs. urgent suspension
   - If urgent (license revoked/suspended): Proceed immediately to Step 2

2. **Immediate Suspension**
   - Set practitioner status to `suspended`
   - Revoke active session tokens
   - Block new patient data submissions for this practitioner
   - Preserve all existing audit logs

3. **Patient Notification Assessment**
   - Determine patients with active data linked to practitioner
   - Draft notification (if practitioner will not return): Advise patients to export data / link to new practitioner
   - Legal review of notification before sending

4. **Resolution**
   - **Reinstatement:** If license restored, re-verify via OPS-RUNBOOK-004, restore access
   - **Permanent Removal:** If license permanently revoked:
     - Offer patients 90 days to export/transfer data
     - After 90 days, de-link practitioner access (data retention policies apply)
     - Archive practitioner record

**SLA:** 
- Urgent suspension: 4 hours from trigger
- Routine re-verification: Per G16 annual cycle

---

## 6. BDD Acceptance Criteria

### Full Feature File: Consent Management

```gherkin
Feature: Consent Management System
  As a patient
  I want to control consent for my PHI
  So that my privacy is protected according to provincial law

  Background:
    Given the application operates in province "<province>"
    And provincial PHI legislation applies

  @critical @G2
  Scenario Outline: Patient provides knowledgeable consent
    Given I am a new patient registering for the app
    When the consent screen is displayed
    Then I SHALL see a clear statement of purposes for collection
    And the purposes SHALL include "providing mental health support"
    And I SHALL see a statement that I may give or withhold consent
    And no consent checkbox SHALL be pre-checked
    And the consent text SHALL be in plain language
    And the consent text SHALL be specific to "<province>"

    Examples:
      | province           |
      | Ontario            |
      | Alberta            |
      | Manitoba           |
      | Saskatchewan       |
      | British Columbia   |
      | New Brunswick      |
      | Prince Edward Island |

  @critical @G2
  Scenario: Patient refuses consent
    Given I am on the consent screen
    When I select "I Do Not Consent"
    Then I SHALL NOT be able to use the app
    And my decision SHALL be logged
    And no PHI SHALL be collected

  @critical @G2
  Scenario: Consent record is created
    Given I provide consent
    When the consent is recorded
    Then the record SHALL include my user identifier
    And the record SHALL include a UTC timestamp
    And the record SHALL include the consent version
    And the record SHALL include the consent method (app tap)
    And the record SHALL be immutable

  @critical @G2
  Scenario: Patient withdraws consent
    Given I have previously consented
    When I navigate to Privacy Settings
    And I select "Withdraw Consent"
    Then I SHALL see a confirmation prompt
    And upon confirmation, my consent status SHALL change to "withdrawn"
    And the withdrawal SHALL be timestamped
    And future data collection SHALL stop
    And historical data SHALL NOT be deleted per PHIPA s.19(1)

  @high @G2
  Scenario: Express consent for sharing with practitioner
    Given I want to share my log entries with my practitioner
    When I access sharing settings
    Then I SHALL be required to provide express consent
    And I SHALL select the specific practitioner
    And I SHALL select what information to share
    And the consent SHALL be recorded with specificity
```

### Full Feature File: Security Safeguards

```gherkin
Feature: Security Safeguards
  As a system
  I must protect PHI against unauthorized access
  So that patient privacy is maintained

  @critical @G6
  Scenario: Encryption at rest
    Given PHI is stored in the database
    When I examine the database storage
    Then all PHI columns SHALL be encrypted
    And encryption SHALL use AES-256 or equivalent
    And encryption keys SHALL be stored in HSM/KMS

  @critical @G6
  Scenario: Encryption in transit
    Given PHI is transmitted over the network
    When I examine network traffic
    Then TLS 1.2 or higher SHALL be used
    And TLS 1.0 and 1.1 SHALL be disabled
    And weak cipher suites SHALL be disabled

  @critical @G6
  Scenario: Multi-factor authentication for practitioners
    Given I am a practitioner logging in
    When I enter my password
    Then I SHALL be prompted for a second factor
    And the second factor SHALL be TOTP or hardware key
    And I SHALL NOT access PHI without completing MFA

  @critical @G6
  Scenario: Session timeout
    Given I am logged in as a practitioner
    When I am idle for 30 minutes
    Then my session SHALL expire
    And I SHALL be required to re-authenticate

  @critical @G6
  Scenario: Failed login lockout
    Given I am attempting to log in
    When I fail authentication 5 times
    Then my account SHALL be locked
    And an alert SHALL be generated
    And I SHALL need to contact support to unlock

  @high @G6
  Scenario: Access denied logging
    Given I am a practitioner
    When I attempt to access a patient who has not consented to share with me
    Then access SHALL be denied
    And the denial SHALL be logged with my identity and the patient ID
```

### Full Feature File: Breach Response

```gherkin
Feature: Breach Detection and Response
  As a custodian
  I must detect and respond to breaches promptly
  So that harm to patients is minimized

  @critical @G7
  Scenario: Anomalous access detected
    Given audit logs are being monitored
    When a practitioner accesses 100+ patient records in 1 hour
    Then an alert SHALL be generated
    And the alert SHALL include practitioner identity and access count
    And the alert SHALL be investigated within 24 hours

  @critical @G7
  Scenario: Breach containment
    Given a breach has been confirmed
    When the incident response plan is activated
    Then affected systems SHALL be isolated within 4 hours
    And compromised credentials SHALL be revoked
    And evidence SHALL be preserved

  @critical @G7
  Scenario: Individual notification (Ontario)
    Given a breach occurred affecting Ontario patients
    And the breach meets notification thresholds
    When notification is prepared
    Then affected individuals SHALL be notified at first reasonable opportunity
    And notification SHALL describe the breach
    And notification SHALL include types of PHI affected
    And notification SHALL include right to complain to Commissioner per PHIPA s.12(2)(b)

  @critical @G7
  Scenario: Risk of harm assessment (Alberta)
    Given a breach occurred affecting Alberta patients
    When notification requirements are assessed
    Then a risk of harm assessment SHALL be conducted per HIA s.60.1
    And the assessment SHALL consider factors from HIA Chapter 14
    And the assessment SHALL be documented

  @critical @G7
  Scenario: Commissioner notification (Ontario)
    Given a breach meets prescribed thresholds
    When Commissioner notification is required
    Then notification SHALL be sent to the Information and Privacy Commissioner
    And notification SHALL include prescribed content per PHIPA s.12(3)
```

---

## 7. Missing Sources & Ambiguities

### 7.1 Missing Source Items

| Item | Province | Impact | Recommended Action |
|------|----------|--------|-------------------|
| ~~Personal Information Protection Act (PIPA)~~ | British Columbia | ~~Governs private sector PHI handling outside designated health information banks~~ | ✅ **OBTAINED** - SBC 2003, c. 63 |
| ~~Health Information Act (full statute text)~~ | Alberta | ~~Guidelines manual provided but not the Act itself~~ | ✅ **OBTAINED** - RSA 2000, c. H-5 |
| Regulations under each Act | All provinces | Specific requirements often in regulations | Obtain all applicable regulations |
| Professional college guidelines | All provinces | May impose additional requirements on practitioners | Obtain college privacy guidelines |
| Commissioner guidance/orders | All provinces | Interpretive guidance | Review OIPC guidance documents |
| ~~Newfoundland PHIA (full Act)~~ | NL | ~~Only policy manual provided~~ | ✅ **OBTAINED** - SNL2008 c. P-7.01 |
| ~~Quebec general health privacy law~~ | Quebec | ~~P-9.0001 is specific to health information sharing~~ | ✅ **OBTAINED** - P-39.1 (Private Sector) |
| ~~Nova Scotia PHIA~~ | Nova Scotia | ~~Province not in corpus~~ | ✅ **OBTAINED** - Chapter 41 of the Acts of 2010 |
| Northwest Territories HIPA | NWT | Territory not in corpus | Assess if applicable to user base |
| Nunavut health privacy legislation | Nunavut | Territory not in corpus | Assess if applicable to user base |
| Yukon health privacy legislation | Yukon | Territory not in corpus | Assess if applicable to user base |
| ~~Federal PIPEDA~~ | Canada | ~~Federal baseline for interprovincial/international transfers~~ | ✅ **OBTAINED** - S.C. 2000, c. 5 |
| Alberta PIPA (private sector) | Alberta | Private sector privacy distinct from HIA | Obtain RSA 2000, c. P-6.5 |

### 7.2 Ambiguities / Interpretive Questions for Counsel

1. **App Company as Agent vs. Custodian:**  
   - Is the app company an "agent" of the practitioner-custodian, or a separate custodian?
   - Answer affects liability allocation and consent requirements.
   - *Recommendation:* Structure as agent to leverage custodian relationship.

2. **Multi-Provincial Operation:**  
   - When a patient is in Province A and practitioner in Province B, which law applies?
   - *Recommendation:* Apply strictest standard; obtain legal opinion.

3. **Implied Consent for Circle of Care:**  
   - Does patient-initiated sharing to their practitioner qualify as "implied consent" for health care purposes?
   - ON PHIPA s.20(2) suggests yes, but express consent is safer.
   - *Recommendation:* Obtain express consent to eliminate ambiguity.

4. **Health Number Collection:**  
   - Is provincial health number required for this app?
   - If collected, special restrictions apply (ON PHIPA s.34, AB HIA s.21).
   - *Recommendation:* Avoid collecting health numbers unless necessary.

5. **De-identification Standard:**  
   - What specific methods satisfy "de-identification" under each province's definition?
   - ON PHIPA s.2 requires removal of information "reasonably foreseeable" to identify.
   - *Recommendation:* Use established standards (e.g., HIPAA Safe Harbor or Expert Determination equivalent).

6. **Cross-Border Practitioner Access:**  
   - If a practitioner licensed in one province accesses patient data from another province, which province's law applies?
   - *Recommendation:* Document patient's province of residence; apply that province's law.

### 7.3 Assumptions Made

| Assumption | Rationale | Risk if Incorrect |
|------------|-----------|-------------------|
| App company operates as agent of custodian | Typical SaaS model; aligns with legislation structure | Higher liability if deemed separate custodian |
| All data storage in Canada | Simplifies cross-border compliance | Would need cross-border assessments |
| Mental health log entries constitute PHI | Conservative interpretation; clearly relates to mental health | Lower compliance burden if incorrect |
| Practitioners are licensed health care providers | Required for custodian status | App may not be usable by unlicensed providers |
| Patients are capable adults unless otherwise indicated | Presumption of capacity in legislation | Need minor/incapacity workflows |
| No research use intended | Simplifies compliance | Would need research ethics pathway if incorrect |
| Primary purpose is providing health care | Enables certain implied consent pathways | Would need different consent model if incorrect |

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-04 | Compliance Engineering | Initial release |
| 2.0 | 2026-02-04 | Compliance Engineering | Added Phase 0: Privacy-by-Design Foundation including Data Promise, Data Inventory & Flows, Minimization Plan, STRIDE + Safety Threat Model, No-Human-Access Posture; Added G0 series compliance gates; Added PBD engineering tickets |

---

## Appendix A: Province-by-Province Requirements Matrix

| Province | Gate | Requirement | App Trigger | Legal Citation | Implementation Notes | Test Cases | Evidence |
|----------|------|-------------|-------------|----------------|---------------------|------------|----------|
| **All** | G0.1 | Data Promise published | App deployment | Best Practice | Patient-readable, verified against implementation | Accessibility test, readability test | Published document, verification report |
| **All** | G0.2 | Data inventory complete | New feature deployment | Best Practice | All PHI documented with flows | Inventory audit | Data inventory document |
| **All** | G0.3 | Minimization enforced | Form design | ON PHIPA s.30(2), SK HIPA s.23 | Necessity justification for each field | Field audit | Necessity matrix |
| **All** | G0.4 | Threat model maintained | Release cycle | Best Practice | STRIDE + safety threats | Model review | Threagile YAML |
| **All** | G0.5 | No-human-access enforced | System access | Best Practice | Support role cannot access PHI | RBAC test | Access config |
| **All** | G1 | PHI classified | Data schema design | All provincial PHI definitions | Tag all PHI fields | Classification audit | Data dictionary |
| **All** | G2 | Consent captured | Registration, sharing | ON PHIPA s.18, AB HIA s.34, MB PHIA s.19.1, SK HIPA s.5-7 | Express consent UI, versioning, audit trail | Consent flow test | Consent records |
| **ON** | G2 | Knowledgeable consent | Registration | PHIPA s.18(5) | Purpose statement, voluntary | UI review | Consent text |
| **AB** | G2 | Distinguish info types | Consent capture | HIA s.34-40 | Registration vs diagnostic/treatment | Consent scope test | Consent records |
| **All** | G3 | Collection minimized | Form submission | ON PHIPA s.30, SK HIPA s.23-24 | Only necessary fields, purpose stated | Field review | Necessity matrix |
| **All** | G4 | Use/disclosure controlled | Practitioner access | ON PHIPA s.29-38, AB HIA s.27-40 | RBAC, consent verification, patient controls | Access control test | Audit logs |
| **All** | G5 | Patient rights enabled | Profile access, export | ON PHIPA s.52-55, MB PHIA s.5-12 | View, export, correction request | Rights flow test | Export samples |
| **ON** | G5 | 30-day response | Access request | PHIPA s.54 | Response tracking | SLA monitoring | Response records |
| **All** | G6 | Safeguards implemented | All data operations | ON PHIPA s.12, MB PHIA s.18, SK HIPA s.16 | Encryption, MFA, audit logging | Security test | Pentest report |
| **All** | G7 | Breach response ready | Incident detection | ON PHIPA s.12(2-3), AB HIA s.60.1, PIPEDA s.10.1 | Detection, containment, notification | Tabletop exercise | IR plan, templates |
| **AB** | G7 | Risk of harm assessment | Breach determination | HIA s.60.1, Chapter 14 | Documented assessment | Assessment review | Assessment records |
| **All** | G8 | Retention/destruction | Record lifecycle | ON PHIPA s.13, SK HIPA s.17 | 10-year retention, secure deletion | Retention audit | Deletion certs |
| **All** | G9 | Vendor agreements | Vendor onboarding | ON PHIPA s.17, SK HIPA s.18, PE HIA s.41-43 | DPA with all vendors, audit rights | Contract review | Executed DPAs |
| **All** | G10 | Cross-border controlled | Data storage, sharing | ON PHIPA s.50, PE HIA s.35 | Canadian residency preferred, consent for cross-border | Residency audit | Data center docs |
| **All** | G11 | De-identification enforced | Analytics, research | ON PHIPA s.2, s.11.2 | No re-identification, analytics isolated | Analytics audit | De-ID methodology |
| **ON** | G12 | Minor/SDM handled | Minor registration, incapacity | PHIPA s.21-26 | Age verification, SDM workflow | Minor flow test | Age verification logs |
| **All** | G13 | Research blocked by default | Research request | ON PHIPA s.44 | No research without explicit pathway | Access control test | Policy document |
| **All** | G14 | Marketing prohibited | Marketing consideration | ON PHIPA s.32-33 | No PHI for marketing without express consent | Marketing audit | Policy document |
| **All** | G15 | Audit logging complete | All PHI operations | ON PHIPA s.10.1, s.16(2) | Comprehensive logging, immutable, 10-year retention | Log audit | Log samples |

---

## Appendix B: Harmonized National Baseline Summary

**Applying Strictest-Province Mode:** The following baseline represents the strictest requirements across all provided provinces. Compliance with this baseline satisfies all provincial requirements where sources were provided.

### Consent
- **Express consent required** for disclosure to non-custodians (ON PHIPA s.18(3))
- **Knowledgeable consent** with clear purpose statement (ON PHIPA s.18(5), MB PHIA s.19.1)
- **Withdrawal permitted** with non-retroactive effect (ON PHIPA s.19, SK HIPA s.7)
- **No deception/coercion** in obtaining consent (ON PHIPA s.18(1)(d), PIPEDA s.6.1)
- **Consent records retained** with timestamp and version (AB HIA s.34)

### Collection
- **Minimum necessary** only (ON PHIPA s.30(2), SK HIPA s.23)
- **Direct collection** preferred (MB PHIA s.14, SK HIPA s.25)
- **Purpose notice** at time of collection (ON PHIPA s.16, MB PHIA s.15)

### Security
- **Administrative, technical, physical safeguards** required (ON PHIPA s.12, MB PHIA s.18)
- **Encryption** at rest and in transit (Best Practice supporting PHIPA s.12)
- **Audit logging** for all PHI access (ON PHIPA s.10.1)
- **Access controls** with least privilege (AB HIA s.57-58)

### Breach Response
- **Individual notification** at first reasonable opportunity (ON PHIPA s.12(2), AB HIA s.60.1)
- **Commissioner notification** when thresholds met (ON PHIPA s.12(3), PIPEDA s.10.1)
- **Risk of harm assessment** (AB HIA s.60.1, PIPEDA s.10.1)
- **Breach records retained** 24 months minimum (PIPEDA s.10.3)

### Retention
- **Secure retention** for prescribed period (typically 10 years) (ON PHIPA s.13)
- **No destruction during access request** (ON PHIPA s.13(2))
- **Secure destruction** with verification (All provinces)

### Third Parties
- **Written agreements** required with all agents/service providers (ON PHIPA s.17, SK HIPA s.18)
- **Custodian remains responsible** for agent compliance (ON PHIPA s.17(3))

---

## Appendix C: Province Delta Packs

### Ontario Delta (vs. Baseline)
*Ontario requirements are largely captured in baseline. Additional considerations:*
- PHIPA s.54.1: Consumer electronic service provider provisions
- PHIPA s.23(1)2: Minor consent provisions (under 16, parent may consent except for treatment child decided on own)

### Alberta Delta (vs. Baseline)
- **HIA s.57-58:** Explicit "least amount of information" and "highest degree of anonymity" requirements
- **HIA s.60.1:** Minister notification in addition to Commissioner
- **HIA Chapter 14:** Detailed duty to notify procedures

### Manitoba Delta (vs. Baseline)
- **PHIA s.1:** "Trustee" terminology instead of "custodian"
- **PHIA s.25:** Information manager-specific duties

### Saskatchewan Delta (vs. Baseline)
- **HIPA s.2(j):** "Information Management Service Provider" terminology
- **HIPA s.17:** Explicit retention and destruction policy requirement
- **HIPA s.9:** Right to be informed provisions

### British Columbia Delta (vs. Baseline)
- **PIPA governs** private sector health information (not separate PHI act for private sector)
- **E-Health Act** applies to designated health information banks only
- **PIPA s.8:** Explicit implicit consent provisions

### New Brunswick Delta (vs. Baseline)
- **PHIPAA s.1:** "Data matching" defined and regulated
- **PHIPAA s.52:** Specific agent and information manager provisions

### Prince Edward Island Delta (vs. Baseline)
- **HIA s.41-43:** Detailed written agreement requirements for agents and information managers
- **HIA s.35:** Disclosure outside province provisions

### Nova Scotia Delta (vs. Baseline)
- **PHIA s.12-15:** Detailed knowledgeable implied consent provisions
- **PHIA s.21-23:** Comprehensive SDM hierarchy

### Newfoundland & Labrador Delta (vs. Baseline)
- **PHIA s.22:** Detailed information manager provisions
- **PHIA s.7:** Representative provisions
- **PHIA s.47:** Disclosure outside province provisions

### Quebec Delta (vs. Baseline)
- **P-39.1:** General private sector privacy law applies (not health-specific)
- **P-9.0001:** Health information sharing-specific provisions
- **Different terminology:** "Enterprise" vs. "custodian"
- **Commission d'accès à l'information** is regulator

### Federal (PIPEDA) Delta (vs. Baseline)
- **Applies to interprovincial/international transfers**
- **s.10.1-10.3:** Mandatory breach notification with "real risk of significant harm" threshold
- **s.10.3:** 24-month breach record retention
- **Schedule 1:** Fair Information Principles

---

**END OF DOCUMENT**

