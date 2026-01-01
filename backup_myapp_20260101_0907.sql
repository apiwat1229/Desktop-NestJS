--
-- PostgreSQL database dump
--

\restrict f7R8i9pD0Rzstx5sFgyzkF7EeyAXWE6aH53RDYiOQ7lPniiTKImO99E3jMbdCZR

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: ApprovalStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ApprovalStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'CANCELLED',
    'RETURNED',
    'EXPIRED',
    'VOID'
);


ALTER TYPE public."ApprovalStatus" OWNER TO postgres;

--
-- Name: NotificationStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."NotificationStatus" AS ENUM (
    'UNREAD',
    'READ',
    'ARCHIVED'
);


ALTER TYPE public."NotificationStatus" OWNER TO postgres;

--
-- Name: NotificationType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."NotificationType" AS ENUM (
    'INFO',
    'SUCCESS',
    'WARNING',
    'ERROR',
    'REQUEST',
    'APPROVE'
);


ALTER TYPE public."NotificationType" OWNER TO postgres;

--
-- Name: UserStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."UserStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'SUSPENDED',
    'PENDING'
);


ALTER TYPE public."UserStatus" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: NotificationGroup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."NotificationGroup" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    color text,
    icon text
);


ALTER TABLE public."NotificationGroup" OWNER TO postgres;

--
-- Name: _NotificationGroupMembers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_NotificationGroupMembers" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_NotificationGroupMembers" OWNER TO postgres;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: approval_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.approval_logs (
    id text NOT NULL,
    approval_request_id text NOT NULL,
    action text NOT NULL,
    old_value jsonb,
    new_value jsonb,
    actor_id text NOT NULL,
    actor_name text NOT NULL,
    actor_role text NOT NULL,
    remark text,
    ip_address text,
    user_agent text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.approval_logs OWNER TO postgres;

--
-- Name: approval_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.approval_requests (
    id text NOT NULL,
    reason text,
    status public."ApprovalStatus" DEFAULT 'PENDING'::public."ApprovalStatus" NOT NULL,
    requester_id text NOT NULL,
    approver_id text,
    submitted_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    acted_at timestamp(3) without time zone,
    action_type text NOT NULL,
    current_data jsonb,
    deleted_at timestamp(3) without time zone,
    deleted_by text,
    entity_id text NOT NULL,
    entity_type text NOT NULL,
    expires_at timestamp(3) without time zone,
    priority text DEFAULT 'NORMAL'::text NOT NULL,
    proposed_data jsonb,
    remark text,
    request_type text NOT NULL,
    source_app text NOT NULL
);


ALTER TABLE public.approval_requests OWNER TO postgres;

--
-- Name: bookings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bookings (
    id text NOT NULL,
    queue_no integer NOT NULL,
    booking_code text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    start_time text NOT NULL,
    end_time text NOT NULL,
    slot text,
    supplier_id text NOT NULL,
    supplier_code text NOT NULL,
    supplier_name text NOT NULL,
    truck_type text,
    truck_register text,
    rubber_type text NOT NULL,
    recorder text NOT NULL,
    checkin_at timestamp(3) without time zone,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deleted_at timestamp(3) without time zone,
    deleted_by text,
    note text,
    rubber_source text,
    start_drain_at timestamp(3) without time zone,
    stop_drain_at timestamp(3) without time zone,
    trailer_rubber_source text,
    trailer_rubber_type text,
    trailer_weight_in double precision,
    trailer_weight_out double precision,
    weight_in double precision,
    weight_out double precision,
    drain_note text
);


ALTER TABLE public.bookings OWNER TO postgres;

--
-- Name: districts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.districts (
    id integer NOT NULL,
    code text NOT NULL,
    name_th text NOT NULL,
    name_en text NOT NULL,
    province_id integer NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.districts OWNER TO postgres;

--
-- Name: notification_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_settings (
    id text NOT NULL,
    "sourceApp" text NOT NULL,
    "actionType" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "recipientRoles" jsonb DEFAULT '[]'::jsonb NOT NULL,
    "recipientUsers" jsonb DEFAULT '[]'::jsonb NOT NULL,
    channels jsonb DEFAULT '["IN_APP"]'::jsonb NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    "recipientGroups" jsonb DEFAULT '[]'::jsonb NOT NULL
);


ALTER TABLE public.notification_settings OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id text NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    type public."NotificationType" DEFAULT 'INFO'::public."NotificationType" NOT NULL,
    status public."NotificationStatus" DEFAULT 'UNREAD'::public."NotificationStatus" NOT NULL,
    user_id text NOT NULL,
    "sourceApp" text NOT NULL,
    "actionType" text NOT NULL,
    "entityId" text,
    "actionUrl" text,
    metadata jsonb,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    approval_request_id text,
    approval_status text
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posts (
    id text NOT NULL,
    title text NOT NULL,
    content text,
    published boolean DEFAULT false NOT NULL,
    "authorId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.posts OWNER TO postgres;

--
-- Name: provinces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provinces (
    id integer NOT NULL,
    code text NOT NULL,
    name_th text NOT NULL,
    name_en text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.provinces OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    icon text,
    color text,
    permissions text[] DEFAULT ARRAY[]::text[],
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: rubber_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rubber_types (
    id text NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    category text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    deleted_at timestamp(3) without time zone,
    deleted_by text
);


ALTER TABLE public.rubber_types OWNER TO postgres;

--
-- Name: subdistricts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subdistricts (
    id integer NOT NULL,
    code text NOT NULL,
    name_th text NOT NULL,
    name_en text NOT NULL,
    zip_code text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    district_id integer NOT NULL
);


ALTER TABLE public.subdistricts OWNER TO postgres;

--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    id text NOT NULL,
    code text NOT NULL,
    display_name text NOT NULL,
    tax_id text,
    address text,
    phone text,
    email text,
    province_id integer,
    district_id integer,
    subdistrict_id integer,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    notes text,
    rubber_type_codes text[] DEFAULT ARRAY[]::text[],
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    first_name text,
    last_name text,
    title text,
    avatar text,
    zip_code text,
    certificate_number text,
    certificate_expire timestamp(3) without time zone,
    score double precision DEFAULT 0,
    eudr_quota_used double precision,
    eudr_quota_current double precision,
    contact_person text,
    is_active boolean DEFAULT true NOT NULL,
    deleted_at timestamp(3) without time zone,
    deleted_by text
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- Name: user_app_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_app_permissions (
    id text NOT NULL,
    user_id text NOT NULL,
    "appName" text NOT NULL,
    actions jsonb NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.user_app_permissions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    avatar text,
    department text,
    display_name text,
    first_name text,
    hod_id text,
    last_name text,
    pin_code text,
    "position" text,
    status public."UserStatus" DEFAULT 'ACTIVE'::public."UserStatus" NOT NULL,
    username text,
    role text DEFAULT 'staff_1'::text NOT NULL,
    employee_id text,
    failed_login_attempts integer DEFAULT 0 NOT NULL,
    force_change_password boolean DEFAULT false NOT NULL,
    is_hod boolean DEFAULT false NOT NULL,
    last_login_at timestamp(3) without time zone,
    manager_id text,
    permissions jsonb DEFAULT '[]'::jsonb,
    preferences jsonb,
    site text,
    role_id text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: NotificationGroup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."NotificationGroup" (id, name, description, "isActive", "createdAt", "updatedAt", color, icon) FROM stdin;
b473a29f-1280-4731-a93d-a52ed9ad43a9	MANAGEMENT	\N	t	2025-12-31 08:30:36.153	2025-12-31 08:30:36.153	\N	\N
d7556630-4f1f-482b-ae40-de8c9f5b6a82	PRODUCTION	\N	t	2025-12-31 08:30:36.159	2025-12-31 08:30:36.159	\N	\N
1fa876e5-c557-42a6-bfdd-28ec4a9c539f	HR	\N	t	2025-12-31 08:30:36.165	2025-12-31 08:30:36.165	\N	\N
e62aef35-830d-4ee7-9202-b5678445ff7d	SALES	\N	t	2025-12-31 08:30:36.174	2025-12-31 08:30:36.174	\N	\N
e1c1aa73-5374-4303-958a-7500ce4b0ef0	IT	\N	t	2025-12-31 08:30:36.176	2025-12-31 08:30:36.176	\N	\N
\.


--
-- Data for Name: _NotificationGroupMembers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_NotificationGroupMembers" ("A", "B") FROM stdin;
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
ce06ea5e-6fda-4988-9833-82f446a0d80c	9fafc79c7ea0889f006db7b643e53e227a4984d3389b010c81333fc5fc956cbc	2025-12-31 08:10:01.987831+00	20251218134428_init	\N	\N	2025-12-31 08:10:01.971971+00	1
6028fd61-e391-4429-9347-9d5f450b07c4	e402659a6163bbe8d67d11dd4129daf5383cad3977db7361e3b21ba73d7fe4d0	2025-12-31 08:10:02.015139+00	20251220094916_add_roles_permissions	\N	\N	2025-12-31 08:10:01.988505+00	1
4a1e7e9f-bbf5-4bf1-81e4-d9605e04e2d6	031645a396650fb508184c4c77aff837139a19c12ccad12253141342e6319a94	2025-12-31 08:10:02.016807+00	20251220105502_add_contact_person_to_supplier	\N	\N	2025-12-31 08:10:02.015621+00	1
834f1600-63ff-41ce-b74c-2c5bb3759ce8	1fda42a8a37a41c6a81b816eb8e40a7647b4c71fd5fea7c8e9cac259379fb8d1	2025-12-31 08:10:02.018257+00	20251220105634_add_is_active_to_supplier	\N	\N	2025-12-31 08:10:02.017165+00	1
9eebacb2-976e-4563-9872-af98e41a4647	b45307151ab8f782518cbddfc97516c24776735db14f59a006ea7675bdb16e8c	2025-12-31 08:10:02.033414+00	20251221012119_init_app_notifications	\N	\N	2025-12-31 08:10:02.018651+00	1
b6b683bc-dda3-4567-bfd4-fe9126f87fe3	3ff1a0e600bd0cb4445978d372caf1bbbefc1706ea17ea1a3f0e40cdb5063451	2025-12-31 08:10:02.041519+00	20251221030806_add_notification_groups	\N	\N	2025-12-31 08:10:02.033868+00	1
439d9819-ad8c-487b-a367-e290f3b6769e	2842a71238cd2f7f1a2d4d7250f831dcb35c0c96879a84f728e7ead2ea5b48c7	2025-12-31 08:10:02.060989+00	20251224014801_add_approval_system	\N	\N	2025-12-31 08:10:02.042058+00	1
dc1474c5-1030-4778-a179-e518abe8e35c	d855f126b1d9ecbe14bc0def52c041efafe560866ebb58cb430ee826412df6c4	2025-12-31 08:10:02.063794+00	20251224084704_remove_unused_roles_table	\N	\N	2025-12-31 08:10:02.061484+00	1
b359d59f-4aef-45d9-ba7b-46025bb843d2	c50393a941fb5072f424b8755818f02c3d0bcbe63b6e56f6cb9c8a8544b2ee59	2025-12-31 08:10:02.065297+00	20251224092730_add_pending_user_status	\N	\N	2025-12-31 08:10:02.064199+00	1
f5c23f0a-36eb-460a-af44-1ec0cb24336f	fe1bc794eb8eaa9d54fcf35d14aec56c73e872b3ad8019b24032ee3c901a1265	2025-12-31 08:10:02.695698+00	20251231081002_add_trailer_fields	\N	\N	2025-12-31 08:10:02.684251+00	1
05c9b785-3feb-4067-8bdd-0b8e4b45c46a	a9ee7b2751d86e6d71a937684149552f69a8ad246b2751e9f4a59e11df6b1d29	2025-12-31 08:28:21.623581+00	20251231082821_add_drain_reason	\N	\N	2025-12-31 08:28:21.619604+00	1
\.


--
-- Data for Name: approval_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.approval_logs (id, approval_request_id, action, old_value, new_value, actor_id, actor_name, actor_role, remark, ip_address, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: approval_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.approval_requests (id, reason, status, requester_id, approver_id, submitted_at, acted_at, action_type, current_data, deleted_at, deleted_by, entity_id, entity_type, expires_at, priority, proposed_data, remark, request_type, source_app) FROM stdin;
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bookings (id, queue_no, booking_code, date, start_time, end_time, slot, supplier_id, supplier_code, supplier_name, truck_type, truck_register, rubber_type, recorder, checkin_at, created_at, updated_at, deleted_at, deleted_by, note, rubber_source, start_drain_at, stop_drain_at, trailer_rubber_source, trailer_rubber_type, trailer_weight_in, trailer_weight_out, weight_in, weight_out, drain_note) FROM stdin;
250266e1-1633-4bb9-947e-593b2baf8128	17	25123117	2025-12-31 00:00:00	13:00	14:00	13:00-14:00	196	0605	นางสาวอำพร ดำเชื้อ	10 ล้อ พ่วง	11223	Regular_CL	apiwat.s	2025-12-31 08:22:38.866	2025-12-31 08:20:57.21	2025-12-31 08:22:38.867	\N	\N		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9231aa90-af18-4a84-be5d-d7a1218719bc	1	25123101	2025-12-31 00:00:00	08:00	09:00	08:00-09:00	195	0603	นางเยาวลักษณ์ สมทรง	10 ล้อ พ่วง	55-1122	EUDR_CL	apiwat.s	2025-12-31 08:21:19.849	2025-12-31 08:20:35.511	2025-12-31 08:22:46.635	\N	\N		\N	2025-12-31 08:22:46.634	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: districts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.districts (id, code, name_th, name_en, province_id, created_at) FROM stdin;
1001	1001	เขตพระนคร	Khet Phra Nakhon	1	2025-12-18 04:35:37.254
1013	1013	เขตสัมพันธวงศ์	Khet Samphanthawong	1	2025-12-18 04:35:37.272
1015	1015	เขตธนบุรี	Khet Thon Buri	1	2025-12-18 04:35:37.274
1016	1016	เขตบางกอกใหญ่	Khet Bangkok Yai	1	2025-12-18 04:35:37.275
1017	1017	เขตห้วยขวาง	Khet Huai Khwang	1	2025-12-18 04:35:37.276
1018	1018	เขตคลองสาน	Khet Khlong San	1	2025-12-18 04:35:37.278
1019	1019	เขตตลิ่งชัน	Khet Taling Chan	1	2025-12-18 04:35:37.28
1020	1020	เขตบางกอกน้อย	Khet Bangkok Noi	1	2025-12-18 04:35:37.281
1021	1021	เขตบางขุนเทียน	Khet Bang Khun Thian	1	2025-12-18 04:35:37.282
1022	1022	เขตภาษีเจริญ	Khet Phasi Charoen	1	2025-12-18 04:35:37.284
1023	1023	เขตหนองแขม	Khet Nong Khaem	1	2025-12-18 04:35:37.286
1024	1024	เขตราษฎร์บูรณะ	Khet Rat Burana	1	2025-12-18 04:35:37.288
1025	1025	เขตบางพลัด	Khet Bang Phlat	1	2025-12-18 04:35:37.289
1026	1026	เขตดินแดง	Khet Din Daeng	1	2025-12-18 04:35:37.29
1027	1027	เขตบึงกุ่ม	Khet Bueng Kum	1	2025-12-18 04:35:37.291
1028	1028	เขตสาทร	Khet Sathon	1	2025-12-18 04:35:37.292
1029	1029	เขตบางซื่อ	Khet Bang Sue	1	2025-12-18 04:35:37.293
1030	1030	เขตจตุจักร	Khet Chatuchak	1	2025-12-18 04:35:37.294
1031	1031	เขตบางคอแหลม	Khet Bang Kho Laem	1	2025-12-18 04:35:37.295
1032	1032	เขตประเวศ	Khet Prawet	1	2025-12-18 04:35:37.296
1033	1033	เขตคลองเตย	Khet Khlong Toei	1	2025-12-18 04:35:37.297
1034	1034	เขตสวนหลวง	Khet Suan Luang	1	2025-12-18 04:35:37.298
1035	1035	เขตจอมทอง	Khet Chom Thong	1	2025-12-18 04:35:37.299
1036	1036	เขตดอนเมือง	Khet Don Mueang	1	2025-12-18 04:35:37.3
1037	1037	เขตราชเทวี	Khet Ratchathewi	1	2025-12-18 04:35:37.301
1038	1038	เขตลาดพร้าว	Khet Lat Phrao	1	2025-12-18 04:35:37.302
1039	1039	เขตวัฒนา	Khet Watthana	1	2025-12-18 04:35:37.303
1040	1040	เขตบางแค	Khet Bang Khae	1	2025-12-18 04:35:37.304
1041	1041	เขตหลักสี่	Khet Lak Si	1	2025-12-18 04:35:37.306
1042	1042	เขตสายไหม	Khet Sai Mai	1	2025-12-18 04:35:37.307
1043	1043	เขตคันนายาว	Khet Khan Na Yao	1	2025-12-18 04:35:37.308
1044	1044	เขตสะพานสูง	Khet Saphan Sung	1	2025-12-18 04:35:37.309
1045	1045	เขตวังทองหลาง	Khet Wang Thonglang	1	2025-12-18 04:35:37.311
1046	1046	เขตคลองสามวา	Khet Khlong Sam Wa	1	2025-12-18 04:35:37.312
1047	1047	เขตบางนา	Khet Bang Na	1	2025-12-18 04:35:37.313
1048	1048	เขตทวีวัฒนา	Khet Thawi Watthana	1	2025-12-18 04:35:37.314
1049	1049	เขตทุ่งครุ	Khet Thung Khru	1	2025-12-18 04:35:37.315
1050	1050	เขตบางบอน	Khet Bang Bon	1	2025-12-18 04:35:37.316
1101	1101	เมืองสมุทรปราการ	Mueang Samut Prakan	2	2025-12-18 04:35:37.317
1102	1102	บางบ่อ	Bang Bo	2	2025-12-18 04:35:37.318
1103	1103	บางพลี	Bang Phli	2	2025-12-18 04:35:37.319
1104	1104	พระประแดง	Phra Pradaeng	2	2025-12-18 04:35:37.32
1105	1105	พระสมุทรเจดีย์	Phra Samut Chedi	2	2025-12-18 04:35:37.321
1106	1106	บางเสาธง	Bang Sao Thong	2	2025-12-18 04:35:37.322
1201	1201	เมืองนนทบุรี	Mueang Nonthaburi	3	2025-12-18 04:35:37.323
1202	1202	บางกรวย	Bang Kruai	3	2025-12-18 04:35:37.324
1203	1203	บางใหญ่	Bang Yai	3	2025-12-18 04:35:37.325
1204	1204	บางบัวทอง	Bang Bua Thong	3	2025-12-18 04:35:37.326
1205	1205	ไทรน้อย	Sai Noi	3	2025-12-18 04:35:37.328
1206	1206	ปากเกร็ด	Pak Kret	3	2025-12-18 04:35:37.329
1301	1301	เมืองปทุมธานี	Mueang Pathum Thani	4	2025-12-18 04:35:37.332
1302	1302	คลองหลวง	Khlong Luang	4	2025-12-18 04:35:37.333
1303	1303	ธัญบุรี	Thanyaburi	4	2025-12-18 04:35:37.335
1304	1304	หนองเสือ	Nong Suea	4	2025-12-18 04:35:37.336
1305	1305	ลาดหลุมแก้ว	Lat Lum Kaeo	4	2025-12-18 04:35:37.337
1306	1306	ลำลูกกา	Lam Luk Ka	4	2025-12-18 04:35:37.339
1307	1307	สามโคก	Sam Khok	4	2025-12-18 04:35:37.34
1401	1401	พระนครศรีอยุธยา	Phra Nakhon Si Ayutthaya	5	2025-12-18 04:35:37.341
1402	1402	ท่าเรือ	Tha Ruea	5	2025-12-18 04:35:37.342
1403	1403	นครหลวง	Nakhon Luang	5	2025-12-18 04:35:37.343
1404	1404	บางไทร	Bang Sai	5	2025-12-18 04:35:37.345
1405	1405	บางบาล	Bang Ban	5	2025-12-18 04:35:37.346
1406	1406	บางปะอิน	Bang Pa-in	5	2025-12-18 04:35:37.347
1408	1408	ผักไห่	Phak Hai	5	2025-12-18 04:35:37.35
1409	1409	ภาชี	Phachi	5	2025-12-18 04:35:37.351
1410	1410	ลาดบัวหลวง	Lat Bua Luang	5	2025-12-18 04:35:37.352
1411	1411	วังน้อย	Wang Noi	5	2025-12-18 04:35:37.353
1412	1412	เสนา	Sena	5	2025-12-18 04:35:37.354
1413	1413	บางซ้าย	Bang Sai	5	2025-12-18 04:35:37.355
1414	1414	อุทัย	Uthai	5	2025-12-18 04:35:37.356
1415	1415	มหาราช	Maha Rat	5	2025-12-18 04:35:37.357
1416	1416	บ้านแพรก	Ban Phraek	5	2025-12-18 04:35:37.358
1501	1501	เมืองอ่างทอง	Mueang Ang Thong	6	2025-12-18 04:35:37.359
1502	1502	ไชโย	Chaiyo	6	2025-12-18 04:35:37.36
1503	1503	ป่าโมก	Pa Mok	6	2025-12-18 04:35:37.361
1504	1504	โพธิ์ทอง	Pho Thong	6	2025-12-18 04:35:37.362
1505	1505	แสวงหา	Sawaeng Ha	6	2025-12-18 04:35:37.363
1506	1506	วิเศษชัยชาญ	Wiset Chai Chan	6	2025-12-18 04:35:37.364
1507	1507	สามโก้	Samko	6	2025-12-18 04:35:37.365
1601	1601	เมืองลพบุรี	Mueang Lop Buri	7	2025-12-18 04:35:37.366
1602	1602	พัฒนานิคม	Phatthana Nikhom	7	2025-12-18 04:35:37.367
1603	1603	โคกสำโรง	Khok Samrong	7	2025-12-18 04:35:37.368
1604	1604	ชัยบาดาล	Chai Badan	7	2025-12-18 04:35:37.369
1605	1605	ท่าวุ้ง	Tha Wung	7	2025-12-18 04:35:37.37
1606	1606	บ้านหมี่	Ban Mi	7	2025-12-18 04:35:37.372
1607	1607	ท่าหลวง	Tha Luang	7	2025-12-18 04:35:37.373
1608	1608	สระโบสถ์	Sa Bot	7	2025-12-18 04:35:37.374
1609	1609	โคกเจริญ	Khok Charoen	7	2025-12-18 04:35:37.376
1610	1610	ลำสนธิ	Lam Sonthi	7	2025-12-18 04:35:37.377
1611	1611	หนองม่วง	Nong Muang	7	2025-12-18 04:35:37.378
1701	1701	เมืองสิงห์บุรี	Mueang Sing Buri	8	2025-12-18 04:35:37.379
1702	1702	บางระจัน	Bang Rachan	8	2025-12-18 04:35:37.381
1703	1703	ค่ายบางระจัน	Khai Bang Rachan	8	2025-12-18 04:35:37.382
1704	1704	พรหมบุรี	Phrom Buri	8	2025-12-18 04:35:37.383
1705	1705	ท่าช้าง	Tha Chang	8	2025-12-18 04:35:37.384
1706	1706	อินทร์บุรี	In Buri	8	2025-12-18 04:35:37.385
1801	1801	เมืองชัยนาท	Mueang Chai Nat	9	2025-12-18 04:35:37.386
1802	1802	มโนรมย์	Manorom	9	2025-12-18 04:35:37.387
1803	1803	วัดสิงห์	Wat Sing	9	2025-12-18 04:35:37.388
1804	1804	สรรพยา	Sapphaya	9	2025-12-18 04:35:37.389
1805	1805	สรรคบุรี	Sankhaburi	9	2025-12-18 04:35:37.39
1806	1806	หันคา	Hankha	9	2025-12-18 04:35:37.391
1807	1807	หนองมะโมง	Nong Mamong	9	2025-12-18 04:35:37.392
1808	1808	เนินขาม	Noen Kham	9	2025-12-18 04:35:37.393
1901	1901	เมืองสระบุรี	Mueang Saraburi	10	2025-12-18 04:35:37.394
1902	1902	แก่งคอย	Kaeng Khoi	10	2025-12-18 04:35:37.395
1903	1903	หนองแค	Nong Khae	10	2025-12-18 04:35:37.396
1904	1904	วิหารแดง	Wihan Daeng	10	2025-12-18 04:35:37.397
1905	1905	หนองแซง	Nong Saeng	10	2025-12-18 04:35:37.398
1906	1906	บ้านหมอ	Ban Mo	10	2025-12-18 04:35:37.399
1907	1907	ดอนพุด	Don Phut	10	2025-12-18 04:35:37.4
1908	1908	หนองโดน	Nong Don	10	2025-12-18 04:35:37.401
1909	1909	พระพุทธบาท	Phra Phutthabat	10	2025-12-18 04:35:37.402
1910	1910	เสาไห้	Sao Hai	10	2025-12-18 04:35:37.403
1911	1911	มวกเหล็ก	Muak Lek	10	2025-12-18 04:35:37.404
1912	1912	วังม่วง	Wang Muang	10	2025-12-18 04:35:37.405
1913	1913	เฉลิมพระเกียรติ	Chaloem Phra Kiat	10	2025-12-18 04:35:37.406
2001	2001	เมืองชลบุรี	Mueang Chon Buri	11	2025-12-18 04:35:37.407
2002	2002	บ้านบึง	Ban Bueng	11	2025-12-18 04:35:37.408
2003	2003	หนองใหญ่	Nong Yai	11	2025-12-18 04:35:37.409
2004	2004	บางละมุง	Bang Lamung	11	2025-12-18 04:35:37.41
2005	2005	พานทอง	Phan Thong	11	2025-12-18 04:35:37.411
2006	2006	พนัสนิคม	Phanat Nikhom	11	2025-12-18 04:35:37.412
2007	2007	ศรีราชา	Si Racha	11	2025-12-18 04:35:37.413
2008	2008	เกาะสีชัง	Ko Sichang	11	2025-12-18 04:35:37.414
2009	2009	สัตหีบ	Sattahip	11	2025-12-18 04:35:37.415
2010	2010	บ่อทอง	Bo Thong	11	2025-12-18 04:35:37.416
2011	2011	เกาะจันทร์	Ko Chan	11	2025-12-18 04:35:37.417
2101	2101	เมืองระยอง	Mueang Rayong	12	2025-12-18 04:35:37.418
2102	2102	บ้านฉาง	Ban Chang	12	2025-12-18 04:35:37.419
2103	2103	แกลง	Klaeng	12	2025-12-18 04:35:37.42
2104	2104	วังจันทร์	Wang Chan	12	2025-12-18 04:35:37.421
2105	2105	บ้านค่าย	Ban Khai	12	2025-12-18 04:35:37.421
2106	2106	ปลวกแดง	Pluak Daeng	12	2025-12-18 04:35:37.422
2107	2107	เขาชะเมา	Khao Chamao	12	2025-12-18 04:35:37.423
2108	2108	นิคมพัฒนา	Nikhom Phatthana	12	2025-12-18 04:35:37.424
2201	2201	เมืองจันทบุรี	Mueang Chanthaburi	13	2025-12-18 04:35:37.425
2202	2202	ขลุง	Khlung	13	2025-12-18 04:35:37.426
2203	2203	ท่าใหม่	Tha Mai	13	2025-12-18 04:35:37.427
2204	2204	โป่งน้ำร้อน	Pong Nam Ron	13	2025-12-18 04:35:37.428
2206	2206	แหลมสิงห์	Laem Sing	13	2025-12-18 04:35:37.43
2207	2207	สอยดาว	Soi Dao	13	2025-12-18 04:35:37.431
2208	2208	แก่งหางแมว	Kaeng Hang Maeo	13	2025-12-18 04:35:37.432
2209	2209	นายายอาม	Na Yai Am	13	2025-12-18 04:35:37.433
2210	2210	เขาคิชฌกูฏ	Khoa Khitchakut	13	2025-12-18 04:35:37.434
2301	2301	เมืองตราด	Mueang Trat	14	2025-12-18 04:35:37.435
2302	2302	คลองใหญ่	Khlong Yai	14	2025-12-18 04:35:37.436
2303	2303	เขาสมิง	Khao Saming	14	2025-12-18 04:35:37.437
2304	2304	บ่อไร่	Bo Rai	14	2025-12-18 04:35:37.438
2305	2305	แหลมงอบ	Laem Ngop	14	2025-12-18 04:35:37.439
2306	2306	เกาะกูด	Ko Kut	14	2025-12-18 04:35:37.44
2307	2307	เกาะช้าง	Ko Chang	14	2025-12-18 04:35:37.441
2401	2401	เมืองฉะเชิงเทรา	Mueang Chachoengsao	15	2025-12-18 04:35:37.441
2402	2402	บางคล้า	Bang Khla	15	2025-12-18 04:35:37.442
2403	2403	บางน้ำเปรี้ยว	Bang Nam Priao	15	2025-12-18 04:35:37.443
2404	2404	บางปะกง	Bang Pakong	15	2025-12-18 04:35:37.444
2405	2405	บ้านโพธิ์	Ban Pho	15	2025-12-18 04:35:37.445
2406	2406	พนมสารคาม	Phanom Sarakham	15	2025-12-18 04:35:37.446
2407	2407	ราชสาส์น	Ratchasan	15	2025-12-18 04:35:37.447
2408	2408	สนามชัยเขต	Sanam Chai Khet	15	2025-12-18 04:35:37.448
2409	2409	แปลงยาว	Plaeng Yao	15	2025-12-18 04:35:37.449
2410	2410	ท่าตะเกียบ	Tha Takiap	15	2025-12-18 04:35:37.45
2411	2411	คลองเขื่อน	Khlong Khuean	15	2025-12-18 04:35:37.451
2501	2501	เมืองปราจีนบุรี	Mueang Prachin Buri	16	2025-12-18 04:35:37.452
2502	2502	กบินทร์บุรี	Kabin Buri	16	2025-12-18 04:35:37.453
2503	2503	นาดี	Na Di	16	2025-12-18 04:35:37.454
2506	2506	บ้านสร้าง	Ban Sang	16	2025-12-18 04:35:37.455
2507	2507	ประจันตคาม	Prachantakham	16	2025-12-18 04:35:37.456
2508	2508	ศรีมหาโพธิ	Si Maha Phot	16	2025-12-18 04:35:37.457
2509	2509	ศรีมโหสถ	Si Mahosot	16	2025-12-18 04:35:37.458
2601	2601	เมืองนครนายก	Mueang Nakhon Nayok	17	2025-12-18 04:35:37.459
2602	2602	ปากพลี	Pak Phli	17	2025-12-18 04:35:37.46
2603	2603	บ้านนา	Ban Na	17	2025-12-18 04:35:37.46
2604	2604	องครักษ์	Ongkharak	17	2025-12-18 04:35:37.461
2701	2701	เมืองสระแก้ว	Mueang Sa Kaeo	18	2025-12-18 04:35:37.462
2702	2702	คลองหาด	Khlong Hat	18	2025-12-18 04:35:37.463
2703	2703	ตาพระยา	Ta Phraya	18	2025-12-18 04:35:37.464
2704	2704	วังน้ำเย็น	Wang Nam Yen	18	2025-12-18 04:35:37.465
2705	2705	วัฒนานคร	Watthana Nakhon	18	2025-12-18 04:35:37.466
2706	2706	อรัญประเทศ	Aranyaprathet	18	2025-12-18 04:35:37.467
2707	2707	เขาฉกรรจ์	Khao Chakan	18	2025-12-18 04:35:37.468
2708	2708	โคกสูง	Khok Sung	18	2025-12-18 04:35:37.469
2709	2709	วังสมบูรณ์	Wang Sombun	18	2025-12-18 04:35:37.47
3001	3001	เมืองนครราชสีมา	Mueang Nakhon Ratchasima	19	2025-12-18 04:35:37.471
3002	3002	ครบุรี	Khon Buri	19	2025-12-18 04:35:37.472
3003	3003	เสิงสาง	Soeng Sang	19	2025-12-18 04:35:37.473
3004	3004	คง	Khong	19	2025-12-18 04:35:37.474
3005	3005	บ้านเหลื่อม	Ban Lueam	19	2025-12-18 04:35:37.475
3006	3006	จักราช	Chakkarat	19	2025-12-18 04:35:37.476
3007	3007	โชคชัย	Chok Chai	19	2025-12-18 04:35:37.477
3008	3008	ด่านขุนทด	Dan Khun Thot	19	2025-12-18 04:35:37.478
3009	3009	โนนไทย	Non Thai	19	2025-12-18 04:35:37.479
3010	3010	โนนสูง	Non Sung	19	2025-12-18 04:35:37.48
3011	3011	ขามสะแกแสง	Kham Sakaesaeng	19	2025-12-18 04:35:37.481
3012	3012	บัวใหญ่	Bua Yai	19	2025-12-18 04:35:37.482
3013	3013	ประทาย	Prathai	19	2025-12-18 04:35:37.483
3014	3014	ปักธงชัย	Pak Thong Chai	19	2025-12-18 04:35:37.484
3015	3015	พิมาย	Phimai	19	2025-12-18 04:35:37.485
3016	3016	ห้วยแถลง	Huai Thalaeng	19	2025-12-18 04:35:37.486
3017	3017	ชุมพวง	Chum Phuang	19	2025-12-18 04:35:37.487
3018	3018	สูงเนิน	Sung Noen	19	2025-12-18 04:35:37.488
3019	3019	ขามทะเลสอ	Kham Thale So	19	2025-12-18 04:35:37.489
3020	3020	สีคิ้ว	Sikhio	19	2025-12-18 04:35:37.49
3021	3021	ปากช่อง	Pak Chong	19	2025-12-18 04:35:37.491
3022	3022	หนองบุญมาก	Nong Bunnak	19	2025-12-18 04:35:37.492
3023	3023	แก้งสนามนาง	Kaeng Sanam Nang	19	2025-12-18 04:35:37.493
3024	3024	โนนแดง	Non Daeng	19	2025-12-18 04:35:37.494
3025	3025	วังน้ำเขียว	Wang Nam Khiao	19	2025-12-18 04:35:37.495
3026	3026	เทพารักษ์	Thepharak	19	2025-12-18 04:35:37.496
3027	3027	เมืองยาง	Mueang Yang	19	2025-12-18 04:35:37.497
3028	3028	พระทองคำ	Phra Thong Kham	19	2025-12-18 04:35:37.498
3029	3029	ลำทะเมนชัย	Lam Thamenchai	19	2025-12-18 04:35:37.499
3030	3030	บัวลาย	Bua Lai	19	2025-12-18 04:35:37.5
3032	3032	เฉลิมพระเกียรติ	Chaloem Phra Kiat	19	2025-12-18 04:35:37.502
3101	3101	เมืองบุรีรัมย์	Mueang Buri Ram	20	2025-12-18 04:35:37.503
3102	3102	คูเมือง	Khu Mueang	20	2025-12-18 04:35:37.504
3103	3103	กระสัง	Krasang	20	2025-12-18 04:35:37.505
3104	3104	นางรอง	Nang Rong	20	2025-12-18 04:35:37.506
3105	3105	หนองกี่	Nong Ki	20	2025-12-18 04:35:37.507
3106	3106	ละหานทราย	Lahan Sai	20	2025-12-18 04:35:37.509
3107	3107	ประโคนชัย	Prakhon Chai	20	2025-12-18 04:35:37.51
3108	3108	บ้านกรวด	Ban Kruat	20	2025-12-18 04:35:37.511
3109	3109	พุทไธสง	Phutthaisong	20	2025-12-18 04:35:37.512
3110	3110	ลำปลายมาศ	Lam Plai Mat	20	2025-12-18 04:35:37.513
3111	3111	สตึก	Satuek	20	2025-12-18 04:35:37.514
3112	3112	ปะคำ	Pakham	20	2025-12-18 04:35:37.515
3113	3113	นาโพธิ์	Na Pho	20	2025-12-18 04:35:37.516
3114	3114	หนองหงส์	Nong Hong	20	2025-12-18 04:35:37.518
3115	3115	พลับพลาชัย	Phlapphla Chai	20	2025-12-18 04:35:37.519
3116	3116	ห้วยราช	Huai Rat	20	2025-12-18 04:35:37.519
3117	3117	โนนสุวรรณ	Non Suwan	20	2025-12-18 04:35:37.52
3118	3118	ชำนิ	Chamni	20	2025-12-18 04:35:37.521
3119	3119	บ้านใหม่ไชยพจน์	Ban Mai Chaiyaphot	20	2025-12-18 04:35:37.523
3120	3120	โนนดินแดง	Din Daeng	20	2025-12-18 04:35:37.523
3121	3121	บ้านด่าน	Ban Dan	20	2025-12-18 04:35:37.525
3122	3122	แคนดง	Khaen Dong	20	2025-12-18 04:35:37.526
3123	3123	เฉลิมพระเกียรติ	Chaloem Phra Kiat	20	2025-12-18 04:35:37.527
3201	3201	เมืองสุรินทร์	Mueang Surin	21	2025-12-18 04:35:37.528
3202	3202	ชุมพลบุรี	Chumphon Buri	21	2025-12-18 04:35:37.529
3203	3203	ท่าตูม	Tha Tum	21	2025-12-18 04:35:37.53
3204	3204	จอมพระ	Chom Phra	21	2025-12-18 04:35:37.531
3205	3205	ปราสาท	Prasat	21	2025-12-18 04:35:37.532
3206	3206	กาบเชิง	Kap Choeng	21	2025-12-18 04:35:37.533
3207	3207	รัตนบุรี	Rattanaburi	21	2025-12-18 04:35:37.534
3208	3208	สนม	Sanom	21	2025-12-18 04:35:37.535
3209	3209	ศีขรภูมิ	Sikhoraphum	21	2025-12-18 04:35:37.535
3210	3210	สังขะ	Sangkha	21	2025-12-18 04:35:37.537
3211	3211	ลำดวน	Lamduan	21	2025-12-18 04:35:37.538
3212	3212	สำโรงทาบ	Samrong Thap	21	2025-12-18 04:35:37.539
3213	3213	บัวเชด	Buachet	21	2025-12-18 04:35:37.54
3214	3214	พนมดงรัก	Phanom Dong Rak	21	2025-12-18 04:35:37.541
3215	3215	ศรีณรงค์	Si Narong	21	2025-12-18 04:35:37.541
3216	3216	เขวาสินรินทร์	Khwao Sinarin	21	2025-12-18 04:35:37.542
3217	3217	โนนนารายณ์	Non Narai	21	2025-12-18 04:35:37.543
3301	3301	เมืองศรีสะเกษ	Mueang Si Sa Ket	22	2025-12-18 04:35:37.544
3302	3302	ยางชุมน้อย	Yang Chum Noi	22	2025-12-18 04:35:37.545
3303	3303	กันทรารมย์	Kanthararom	22	2025-12-18 04:35:37.546
3304	3304	กันทรลักษ์	Kantharalak	22	2025-12-18 04:35:37.548
3305	3305	ขุขันธ์	Khukhan	22	2025-12-18 04:35:37.548
3306	3306	ไพรบึง	Phrai Bueng	22	2025-12-18 04:35:37.549
3307	3307	ปรางค์กู่	Prang Ku	22	2025-12-18 04:35:37.55
3308	3308	ขุนหาญ	Khun Han	22	2025-12-18 04:35:37.551
3309	3309	ราษีไศล	Rasi Salai	22	2025-12-18 04:35:37.552
3310	3310	อุทุมพรพิสัย	Uthumphon Phisai	22	2025-12-18 04:35:37.553
3311	3311	บึงบูรพ์	Bueng Bun	22	2025-12-18 04:35:37.554
3312	3312	ห้วยทับทัน	Huai Thap Than	22	2025-12-18 04:35:37.555
3313	3313	โนนคูณ	Non Khun	22	2025-12-18 04:35:37.556
2205	2205	มะขาม	Makham	13	2025-12-18 04:35:37.429
3314	3314	ศรีรัตนะ	Si Rattana	22	2025-12-18 04:35:37.557
3315	3315	น้ำเกลี้ยง	Nam Kliang	22	2025-12-18 04:35:37.558
3316	3316	วังหิน	Wang Hin	22	2025-12-18 04:35:37.559
3317	3317	ภูสิงห์	Phu Sing	22	2025-12-18 04:35:37.56
3318	3318	เมืองจันทร์	Mueang Chan	22	2025-12-18 04:35:37.561
3319	3319	เบญจลักษ์	Benchalak	22	2025-12-18 04:35:37.562
3321	3321	โพธิ์ศรีสุวรรณ	Pho Si Suwan	22	2025-12-18 04:35:37.569
3322	3322	ศิลาลาด	Sila Lat	22	2025-12-18 04:35:37.571
3401	3401	เมืองอุบลราชธานี	Mueang Ubon Ratchathani	23	2025-12-18 04:35:37.572
3402	3402	ศรีเมืองใหม่	Si Mueang Mai	23	2025-12-18 04:35:37.575
3403	3403	โขงเจียม	Khong Chiam	23	2025-12-18 04:35:37.576
3404	3404	เขื่องใน	Khueang Nai	23	2025-12-18 04:35:37.577
3405	3405	เขมราฐ	Khemarat	23	2025-12-18 04:35:37.578
3407	3407	เดชอุดม	Det Udom	23	2025-12-18 04:35:37.579
3408	3408	นาจะหลวย	Na Chaluai	23	2025-12-18 04:35:37.58
3409	3409	น้ำยืน	Nam Yuen	23	2025-12-18 04:35:37.581
3410	3410	บุณฑริก	Buntharik	23	2025-12-18 04:35:37.582
3411	3411	ตระการพืชผล	Trakan Phuet Phon	23	2025-12-18 04:35:37.583
3412	3412	กุดข้าวปุ้น	Kut Khaopun	23	2025-12-18 04:35:37.584
3414	3414	ม่วงสามสิบ	Muang Sam Sip	23	2025-12-18 04:35:37.585
3415	3415	วารินชำราบ	Warin Chamrap	23	2025-12-18 04:35:37.586
3419	3419	พิบูลมังสาหาร	Phibun Mangsahan	23	2025-12-18 04:35:37.589
3420	3420	ตาลสุม	Tan Sum	23	2025-12-18 04:35:37.59
3421	3421	โพธิ์ไทร	Pho Sai	23	2025-12-18 04:35:37.591
3422	3422	สำโรง	Samrong	23	2025-12-18 04:35:37.592
3424	3424	ดอนมดแดง	Don Mot Daeng	23	2025-12-18 04:35:37.593
3425	3425	สิรินธร	Sirindhorn	23	2025-12-18 04:35:37.594
3426	3426	ทุ่งศรีอุดม	Thung Si Udom	23	2025-12-18 04:35:37.595
3429	3429	นาเยีย	Na Yia	23	2025-12-18 04:35:37.596
3430	3430	นาตาล	Na Tan	23	2025-12-18 04:35:37.597
3431	3431	เหล่าเสือโก้ก	Lao Suea Kok	23	2025-12-18 04:35:37.598
3432	3432	สว่างวีระวงศ์	Sawang Wirawong	23	2025-12-18 04:35:37.599
3433	3433	น้ำขุ่น	Nam Khun	23	2025-12-18 04:35:37.6
3501	3501	เมืองยโสธร	Mueang Yasothon	24	2025-12-18 04:35:37.601
3502	3502	ทรายมูล	Sai Mun	24	2025-12-18 04:35:37.602
3503	3503	กุดชุม	Kut Chum	24	2025-12-18 04:35:37.603
3504	3504	คำเขื่อนแก้ว	Kham Khuean Kaeo	24	2025-12-18 04:35:37.604
3505	3505	ป่าติ้ว	Pa Tio	24	2025-12-18 04:35:37.605
3506	3506	มหาชนะชัย	Maha Chana Chai	24	2025-12-18 04:35:37.606
3507	3507	ค้อวัง	Kho Wang	24	2025-12-18 04:35:37.607
3508	3508	เลิงนกทา	Loeng Nok Tha	24	2025-12-18 04:35:37.608
3509	3509	ไทยเจริญ	Thai Charoen	24	2025-12-18 04:35:37.609
3601	3601	เมืองชัยภูมิ	Mueang Chaiyaphum	25	2025-12-18 04:35:37.61
3602	3602	บ้านเขว้า	Ban Khwao	25	2025-12-18 04:35:37.611
3603	3603	คอนสวรรค์	Khon Sawan	25	2025-12-18 04:35:37.612
3604	3604	เกษตรสมบูรณ์	Kaset Sombun	25	2025-12-18 04:35:37.613
3605	3605	หนองบัวแดง	Nong Bua Daeng	25	2025-12-18 04:35:37.614
3606	3606	จัตุรัส	Chatturat	25	2025-12-18 04:35:37.615
3607	3607	บำเหน็จณรงค์	Bamnet Narong	25	2025-12-18 04:35:37.616
3608	3608	หนองบัวระเหว	Nong Bua Rawe	25	2025-12-18 04:35:37.617
3609	3609	เทพสถิต	Thep Sathit	25	2025-12-18 04:35:37.618
3610	3610	ภูเขียว	Phu Khiao	25	2025-12-18 04:35:37.619
3611	3611	บ้านแท่น	Ban Thaen	25	2025-12-18 04:35:37.62
3612	3612	แก้งคร้อ	Kaeng Khro	25	2025-12-18 04:35:37.621
3613	3613	คอนสาร	Khon San	25	2025-12-18 04:35:37.621
3614	3614	ภักดีชุมพล	Phakdi Chumphon	25	2025-12-18 04:35:37.622
3615	3615	เนินสง่า	Noen Sa-nga	25	2025-12-18 04:35:37.623
3616	3616	ซับใหญ่	Sap Yai	25	2025-12-18 04:35:37.624
3701	3701	เมืองอำนาจเจริญ	Mueang Amnat Charoen	26	2025-12-18 04:35:37.625
3702	3702	ชานุมาน	Chanuman	26	2025-12-18 04:35:37.626
3703	3703	ปทุมราชวงศา	Pathum Ratchawongsa	26	2025-12-18 04:35:37.627
3705	3705	เสนางคนิคม	Senangkhanikhom	26	2025-12-18 04:35:37.629
3706	3706	หัวตะพาน	Hua Taphan	26	2025-12-18 04:35:37.63
3707	3707	ลืออำนาจ	Lue Amnat	26	2025-12-18 04:35:37.631
3801	3801	เมืองบึงกาฬ	Mueang Bueng Kan	77	2025-12-18 04:35:37.632
3802	3802	เซกา	Seka	77	2025-12-18 04:35:37.633
3803	3803	โซ่พิสัย	So Phisai	77	2025-12-18 04:35:37.634
3804	3804	พรเจริญ	Phon Charoen	77	2025-12-18 04:35:37.635
3805	3805	ศรีวิไล	Si Wilai	77	2025-12-18 04:35:37.636
3806	3806	บึงโขงหลง	Bueng Khong Long	77	2025-12-18 04:35:37.637
3807	3807	ปากคาด	Pak Khat	77	2025-12-18 04:35:37.638
3808	3808	บุ่งคล้า	Bung Khla	77	2025-12-18 04:35:37.639
3901	3901	เมืองหนองบัวลำภู	Mueang Nong Bua Lam Phu	27	2025-12-18 04:35:37.64
3902	3902	นากลาง	Na Klang	27	2025-12-18 04:35:37.641
3903	3903	โนนสัง	Non Sang	27	2025-12-18 04:35:37.642
3904	3904	ศรีบุญเรือง	Si Bun Rueang	27	2025-12-18 04:35:37.643
3905	3905	สุวรรณคูหา	Suwannakhuha	27	2025-12-18 04:35:37.644
3906	3906	นาวัง	Na Wang	27	2025-12-18 04:35:37.645
4001	4001	เมืองขอนแก่น	Mueang Khon Kaen	28	2025-12-18 04:35:37.646
4002	4002	บ้านฝาง	Ban Fang	28	2025-12-18 04:35:37.647
4003	4003	พระยืน	Phra Yuen	28	2025-12-18 04:35:37.648
4004	4004	หนองเรือ	Nong Ruea	28	2025-12-18 04:35:37.649
4005	4005	ชุมแพ	Chum Phae	28	2025-12-18 04:35:37.65
4006	4006	สีชมพู	Si Chomphu	28	2025-12-18 04:35:37.651
4007	4007	น้ำพอง	Nam Phong	28	2025-12-18 04:35:37.652
4008	4008	อุบลรัตน์	Ubolratana	28	2025-12-18 04:35:37.653
4009	4009	กระนวน	Kranuan	28	2025-12-18 04:35:37.654
3031	3031	สีดา	Sida	19	2025-12-18 04:35:37.501
4010	4010	บ้านไผ่	Ban Phai	28	2025-12-18 04:35:37.654
4011	4011	เปือยน้อย	Pueai Noi	28	2025-12-18 04:35:37.656
4012	4012	พล	Phon	28	2025-12-18 04:35:37.657
4013	4013	แวงใหญ่	Waeng Yai	28	2025-12-18 04:35:37.658
4014	4014	แวงน้อย	Waeng Noi	28	2025-12-18 04:35:37.659
4015	4015	หนองสองห้อง	Nong Song Hong	28	2025-12-18 04:35:37.66
4016	4016	ภูเวียง	Phu Wiang	28	2025-12-18 04:35:37.661
4017	4017	มัญจาคีรี	Mancha Khiri	28	2025-12-18 04:35:37.662
4018	4018	ชนบท	Chonnabot	28	2025-12-18 04:35:37.663
4019	4019	เขาสวนกวาง	Khao Suan Kwang	28	2025-12-18 04:35:37.664
4020	4020	ภูผาม่าน	Phu Pha Man	28	2025-12-18 04:35:37.665
4021	4021	ซำสูง	Sam Sung	28	2025-12-18 04:35:37.666
4022	4022	โคกโพธิ์ไชย	Khok Pho Chai	28	2025-12-18 04:35:37.667
4023	4023	หนองนาคำ	Nong Na Kham	28	2025-12-18 04:35:37.667
4024	4024	บ้านแฮด	Ban Haet	28	2025-12-18 04:35:37.668
4025	4025	โนนศิลา	Non Sila	28	2025-12-18 04:35:37.669
4029	4029	เวียงเก่า	Wiang Kao	28	2025-12-18 04:35:37.67
4101	4101	เมืองอุดรธานี	Mueang Udon Thani	29	2025-12-18 04:35:37.671
4102	4102	กุดจับ	Kut Chap	29	2025-12-18 04:35:37.672
4103	4103	หนองวัวซอ	Nong Wua So	29	2025-12-18 04:35:37.673
4104	4104	กุมภวาปี	Kumphawapi	29	2025-12-18 04:35:37.674
4105	4105	โนนสะอาด	Non Sa-at	29	2025-12-18 04:35:37.675
4106	4106	หนองหาน	Nong Han	29	2025-12-18 04:35:37.676
4107	4107	ทุ่งฝน	Thung Fon	29	2025-12-18 04:35:37.677
4108	4108	ไชยวาน	Chai Wan	29	2025-12-18 04:35:37.678
4109	4109	ศรีธาตุ	Si That	29	2025-12-18 04:35:37.681
4110	4110	วังสามหมอ	Wang Sam Mo	29	2025-12-18 04:35:37.684
4111	4111	บ้านดุง	Ban Dung	29	2025-12-18 04:35:37.687
4117	4117	บ้านผือ	Ban Phue	29	2025-12-18 04:35:37.69
4118	4118	น้ำโสม	Nam Som	29	2025-12-18 04:35:37.692
4119	4119	เพ็ญ	Phen	29	2025-12-18 04:35:37.693
4120	4120	สร้างคอม	Sang Khom	29	2025-12-18 04:35:37.694
4121	4121	หนองแสง	Nong Saeng	29	2025-12-18 04:35:37.695
4122	4122	นายูง	Na Yung	29	2025-12-18 04:35:37.695
4123	4123	พิบูลย์รักษ์	Phibun Rak	29	2025-12-18 04:35:37.696
4124	4124	กู่แก้ว	Ku Kaeo	29	2025-12-18 04:35:37.697
4125	4125	ประจักษ์ศิลปาคม	rachak-sinlapakhom	29	2025-12-18 04:35:37.698
4201	4201	เมืองเลย	Mueang Loei	30	2025-12-18 04:35:37.7
4202	4202	นาด้วง	Na Duang	30	2025-12-18 04:35:37.7
4203	4203	เชียงคาน	Chiang Khan	30	2025-12-18 04:35:37.701
4204	4204	ปากชม	Pak Chom	30	2025-12-18 04:35:37.702
4205	4205	ด่านซ้าย	Dan Sai	30	2025-12-18 04:35:37.703
4206	4206	นาแห้ว	Na Haeo	30	2025-12-18 04:35:37.704
4207	4207	ภูเรือ	Phu Ruea	30	2025-12-18 04:35:37.705
4208	4208	ท่าลี่	Tha Li	30	2025-12-18 04:35:37.706
4209	4209	วังสะพุง	Wang Saphung	30	2025-12-18 04:35:37.707
4210	4210	ภูกระดึง	Phu Kradueng	30	2025-12-18 04:35:37.708
4211	4211	ภูหลวง	Phu Luang	30	2025-12-18 04:35:37.709
4212	4212	ผาขาว	Pha Khao	30	2025-12-18 04:35:37.71
4213	4213	เอราวัณ	Erawan	30	2025-12-18 04:35:37.711
4214	4214	หนองหิน	Nong Hin	30	2025-12-18 04:35:37.712
4301	4301	เมืองหนองคาย	Mueang Nong Khai	31	2025-12-18 04:35:37.712
4302	4302	ท่าบ่อ	Tha Bo	31	2025-12-18 04:35:37.713
4305	4305	โพนพิสัย	Phon Phisai	31	2025-12-18 04:35:37.715
4307	4307	ศรีเชียงใหม่	Si Chiang Mai	31	2025-12-18 04:35:37.715
4308	4308	สังคม	Sangkhom	31	2025-12-18 04:35:37.716
4314	4314	สระใคร	Sakhrai	31	2025-12-18 04:35:37.717
4315	4315	เฝ้าไร่	Fao Rai	31	2025-12-18 04:35:37.718
4316	4316	รัตนวาปี	Rattanawapi	31	2025-12-18 04:35:37.719
4317	4317	โพธิ์ตาก	Pho Tak	31	2025-12-18 04:35:37.72
4401	4401	เมืองมหาสารคาม	Mueang Maha Sarakham	32	2025-12-18 04:35:37.721
4402	4402	แกดำ	Kae Dam	32	2025-12-18 04:35:37.722
4403	4403	โกสุมพิสัย	Kosum Phisai	32	2025-12-18 04:35:37.723
4404	4404	กันทรวิชัย	Kantharawichai	32	2025-12-18 04:35:37.724
4405	4405	เชียงยืน	Kantharawichai	32	2025-12-18 04:35:37.725
4406	4406	บรบือ	Borabue	32	2025-12-18 04:35:37.726
4407	4407	นาเชือก	Na Chueak	32	2025-12-18 04:35:37.726
4408	4408	พยัคฆภูมิพิสัย	Phayakkhaphum Phisai	32	2025-12-18 04:35:37.727
4409	4409	วาปีปทุม	Wapi Pathum	32	2025-12-18 04:35:37.728
4410	4410	นาดูน	Na Dun	32	2025-12-18 04:35:37.729
4411	4411	ยางสีสุราช	Yang Sisurat	32	2025-12-18 04:35:37.73
4412	4412	กุดรัง	Kut Rang	32	2025-12-18 04:35:37.731
4413	4413	ชื่นชม	Chuen Chom	32	2025-12-18 04:35:37.732
4501	4501	เมืองร้อยเอ็ด	Mueang Roi Et	33	2025-12-18 04:35:37.733
4502	4502	เกษตรวิสัย	Kaset Wisai	33	2025-12-18 04:35:37.734
4503	4503	ปทุมรัตต์	Pathum Rat	33	2025-12-18 04:35:37.735
4504	4504	จตุรพักตรพิมาน	Chaturaphak Phiman	33	2025-12-18 04:35:37.736
4505	4505	ธวัชบุรี	Thawat Buri	33	2025-12-18 04:35:37.737
4506	4506	พนมไพร	Phanom Phrai	33	2025-12-18 04:35:37.738
4507	4507	โพนทอง	Phon Thong	33	2025-12-18 04:35:37.738
4508	4508	โพธิ์ชัย	Pho Chai	33	2025-12-18 04:35:37.74
4509	4509	หนองพอก	Nong Phok	33	2025-12-18 04:35:37.74
4510	4510	เสลภูมิ	Selaphum	33	2025-12-18 04:35:37.741
4511	4511	สุวรรณภูมิ	Suwannaphum	33	2025-12-18 04:35:37.742
4512	4512	เมืองสรวง	Mueang Suang	33	2025-12-18 04:35:37.743
4513	4513	โพนทราย	Phon Sai	33	2025-12-18 04:35:37.744
4514	4514	อาจสามารถ	At Samat	33	2025-12-18 04:35:37.745
4515	4515	เมยวดี	Moei Wadi	33	2025-12-18 04:35:37.746
4516	4516	ศรีสมเด็จ	Si Somdet	33	2025-12-18 04:35:37.747
4517	4517	จังหาร	Changhan	33	2025-12-18 04:35:37.748
4518	4518	เชียงขวัญ	Chiang Khwan	33	2025-12-18 04:35:37.749
4519	4519	หนองฮี	Nong Hi	33	2025-12-18 04:35:37.75
4904	4904	ดงหลวง	Dong Luang	37	2025-12-18 04:35:37.798
4520	4520	ทุ่งเขาหลวง	Thung Khao Luangกิ่	33	2025-12-18 04:35:37.751
4601	4601	เมืองกาฬสินธุ์	Mueang Kalasin	34	2025-12-18 04:35:37.752
4602	4602	นามน	Na Mon	34	2025-12-18 04:35:37.753
4603	4603	กมลาไสย	Kamalasai	34	2025-12-18 04:35:37.754
4604	4604	ร่องคำ	Rong Kham	34	2025-12-18 04:35:37.754
4605	4605	กุฉินารายณ์	Kuchinarai	34	2025-12-18 04:35:37.755
4606	4606	เขาวง	Khao Wong	34	2025-12-18 04:35:37.756
4607	4607	ยางตลาด	Yang Talat	34	2025-12-18 04:35:37.757
4608	4608	ห้วยเม็ก	Huai Mek	34	2025-12-18 04:35:37.758
4609	4609	สหัสขันธ์	Sahatsakhan	34	2025-12-18 04:35:37.759
4610	4610	คำม่วง	Kham Muang	34	2025-12-18 04:35:37.76
4611	4611	ท่าคันโท	Tha Khantho	34	2025-12-18 04:35:37.761
4612	4612	หนองกุงศรี	Nong Kung Si	34	2025-12-18 04:35:37.762
4613	4613	สมเด็จ	Somdet	34	2025-12-18 04:35:37.763
4614	4614	ห้วยผึ้ง	Huai Phueng	34	2025-12-18 04:35:37.764
4615	4615	สามชัย	Sam Chai	34	2025-12-18 04:35:37.764
4616	4616	นาคู	Na Khu	34	2025-12-18 04:35:37.766
4617	4617	ดอนจาน	Don Chan	34	2025-12-18 04:35:37.767
4618	4618	ฆ้องชัย	Khong Chai	34	2025-12-18 04:35:37.767
4701	4701	เมืองสกลนคร	Mueang Sakon Nakhon	35	2025-12-18 04:35:37.768
4702	4702	กุสุมาลย์	Kusuman	35	2025-12-18 04:35:37.769
4703	4703	กุดบาก	Kut Bak	35	2025-12-18 04:35:37.77
4704	4704	พรรณานิคม	Phanna Nikhom	35	2025-12-18 04:35:37.771
4705	4705	พังโคน	Phang Khon	35	2025-12-18 04:35:37.772
4706	4706	วาริชภูมิ	Waritchaphum	35	2025-12-18 04:35:37.773
4707	4707	นิคมน้ำอูน	Nikhom Nam Un	35	2025-12-18 04:35:37.774
4708	4708	วานรนิวาส	Wanon Niwat	35	2025-12-18 04:35:37.775
4709	4709	คำตากล้า	Kham Ta Kla	35	2025-12-18 04:35:37.776
4710	4710	บ้านม่วง	Ban Muang	35	2025-12-18 04:35:37.777
4711	4711	อากาศอำนวย	Akat Amnuai	35	2025-12-18 04:35:37.778
4712	4712	สว่างแดนดิน	Sawang Daen Din	35	2025-12-18 04:35:37.778
4713	4713	ส่องดาว	Song Dao	35	2025-12-18 04:35:37.779
4714	4714	เต่างอย	Tao Ngoi	35	2025-12-18 04:35:37.78
4715	4715	โคกศรีสุพรรณ	Khok Si Suphan	35	2025-12-18 04:35:37.781
4716	4716	เจริญศิลป์	Charoen Sin	35	2025-12-18 04:35:37.782
4717	4717	โพนนาแก้ว	Phon Na Kaeo	35	2025-12-18 04:35:37.783
4718	4718	ภูพาน	Phu Phan	35	2025-12-18 04:35:37.784
4801	4801	เมืองนครพนม	Mueang Nakhon Phanom	36	2025-12-18 04:35:37.785
4802	4802	ปลาปาก	Pla Pak	36	2025-12-18 04:35:37.786
4803	4803	ท่าอุเทน	Tha Uthen	36	2025-12-18 04:35:37.787
4804	4804	บ้านแพง	Ban Phaeng	36	2025-12-18 04:35:37.788
4805	4805	ธาตุพนม	That Phanom	36	2025-12-18 04:35:37.788
4806	4806	เรณูนคร	Renu Nakhon	36	2025-12-18 04:35:37.789
4807	4807	นาแก	Na Kae	36	2025-12-18 04:35:37.79
4808	4808	ศรีสงคราม	Si Songkhram	36	2025-12-18 04:35:37.791
4809	4809	นาหว้า	Na Wa	36	2025-12-18 04:35:37.792
4810	4810	โพนสวรรค์	Phon Sawan	36	2025-12-18 04:35:37.793
4811	4811	นาทม	Na Thom	36	2025-12-18 04:35:37.794
4812	4812	วังยาง	Wang Yang	36	2025-12-18 04:35:37.795
4901	4901	เมืองมุกดาหาร	Mueang Mukdahan	37	2025-12-18 04:35:37.796
4902	4902	นิคมคำสร้อย	Nikhom Kham Soi	37	2025-12-18 04:35:37.797
4903	4903	ดอนตาล	Don Tan	37	2025-12-18 04:35:37.798
4905	4905	คำชะอี	Khamcha-i	37	2025-12-18 04:35:37.799
4906	4906	หว้านใหญ่	Wan Yai	37	2025-12-18 04:35:37.8
4907	4907	หนองสูง	Nong Sung	37	2025-12-18 04:35:37.801
5001	5001	เมืองเชียงใหม่	Mueang Chiang Mai	38	2025-12-18 04:35:37.802
5002	5002	จอมทอง	Chom Thong	38	2025-12-18 04:35:37.803
5003	5003	แม่แจ่ม	Mae Chaem	38	2025-12-18 04:35:37.804
5004	5004	เชียงดาว	Chiang Dao	38	2025-12-18 04:35:37.805
5005	5005	ดอยสะเก็ด	Doi Saket	38	2025-12-18 04:35:37.806
5006	5006	แม่แตง	Mae Taeng	38	2025-12-18 04:35:37.807
5007	5007	แม่ริม	Mae Rim	38	2025-12-18 04:35:37.807
5008	5008	สะเมิง	Samoeng	38	2025-12-18 04:35:37.808
5009	5009	ฝาง	Fang	38	2025-12-18 04:35:37.809
5010	5010	แม่อาย	Mae Ai	38	2025-12-18 04:35:37.81
5011	5011	พร้าว	Phrao	38	2025-12-18 04:35:37.811
5012	5012	สันป่าตอง	San Pa Tong	38	2025-12-18 04:35:37.812
5013	5013	สันกำแพง	San Kamphaeng	38	2025-12-18 04:35:37.813
5014	5014	สันทราย	San Sai	38	2025-12-18 04:35:37.814
5015	5015	หางดง	Hang Dong	38	2025-12-18 04:35:37.816
5016	5016	ฮอด	Hot	38	2025-12-18 04:35:37.817
5017	5017	ดอยเต่า	Doi Tao	38	2025-12-18 04:35:37.819
5018	5018	อมก๋อย	Omkoi	38	2025-12-18 04:35:37.82
5019	5019	สารภี	Saraphi	38	2025-12-18 04:35:37.821
5020	5020	เวียงแหง	Wiang Haeng	38	2025-12-18 04:35:37.822
5021	5021	ไชยปราการ	Chai Prakan	38	2025-12-18 04:35:37.823
5022	5022	แม่วาง	Mae Wang	38	2025-12-18 04:35:37.825
5023	5023	แม่ออน	Mae On	38	2025-12-18 04:35:37.826
5024	5024	ดอยหล่อ	Doi Lo	38	2025-12-18 04:35:37.827
5101	5101	เมืองลำพูน	Mueang Lamphun	39	2025-12-18 04:35:37.828
5102	5102	แม่ทา	Mae Tha	39	2025-12-18 04:35:37.829
5103	5103	บ้านโฮ่ง	Ban Hong	39	2025-12-18 04:35:37.831
5104	5104	ลี้	Li	39	2025-12-18 04:35:37.832
5105	5105	ทุ่งหัวช้าง	Thung Hua Chang	39	2025-12-18 04:35:37.833
5106	5106	ป่าซาง	Pa Sang	39	2025-12-18 04:35:37.834
5108	5108	เวียงหนองล่อง	Wiang Nong Long	39	2025-12-18 04:35:37.837
5201	5201	เมืองลำปาง	Mueang Lampang	40	2025-12-18 04:35:37.838
5202	5202	แม่เมาะ	Mae Mo	40	2025-12-18 04:35:37.84
5203	5203	เกาะคา	Ko Kha	40	2025-12-18 04:35:37.841
5204	5204	เสริมงาม	Soem Ngam	40	2025-12-18 04:35:37.843
5205	5205	งาว	Ngao	40	2025-12-18 04:35:37.844
1407	1407	บางปะหัน	Bang Pahan	5	2025-12-18 04:35:37.349
5206	5206	แจ้ห่ม	Chae Hom	40	2025-12-18 04:35:37.845
5207	5207	วังเหนือ	Wang Nuea	40	2025-12-18 04:35:37.846
5208	5208	เถิน	Thoen	40	2025-12-18 04:35:37.848
5209	5209	แม่พริก	Mae Phrik	40	2025-12-18 04:35:37.849
5210	5210	แม่ทะ	Mae Tha	40	2025-12-18 04:35:37.85
5211	5211	สบปราบ	Sop Prap	40	2025-12-18 04:35:37.852
5212	5212	ห้างฉัตร	Hang Chat	40	2025-12-18 04:35:37.853
5213	5213	เมืองปาน	Mueang Pan	40	2025-12-18 04:35:37.854
5301	5301	เมืองอุตรดิตถ์	Mueang Uttaradit	41	2025-12-18 04:35:37.856
5302	5302	ตรอน	Tron	41	2025-12-18 04:35:37.857
5303	5303	ท่าปลา	Tha Pla	41	2025-12-18 04:35:37.859
5304	5304	น้ำปาด	Nam Pat	41	2025-12-18 04:35:37.86
5305	5305	ฟากท่า	Fak Tha	41	2025-12-18 04:35:37.861
5306	5306	บ้านโคก	Ban Khok	41	2025-12-18 04:35:37.863
5307	5307	พิชัย	Phichai	41	2025-12-18 04:35:37.864
5308	5308	ลับแล	Laplae	41	2025-12-18 04:35:37.865
5309	5309	ทองแสนขัน	Thong Saen Khan	41	2025-12-18 04:35:37.867
5401	5401	เมืองแพร่	Mueang Phrae	42	2025-12-18 04:35:37.868
5402	5402	ร้องกวาง	Rong Kwang	42	2025-12-18 04:35:37.869
5403	5403	ลอง	Long	42	2025-12-18 04:35:37.871
5404	5404	สูงเม่น	Sung Men	42	2025-12-18 04:35:37.872
5405	5405	เด่นชัย	Den Chai	42	2025-12-18 04:35:37.873
5406	5406	สอง	Song	42	2025-12-18 04:35:37.875
5407	5407	วังชิ้น	Wang Chin	42	2025-12-18 04:35:37.876
5408	5408	หนองม่วงไข่	Nong Muang Khai	42	2025-12-18 04:35:37.877
5501	5501	เมืองน่าน	Mueang Nan	43	2025-12-18 04:35:37.879
5502	5502	แม่จริม	Mae Charim	43	2025-12-18 04:35:37.88
5503	5503	บ้านหลวง	Ban Luang	43	2025-12-18 04:35:37.881
5504	5504	นาน้อย	Na Noi	43	2025-12-18 04:35:37.883
5505	5505	ปัว	Pua	43	2025-12-18 04:35:37.884
5506	5506	ท่าวังผา	Tha Wang Pha	43	2025-12-18 04:35:37.885
5507	5507	เวียงสา	Wiang Sa	43	2025-12-18 04:35:37.887
5508	5508	ทุ่งช้าง	Thung Chang	43	2025-12-18 04:35:37.888
5509	5509	เชียงกลาง	Chiang Klang	43	2025-12-18 04:35:37.89
5510	5510	นาหมื่น	Na Muen	43	2025-12-18 04:35:37.891
5511	5511	สันติสุข	Santi Suk	43	2025-12-18 04:35:37.892
5512	5512	บ่อเกลือ	Bo Kluea	43	2025-12-18 04:35:37.894
5513	5513	สองแคว	Song Khwae	43	2025-12-18 04:35:37.895
5514	5514	ภูเพียง	Phu Phiang	43	2025-12-18 04:35:37.896
5515	5515	เฉลิมพระเกียรติ	Chaloem Phra Kiat	43	2025-12-18 04:35:37.897
5601	5601	เมืองพะเยา	Mueang Phayao	44	2025-12-18 04:35:37.899
5602	5602	จุน	Chun	44	2025-12-18 04:35:37.9
5603	5603	เชียงคำ	Chiang Kham	44	2025-12-18 04:35:37.902
5604	5604	เชียงม่วน	Chiang Muan	44	2025-12-18 04:35:37.904
5605	5605	ดอกคำใต้	Dok Khamtai	44	2025-12-18 04:35:37.905
5606	5606	ปง	Pong	44	2025-12-18 04:35:37.907
5607	5607	แม่ใจ	Mae Chai	44	2025-12-18 04:35:37.908
5608	5608	ภูซาง	Phu Sang	44	2025-12-18 04:35:37.91
5609	5609	ภูกามยาว	Phu Kamyao	44	2025-12-18 04:35:37.911
5701	5701	เมืองเชียงราย	Mueang Chiang Rai	45	2025-12-18 04:35:37.913
5702	5702	เวียงชัย	Wiang Chai	45	2025-12-18 04:35:37.914
5703	5703	เชียงของ	Chiang Khong	45	2025-12-18 04:35:37.916
5704	5704	เทิง	Thoeng	45	2025-12-18 04:35:37.917
5705	5705	พาน	Phan	45	2025-12-18 04:35:37.918
5706	5706	ป่าแดด	Pa Daet	45	2025-12-18 04:35:37.92
5707	5707	แม่จัน	Mae Chan	45	2025-12-18 04:35:37.921
5708	5708	เชียงแสน	Chiang Saen	45	2025-12-18 04:35:37.923
5709	5709	แม่สาย	Mae Sai	45	2025-12-18 04:35:37.924
5710	5710	แม่สรวย	Mae Suai	45	2025-12-18 04:35:37.925
5711	5711	เวียงป่าเป้า	Wiang Pa Pao	45	2025-12-18 04:35:37.927
5712	5712	พญาเม็งราย	Phaya Mengrai	45	2025-12-18 04:35:37.928
5713	5713	เวียงแก่น	Wiang Kaen	45	2025-12-18 04:35:37.93
5714	5714	ขุนตาล	Khun Tan	45	2025-12-18 04:35:37.931
5715	5715	แม่ฟ้าหลวง	Mae Fa Luang	45	2025-12-18 04:35:37.933
5716	5716	แม่ลาว	Mae Lao	45	2025-12-18 04:35:37.934
5717	5717	เวียงเชียงรุ้ง	Wiang Chiang Rung	45	2025-12-18 04:35:37.935
5718	5718	ดอยหลวง	Doi Luang	45	2025-12-18 04:35:37.937
5801	5801	เมืองแม่ฮ่องสอน	Mueang Mae Hong Son	46	2025-12-18 04:35:37.938
5802	5802	ขุนยวม	Khun Yuam	46	2025-12-18 04:35:37.94
5803	5803	ปาย	Pai	46	2025-12-18 04:35:37.941
5804	5804	แม่สะเรียง	Mae Sariang	46	2025-12-18 04:35:37.943
5805	5805	แม่ลาน้อย	Mae La Noi	46	2025-12-18 04:35:37.944
5806	5806	สบเมย	Sop Moei	46	2025-12-18 04:35:37.945
5807	5807	ปางมะผ้า	Pang Mapha	46	2025-12-18 04:35:37.947
6001	6001	เมืองนครสวรรค์	Mueang Nakhon Sawan	47	2025-12-18 04:35:37.948
6002	6002	โกรกพระ	Krok Phra	47	2025-12-18 04:35:37.95
6003	6003	ชุมแสง	Chum Saeng	47	2025-12-18 04:35:37.951
6004	6004	หนองบัว	Nong Bua	47	2025-12-18 04:35:37.953
6005	6005	บรรพตพิสัย	Banphot Phisai	47	2025-12-18 04:35:37.954
6006	6006	เก้าเลี้ยว	Kao Liao	47	2025-12-18 04:35:37.956
6007	6007	ตาคลี	Takhli	47	2025-12-18 04:35:37.958
6008	6008	ท่าตะโก	Takhli	47	2025-12-18 04:35:37.959
6009	6009	ไพศาลี	Phaisali	47	2025-12-18 04:35:37.961
6010	6010	พยุหะคีรี	Phayuha Khiri	47	2025-12-18 04:35:37.962
6011	6011	ลาดยาว	Phayuha Khiri	47	2025-12-18 04:35:37.964
6012	6012	ตากฟ้า	Tak Fa	47	2025-12-18 04:35:37.965
6013	6013	แม่วงก์	Mae Wong	47	2025-12-18 04:35:37.967
6014	6014	แม่เปิน	Mae Poen	47	2025-12-18 04:35:37.969
6015	6015	ชุมตาบง	Chum Ta Bong	47	2025-12-18 04:35:37.97
6101	6101	เมืองอุทัยธานี	Mueang Uthai Thani	48	2025-12-18 04:35:37.972
6102	6102	ทัพทัน	Thap Than	48	2025-12-18 04:35:37.973
6103	6103	สว่างอารมณ์	Sawang Arom	48	2025-12-18 04:35:37.975
6104	6104	หนองฉาง	Nong Chang	48	2025-12-18 04:35:37.976
6105	6105	หนองขาหย่าง	Nong Khayang	48	2025-12-18 04:35:37.978
6106	6106	บ้านไร่	Ban Rai	48	2025-12-18 04:35:37.981
6107	6107	ลานสัก	Lan Sak	48	2025-12-18 04:35:37.982
6108	6108	ห้วยคต	Huai Khot	48	2025-12-18 04:35:37.983
6201	6201	เมืองกำแพงเพชร	Mueang Kamphaeng Phet	49	2025-12-18 04:35:37.986
6202	6202	ไทรงาม	Sai Ngam	49	2025-12-18 04:35:37.988
6203	6203	คลองลาน	Khlong Lan	49	2025-12-18 04:35:37.989
6204	6204	ขาณุวรลักษบุรี	Khanu Woralaksaburi	49	2025-12-18 04:35:37.991
6205	6205	คลองขลุง	Khlong Khlung	49	2025-12-18 04:35:37.994
6206	6206	พรานกระต่าย	Phran Kratai	49	2025-12-18 04:35:37.996
6207	6207	ลานกระบือ	Lan Krabue	49	2025-12-18 04:35:37.999
6208	6208	ทรายทองวัฒนา	Sai Thong Watthana	49	2025-12-18 04:35:38.001
6209	6209	ปางศิลาทอง	Pang Sila Thong	49	2025-12-18 04:35:38.003
6210	6210	บึงสามัคคี	Bueng Samakkhi	49	2025-12-18 04:35:38.005
6211	6211	โกสัมพีนคร	Kosamphi Nakhon	49	2025-12-18 04:35:38.007
6301	6301	เมืองตาก	Mueang Tak	50	2025-12-18 04:35:38.008
6302	6302	บ้านตาก	Ban Tak	50	2025-12-18 04:35:38.01
6303	6303	สามเงา	Sam Ngao	50	2025-12-18 04:35:38.012
6304	6304	แม่ระมาด	Mae Ramat	50	2025-12-18 04:35:38.014
6305	6305	ท่าสองยาง	Tha Song Yang	50	2025-12-18 04:35:38.015
6306	6306	แม่สอด	Mae Sot	50	2025-12-18 04:35:38.017
6307	6307	พบพระ	Phop Phra	50	2025-12-18 04:35:38.019
6308	6308	อุ้มผาง	Umphang	50	2025-12-18 04:35:38.021
6309	6309	วังเจ้า	Wang Chao	50	2025-12-18 04:35:38.023
6401	6401	เมืองสุโขทัย	Mueang Sukhothai	51	2025-12-18 04:35:38.025
6402	6402	บ้านด่านลานหอย	Ban Dan Lan Hoi	51	2025-12-18 04:35:38.027
6403	6403	คีรีมาศ	Khiri Mat	51	2025-12-18 04:35:38.029
6404	6404	กงไกรลาศ	Kong Krailat	51	2025-12-18 04:35:38.031
6405	6405	ศรีสัชนาลัย	Si Satchanalai	51	2025-12-18 04:35:38.033
6406	6406	ศรีสำโรง	Si Samrong	51	2025-12-18 04:35:38.035
6407	6407	สวรรคโลก	Sawankhalok	51	2025-12-18 04:35:38.037
6408	6408	ศรีนคร	Si Nakhon	51	2025-12-18 04:35:38.039
6409	6409	ทุ่งเสลี่ยม	Thung Saliam	51	2025-12-18 04:35:38.041
6501	6501	เมืองพิษณุโลก	Mueang Phitsanulok	52	2025-12-18 04:35:38.042
6502	6502	นครไทย	Nakhon Thai	52	2025-12-18 04:35:38.045
6503	6503	ชาติตระการ	Chat Trakan	52	2025-12-18 04:35:38.047
6504	6504	บางระกำ	Bang Rakam	52	2025-12-18 04:35:38.049
6505	6505	บางกระทุ่ม	Bang Krathum	52	2025-12-18 04:35:38.051
6506	6506	พรหมพิราม	Phrom Phiram	52	2025-12-18 04:35:38.054
6507	6507	วัดโบสถ์	Wat Bot	52	2025-12-18 04:35:38.056
6508	6508	วังทอง	Wang Thong	52	2025-12-18 04:35:38.058
6509	6509	เนินมะปราง	Noen Maprang	52	2025-12-18 04:35:38.06
6601	6601	เมืองพิจิตร	Mueang Phichit	53	2025-12-18 04:35:38.063
6602	6602	วังทรายพูน	Wang Sai Phun	53	2025-12-18 04:35:38.064
6603	6603	โพธิ์ประทับช้าง	Pho Prathap Chang	53	2025-12-18 04:35:38.066
6604	6604	ตะพานหิน	Taphan Hin	53	2025-12-18 04:35:38.069
6605	6605	บางมูลนาก	Bang Mun Nak	53	2025-12-18 04:35:38.071
6606	6606	โพทะเล	Pho Thale	53	2025-12-18 04:35:38.073
6607	6607	สามง่าม	Sam Ngam	53	2025-12-18 04:35:38.076
6608	6608	ทับคล้อ	Tap Khlo	53	2025-12-18 04:35:38.078
6609	6609	สากเหล็ก	Sak Lek	53	2025-12-18 04:35:38.08
6610	6610	บึงนาราง	Bueng Na Rang	53	2025-12-18 04:35:38.082
6611	6611	ดงเจริญ	Dong Charoen	53	2025-12-18 04:35:38.084
6612	6612	วชิรบารมี	Wachirabarami	53	2025-12-18 04:35:38.086
6701	6701	เมืองเพชรบูรณ์	Mueang Phetchabun	54	2025-12-18 04:35:38.088
6702	6702	ชนแดน	Chon Daen	54	2025-12-18 04:35:38.091
6703	6703	หล่มสัก	Lom Sak	54	2025-12-18 04:35:38.095
6704	6704	หล่มเก่า	Lom Kao	54	2025-12-18 04:35:38.097
6705	6705	วิเชียรบุรี	Wichian Buri	54	2025-12-18 04:35:38.1
6706	6706	ศรีเทพ	Si Thep	54	2025-12-18 04:35:38.101
6707	6707	หนองไผ่	Nong Phai	54	2025-12-18 04:35:38.103
6708	6708	บึงสามพัน	Bueng Sam Phan	54	2025-12-18 04:35:38.104
6709	6709	น้ำหนาว	Nam Nao	54	2025-12-18 04:35:38.105
6710	6710	วังโป่ง	Wang Pong	54	2025-12-18 04:35:38.106
6711	6711	เขาค้อ	Khao Kho	54	2025-12-18 04:35:38.108
7001	7001	เมืองราชบุรี	Mueang Ratchaburi	55	2025-12-18 04:35:38.109
7002	7002	จอมบึง	Chom Bueng	55	2025-12-18 04:35:38.11
7003	7003	สวนผึ้ง	Suan Phueng	55	2025-12-18 04:35:38.111
7004	7004	ดำเนินสะดวก	Damnoen Saduak	55	2025-12-18 04:35:38.112
7005	7005	บ้านโป่ง	Ban Pong	55	2025-12-18 04:35:38.113
7006	7006	บางแพ	Bang Phae	55	2025-12-18 04:35:38.114
7007	7007	โพธาราม	Photharam	55	2025-12-18 04:35:38.115
7008	7008	ปากท่อ	Pak Tho	55	2025-12-18 04:35:38.116
7009	7009	วัดเพลง	Wat Phleng	55	2025-12-18 04:35:38.117
7010	7010	บ้านคา	Ban Kha	55	2025-12-18 04:35:38.118
7074	7074	ท้องถิ่นเทศบาลตำบลบ้านฆ้อง	Tet Saban Ban Kong	55	2025-12-18 04:35:38.119
7101	7101	เมืองกาญจนบุรี	Mueang Kanchanaburi	56	2025-12-18 04:35:38.12
7102	7102	ไทรโยค	Sai Yok	56	2025-12-18 04:35:38.121
7103	7103	บ่อพลอย	Bo Phloi	56	2025-12-18 04:35:38.122
7104	7104	ศรีสวัสดิ์	Si Sawat	56	2025-12-18 04:35:38.123
7105	7105	ท่ามะกา	Tha Maka	56	2025-12-18 04:35:38.124
7106	7106	ท่าม่วง	Tha Muang	56	2025-12-18 04:35:38.125
7107	7107	ทองผาภูมิ	Pha Phum	56	2025-12-18 04:35:38.126
7108	7108	สังขละบุรี	Sangkhla Buri	56	2025-12-18 04:35:38.128
7109	7109	พนมทวน	Phanom Thuan	56	2025-12-18 04:35:38.13
7110	7110	เลาขวัญ	Lao Khwan	56	2025-12-18 04:35:38.132
7111	7111	ด่านมะขามเตี้ย	Dan Makham Tia	56	2025-12-18 04:35:38.133
7112	7112	หนองปรือ	Nong Prue	56	2025-12-18 04:35:38.134
7113	7113	ห้วยกระเจา	Huai Krachao	56	2025-12-18 04:35:38.136
7201	7201	เมืองสุพรรณบุรี	Mueang Suphan Buri	57	2025-12-18 04:35:38.137
7202	7202	เดิมบางนางบวช	Doem Bang Nang Buat	57	2025-12-18 04:35:38.139
7203	7203	ด่านช้าง	Dan Chang	57	2025-12-18 04:35:38.14
7204	7204	บางปลาม้า	Bang Pla Ma	57	2025-12-18 04:35:38.141
7205	7205	ศรีประจันต์	Si Prachan	57	2025-12-18 04:35:38.142
7206	7206	ดอนเจดีย์	Don Chedi	57	2025-12-18 04:35:38.143
7207	7207	สองพี่น้อง	Song Phi Nong	57	2025-12-18 04:35:38.144
7208	7208	สามชุก	Sam Chuk	57	2025-12-18 04:35:38.145
7209	7209	อู่ทอง	U Thong	57	2025-12-18 04:35:38.146
7210	7210	หนองหญ้าไซ	Nong Ya Sai	57	2025-12-18 04:35:38.147
7301	7301	เมืองนครปฐม	Mueang Nakhon Pathom	58	2025-12-18 04:35:38.148
7302	7302	กำแพงแสน	Kamphaeng Saen	58	2025-12-18 04:35:38.15
7304	7304	ดอนตูม	Don Tum	58	2025-12-18 04:35:38.152
7305	7305	บางเลน	Bang Len	58	2025-12-18 04:35:38.154
7306	7306	สามพราน	Sam Phran	58	2025-12-18 04:35:38.155
7307	7307	พุทธมณฑล	Phutthamonthon	58	2025-12-18 04:35:38.157
7401	7401	เมืองสมุทรสาคร	Mueang Samut Sakhon	59	2025-12-18 04:35:38.158
7402	7402	กระทุ่มแบน	Krathum Baen	59	2025-12-18 04:35:38.159
7403	7403	บ้านแพ้ว	Ban Phaeo	59	2025-12-18 04:35:38.161
7501	7501	เมืองสมุทรสงคราม	Mueang Samut Songkhram	60	2025-12-18 04:35:38.162
7502	7502	บางคนที	Bang Khonthi	60	2025-12-18 04:35:38.164
7503	7503	อัมพวา	Amphawa	60	2025-12-18 04:35:38.165
7601	7601	เมืองเพชรบุรี	Mueang Phetchaburi	61	2025-12-18 04:35:38.166
7602	7602	เขาย้อย	Khao Yoi	61	2025-12-18 04:35:38.168
7603	7603	หนองหญ้าปล้อง	Nong Ya Plong	61	2025-12-18 04:35:38.169
7604	7604	ชะอำ	Cha-am	61	2025-12-18 04:35:38.171
7605	7605	ท่ายาง	Tha Yang	61	2025-12-18 04:35:38.172
7606	7606	บ้านลาด	Ban Lat	61	2025-12-18 04:35:38.173
7607	7607	บ้านแหลม	Ban Laem	61	2025-12-18 04:35:38.175
7608	7608	แก่งกระจาน	Kaeng Krachan	61	2025-12-18 04:35:38.176
7701	7701	เมืองประจวบคีรีขันธ์	Mueang Prachuap Khiri Khan	62	2025-12-18 04:35:38.178
7702	7702	กุยบุรี	Kui Buri	62	2025-12-18 04:35:38.179
7703	7703	ทับสะแก	Thap Sakae	62	2025-12-18 04:35:38.181
7704	7704	บางสะพาน	Bang Saphan	62	2025-12-18 04:35:38.182
7705	7705	บางสะพานน้อย	Bang Saphan Noi	62	2025-12-18 04:35:38.184
7706	7706	ปราณบุรี	Pran Buri	62	2025-12-18 04:35:38.186
7707	7707	หัวหิน	Hua Hin	62	2025-12-18 04:35:38.187
7708	7708	สามร้อยยอด	Sam Roi Yot	62	2025-12-18 04:35:38.188
8001	8001	เมืองนครศรีธรรมราช	Mueang Nakhon Si Thammarat	63	2025-12-18 04:35:38.19
8002	8002	พรหมคีรี	Phrom Khiri	63	2025-12-18 04:35:38.192
8003	8003	ลานสกา	Lan Saka	63	2025-12-18 04:35:38.193
8004	8004	ฉวาง	Chawang	63	2025-12-18 04:35:38.195
8005	8005	พิปูน	Phipun	63	2025-12-18 04:35:38.196
8006	8006	เชียรใหญ่	Chian Yai	63	2025-12-18 04:35:38.198
8007	8007	ชะอวด	Cha-uat	63	2025-12-18 04:35:38.199
8008	8008	ท่าศาลา	Tha Sala	63	2025-12-18 04:35:38.2
8009	8009	ทุ่งสง	Thung Song	63	2025-12-18 04:35:38.202
8010	8010	นาบอน	Na Bon	63	2025-12-18 04:35:38.203
8011	8011	ทุ่งใหญ่	Thung Yai	63	2025-12-18 04:35:38.205
8012	8012	ปากพนัง	Pak Phanang	63	2025-12-18 04:35:38.206
8013	8013	ร่อนพิบูลย์	Ron Phibun	63	2025-12-18 04:35:38.207
8014	8014	สิชล	Sichon	63	2025-12-18 04:35:38.209
8015	8015	ขนอม	Khanom	63	2025-12-18 04:35:38.21
8016	8016	หัวไทร	Hua Sai	63	2025-12-18 04:35:38.212
8017	8017	บางขัน	Bang Khan	63	2025-12-18 04:35:38.213
8018	8018	ถ้ำพรรณรา	Tham Phannara	63	2025-12-18 04:35:38.215
8019	8019	จุฬาภรณ์	Chulabhorn	63	2025-12-18 04:35:38.216
8020	8020	พระพรหม	Phra Phrom	63	2025-12-18 04:35:38.219
8021	8021	นบพิตำ	Nopphitam	63	2025-12-18 04:35:38.221
8022	8022	ช้างกลาง	Chang Klang	63	2025-12-18 04:35:38.222
8023	8023	เฉลิมพระเกียรติ	Chaloem Phra Kiat	63	2025-12-18 04:35:38.224
8101	8101	เมืองกระบี่	Mueang Krabi	64	2025-12-18 04:35:38.225
8102	8102	เขาพนม	Khao Phanom	64	2025-12-18 04:35:38.227
8103	8103	เกาะลันตา	Ko Lanta	64	2025-12-18 04:35:38.228
8104	8104	คลองท่อม	Khlong Thom	64	2025-12-18 04:35:38.23
8105	8105	อ่าวลึก	Ao Luek	64	2025-12-18 04:35:38.231
8106	8106	ปลายพระยา	Plai Phraya	64	2025-12-18 04:35:38.233
8107	8107	ลำทับ	Lam Thap	64	2025-12-18 04:35:38.235
8108	8108	เหนือคลอง	Nuea Khlong	64	2025-12-18 04:35:38.237
8201	8201	เมืองพังงา	Mueang Phang-nga	65	2025-12-18 04:35:38.239
8202	8202	เกาะยาว	Ko Yao	65	2025-12-18 04:35:38.24
8203	8203	กะปง	Kapong	65	2025-12-18 04:35:38.242
8204	8204	ตะกั่วทุ่ง	Takua Thung	65	2025-12-18 04:35:38.244
8205	8205	ตะกั่วป่า	Takua Pa	65	2025-12-18 04:35:38.245
8206	8206	คุระบุรี	Khura Buri	65	2025-12-18 04:35:38.247
8207	8207	ทับปุด	Thap Put	65	2025-12-18 04:35:38.248
8208	8208	ท้ายเหมือง	Thai Mueang	65	2025-12-18 04:35:38.25
8301	8301	เมืองภูเก็ต	Mueang Phuket	66	2025-12-18 04:35:38.251
8302	8302	กะทู้	Kathu	66	2025-12-18 04:35:38.253
8303	8303	ถลาง	Thalang	66	2025-12-18 04:35:38.254
8401	8401	เมืองสุราษฎร์ธานี	Mueang Surat Thani	67	2025-12-18 04:35:38.256
8402	8402	กาญจนดิษฐ์	Kanchanadit	67	2025-12-18 04:35:38.257
8403	8403	ดอนสัก	Don Sak	67	2025-12-18 04:35:38.259
8404	8404	เกาะสมุย	Ko Samui	67	2025-12-18 04:35:38.261
8405	8405	เกาะพะงัน	Ko Pha-ngan	67	2025-12-18 04:35:38.263
8406	8406	ไชยา	Chaiya	67	2025-12-18 04:35:38.265
8407	8407	ท่าชนะ	Tha Chana	67	2025-12-18 04:35:38.267
8408	8408	คีรีรัฐนิคม	Khiri Rat Nikhom	67	2025-12-18 04:35:38.268
8409	8409	บ้านตาขุน	Ban Ta Khun	67	2025-12-18 04:35:38.27
8410	8410	พนม	Phanom	67	2025-12-18 04:35:38.272
8411	8411	ท่าฉาง	Tha Chang	67	2025-12-18 04:35:38.274
8412	8412	บ้านนาสาร	Ban Na San	67	2025-12-18 04:35:38.275
8413	8413	บ้านนาเดิม	Ban Na Doem	67	2025-12-18 04:35:38.277
8414	8414	เคียนซา	Khian Sa	67	2025-12-18 04:35:38.279
8415	8415	เวียงสระ	Wiang Sa	67	2025-12-18 04:35:38.28
8416	8416	พระแสง	Phrasaeng	67	2025-12-18 04:35:38.282
8417	8417	พุนพิน	Phunphin	67	2025-12-18 04:35:38.284
8418	8418	ชัยบุรี	Chai Buri	67	2025-12-18 04:35:38.286
8419	8419	วิภาวดี	Vibhavadi	67	2025-12-18 04:35:38.288
8501	8501	เมืองระนอง	Mueang Ranong	68	2025-12-18 04:35:38.29
8502	8502	ละอุ่น	La-un	68	2025-12-18 04:35:38.293
8503	8503	กะเปอร์	Kapoe	68	2025-12-18 04:35:38.295
8504	8504	กระบุรี	Kra Buri	68	2025-12-18 04:35:38.297
8505	8505	สุขสำราญ	Suk Samran	68	2025-12-18 04:35:38.299
8601	8601	เมืองชุมพร	Mueang Chumphon	69	2025-12-18 04:35:38.301
8602	8602	ท่าแซะ	Tha Sae	69	2025-12-18 04:35:38.303
8603	8603	ปะทิว	Pathio	69	2025-12-18 04:35:38.305
8604	8604	หลังสวน	Lang Suan	69	2025-12-18 04:35:38.308
8605	8605	ละแม	Lamae	69	2025-12-18 04:35:38.309
8606	8606	พะโต๊ะ	Phato	69	2025-12-18 04:35:38.311
8607	8607	สวี	Sawi	69	2025-12-18 04:35:38.313
8608	8608	ทุ่งตะโก	Thung Tako	69	2025-12-18 04:35:38.315
9001	9001	เมืองสงขลา	Mueang Songkhla	70	2025-12-18 04:35:38.317
9002	9002	สทิงพระ	Sathing Phra	70	2025-12-18 04:35:38.318
9003	9003	จะนะ	Chana	70	2025-12-18 04:35:38.321
9004	9004	นาทวี	Na Thawi	70	2025-12-18 04:35:38.323
9005	9005	เทพา	Thepha	70	2025-12-18 04:35:38.324
9006	9006	สะบ้าย้อย	Saba Yoi	70	2025-12-18 04:35:38.326
9007	9007	ระโนด	Ranot	70	2025-12-18 04:35:38.328
9008	9008	กระแสสินธุ์	Krasae Sin	70	2025-12-18 04:35:38.33
9009	9009	รัตภูมิ	Rattaphum	70	2025-12-18 04:35:38.331
9010	9010	สะเดา	Sadao	70	2025-12-18 04:35:38.333
9011	9011	หาดใหญ่	Hat Yai	70	2025-12-18 04:35:38.335
9012	9012	นาหม่อม	Na Mom	70	2025-12-18 04:35:38.337
9013	9013	ควนเนียง	Khuan Niang	70	2025-12-18 04:35:38.339
9014	9014	บางกล่ำ	Bang Klam	70	2025-12-18 04:35:38.341
9015	9015	สิงหนคร	Singhanakhon	70	2025-12-18 04:35:38.343
9016	9016	คลองหอยโข่ง	Khlong Hoi Khong	70	2025-12-18 04:35:38.345
9077	9077	ท้องถิ่นเทศบาลตำบลสำนักขาม	Sum Nung Kam	70	2025-12-18 04:35:38.347
9101	9101	เมืองสตูล	Mueang Satun	71	2025-12-18 04:35:38.35
9102	9102	ควนโดน	Khuan Don	71	2025-12-18 04:35:38.352
9103	9103	ควนกาหลง	Khuan Kalong	71	2025-12-18 04:35:38.354
9104	9104	ท่าแพ	Tha Phae	71	2025-12-18 04:35:38.357
9105	9105	ละงู	La-ngu	71	2025-12-18 04:35:38.359
9106	9106	ทุ่งหว้า	Thung Wa	71	2025-12-18 04:35:38.361
9107	9107	มะนัง	Manang	71	2025-12-18 04:35:38.363
9201	9201	เมืองตรัง	Mueang Trang	72	2025-12-18 04:35:38.366
9202	9202	กันตัง	Kantang	72	2025-12-18 04:35:38.369
9203	9203	ย่านตาขาว	Yan Ta Khao	72	2025-12-18 04:35:38.371
9204	9204	ปะเหลียน	Palian	72	2025-12-18 04:35:38.373
9205	9205	สิเกา	Sikao	72	2025-12-18 04:35:38.376
9206	9206	ห้วยยอด	Huai Yot	72	2025-12-18 04:35:38.378
9207	9207	วังวิเศษ	Wang Wiset	72	2025-12-18 04:35:38.38
9208	9208	นาโยง	Na Yong	72	2025-12-18 04:35:38.383
9209	9209	รัษฎา	Ratsada	72	2025-12-18 04:35:38.385
9210	9210	หาดสำราญ	Hat Samran	72	2025-12-18 04:35:38.388
9606	9606	รือเสาะ	Rueso	76	2025-12-18 04:35:38.467
9607	9607	ศรีสาคร	Si Sakhon	76	2025-12-18 04:35:38.469
9608	9608	แว้ง	Waeng	76	2025-12-18 04:35:38.471
9609	9609	สุคิริน	Sukhirin	76	2025-12-18 04:35:38.473
9610	9610	สุไหงโก-ลก	Su-ngai Kolok	76	2025-12-18 04:35:38.476
9611	9611	สุไหงปาดี	Su-ngai Padi	76	2025-12-18 04:35:38.478
9612	9612	จะแนะ	Chanae	76	2025-12-18 04:35:38.481
9613	9613	เจาะไอร้อง	Cho-airong	76	2025-12-18 04:35:38.483
3704	3704	พนา	Phana	26	2025-12-18 04:35:37.628
1012	1012	เขตยานนาวา	Khet Yan Nawa	1	2025-12-18 04:35:37.271
1002	1002	เขตดุสิต	Khet Dusit	1	2025-12-18 04:35:37.256
1003	1003	เขตหนองจอก	Khet Nong Chok	1	2025-12-18 04:35:37.257
1004	1004	เขตบางรัก	Khet Bang Rak	1	2025-12-18 04:35:37.258
1005	1005	เขตบางเขน	Khet Bang Khen	1	2025-12-18 04:35:37.259
1006	1006	เขตบางกะปิ	Khet Bang Kapi	1	2025-12-18 04:35:37.261
1007	1007	เขตปทุมวัน	Khet Pathum Wan	1	2025-12-18 04:35:37.263
1008	1008	เขตป้อมปราบศัตรูพ่าย	Khet Pom Prap Sattru Phai	1	2025-12-18 04:35:37.265
1009	1009	เขตพระโขนง	Khet Phra Khanong	1	2025-12-18 04:35:37.268
1010	1010	เขตมีนบุรี	Khet Min Buri	1	2025-12-18 04:35:37.269
1011	1011	เขตลาดกระบัง	Khet Lat Krabang	1	2025-12-18 04:35:37.27
1014	1014	เขตพญาไท	Khet Phaya Thai	1	2025-12-18 04:35:37.274
3320	3320	พยุห์	Phayu	22	2025-12-18 04:35:37.563
5107	5107	บ้านธิ	Ban Thi	39	2025-12-18 04:35:37.836
7303	7303	นครชัยศรี	Nakhon Chai Si	58	2025-12-18 04:35:38.151
9301	9301	เมืองพัทลุง	Mueang Phatthalung	73	2025-12-18 04:35:38.39
9302	9302	กงหรา	Kong Ra	73	2025-12-18 04:35:38.392
9303	9303	เขาชัยสน	Khao Chaison	73	2025-12-18 04:35:38.394
9304	9304	ตะโหมด	Tamot	73	2025-12-18 04:35:38.396
9305	9305	ควนขนุน	Khuan Khanun	73	2025-12-18 04:35:38.399
9306	9306	ปากพะยูน	Pak Phayun	73	2025-12-18 04:35:38.4
9307	9307	ศรีบรรพต	Si Banphot	73	2025-12-18 04:35:38.402
9308	9308	ป่าบอน	Pa Bon	73	2025-12-18 04:35:38.404
9309	9309	บางแก้ว	Bang Kaeo	73	2025-12-18 04:35:38.406
9310	9310	ป่าพะยอม	Pa Phayom	73	2025-12-18 04:35:38.409
9311	9311	ศรีนครินทร์	Srinagarindra	73	2025-12-18 04:35:38.411
9401	9401	เมืองปัตตานี	Mueang Pattani	74	2025-12-18 04:35:38.413
9402	9402	โคกโพธิ์	Khok Pho	74	2025-12-18 04:35:38.415
9403	9403	หนองจิก	Nong Chik	74	2025-12-18 04:35:38.416
9404	9404	ปะนาเระ	Panare	74	2025-12-18 04:35:38.418
9405	9405	มายอ	Mayo	74	2025-12-18 04:35:38.42
9406	9406	ทุ่งยางแดง	Thung Yang Daeng	74	2025-12-18 04:35:38.422
9407	9407	สายบุรี	Sai Buri	74	2025-12-18 04:35:38.425
9408	9408	ไม้แก่น	Mai Kaen	74	2025-12-18 04:35:38.427
9409	9409	ยะหริ่ง	Yaring	74	2025-12-18 04:35:38.429
9410	9410	ยะรัง	Yarang	74	2025-12-18 04:35:38.431
9411	9411	กะพ้อ	Kapho	74	2025-12-18 04:35:38.433
9412	9412	แม่ลาน	Mae Lan	74	2025-12-18 04:35:38.435
9501	9501	เมืองยะลา	Mueang Yala	75	2025-12-18 04:35:38.437
9502	9502	เบตง	Betong	75	2025-12-18 04:35:38.439
9503	9503	บันนังสตา	Bannang Sata	75	2025-12-18 04:35:38.441
9504	9504	ธารโต	Than To	75	2025-12-18 04:35:38.443
9505	9505	ยะหา	Yaha	75	2025-12-18 04:35:38.445
9506	9506	รามัน	Raman	75	2025-12-18 04:35:38.448
9507	9507	กาบัง	Kabang	75	2025-12-18 04:35:38.449
9508	9508	กรงปินัง	Krong Pinang	75	2025-12-18 04:35:38.452
9601	9601	เมืองนราธิวาส	Mueang Narathiwat	76	2025-12-18 04:35:38.455
9602	9602	ตากใบ	Tak Bai	76	2025-12-18 04:35:38.457
9603	9603	บาเจาะ	Bacho	76	2025-12-18 04:35:38.46
9604	9604	ยี่งอ	Yi-ngo	76	2025-12-18 04:35:38.462
9605	9605	ระแงะ	Ra-ngae	76	2025-12-18 04:35:38.464
\.


--
-- Data for Name: notification_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_settings (id, "sourceApp", "actionType", "isActive", "recipientRoles", "recipientUsers", channels, created_at, updated_at, "recipientGroups") FROM stdin;
9be89e7a-0ded-406e-966e-a4d890ceecf2	BOOKING	CREATE	t	["ADMIN", "MANAGER"]	[]	["IN_APP"]	2025-12-31 08:30:36.143	2025-12-31 08:30:36.143	[]
fbd884c1-c0ac-46e0-aafa-a9bb741cf45f	BOOKING	CANCEL	t	["ADMIN"]	[]	["IN_APP"]	2025-12-31 08:30:36.146	2025-12-31 08:30:36.146	[]
1e544a71-acb5-41f2-9a7d-fe7f403c8b2a	USER	REGISTER	t	["ADMIN"]	[]	["IN_APP"]	2025-12-31 08:30:36.147	2025-12-31 08:30:36.147	[]
46dafd63-fe03-40d8-b33e-ddbd1c17e491	USER	APPROVAL_REQUEST	t	["ADMIN", "MANAGER"]	[]	["IN_APP"]	2025-12-31 08:30:36.149	2025-12-31 08:30:36.149	[]
bf15537a-deec-4744-aa69-e3627f2dd15b	SUPPLIER	CREATE	t	["ADMIN", "PURCHASING"]	[]	["IN_APP"]	2025-12-31 08:30:36.151	2025-12-31 08:30:36.151	[]
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, title, message, type, status, user_id, "sourceApp", "actionType", "entityId", "actionUrl", metadata, created_at, approval_request_id, approval_status) FROM stdin;
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posts (id, title, content, published, "authorId", "createdAt", "updatedAt") FROM stdin;
7caad5ce-e007-49b5-acc0-36a1e5bd60b8	Welcome to the Monorepo	This is a sample post created during database seeding.	t	027fc907-e8b3-4017-b84d-5f0279965aae	2025-12-31 08:30:36.141	2025-12-31 08:30:36.141
\.


--
-- Data for Name: provinces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provinces (id, code, name_th, name_en, created_at) FROM stdin;
1	1	กรุงเทพมหานคร	Bangkok	2025-12-18 04:35:37.177
2	2	สมุทรปราการ	Samut Prakan	2025-12-18 04:35:37.18
3	3	นนทบุรี	Nonthaburi	2025-12-18 04:35:37.181
4	4	ปทุมธานี	Pathum Thani	2025-12-18 04:35:37.182
5	5	พระนครศรีอยุธยา	Phra Nakhon Si Ayutthaya	2025-12-18 04:35:37.183
6	6	อ่างทอง	Ang Thong	2025-12-18 04:35:37.184
7	7	ลพบุรี	Lopburi	2025-12-18 04:35:37.186
8	8	สิงห์บุรี	Sing Buri	2025-12-18 04:35:37.187
9	9	ชัยนาท	Chai Nat	2025-12-18 04:35:37.188
10	10	สระบุรี	Saraburi	2025-12-18 04:35:37.189
11	11	ชลบุรี	Chon Buri	2025-12-18 04:35:37.19
12	12	ระยอง	Rayong	2025-12-18 04:35:37.191
13	13	จันทบุรี	Chanthaburi	2025-12-18 04:35:37.192
14	14	ตราด	Trat	2025-12-18 04:35:37.193
15	15	ฉะเชิงเทรา	Chachoengsao	2025-12-18 04:35:37.194
16	16	ปราจีนบุรี	Prachin Buri	2025-12-18 04:35:37.195
17	17	นครนายก	Nakhon Nayok	2025-12-18 04:35:37.196
18	18	สระแก้ว	Sa Kaeo	2025-12-18 04:35:37.197
19	19	นครราชสีมา	Nakhon Ratchasima	2025-12-18 04:35:37.198
20	20	บุรีรัมย์	Buri Ram	2025-12-18 04:35:37.199
21	21	สุรินทร์	Surin	2025-12-18 04:35:37.2
22	22	ศรีสะเกษ	Si Sa Ket	2025-12-18 04:35:37.201
23	23	อุบลราชธานี	Ubon Ratchathani	2025-12-18 04:35:37.202
24	24	ยโสธร	Yasothon	2025-12-18 04:35:37.203
25	25	ชัยภูมิ	Chaiyaphum	2025-12-18 04:35:37.203
26	26	อำนาจเจริญ	Amnat Charoen	2025-12-18 04:35:37.204
27	27	หนองบัวลำภู	Nong Bua Lam Phu	2025-12-18 04:35:37.205
28	28	ขอนแก่น	Khon Kaen	2025-12-18 04:35:37.206
29	29	อุดรธานี	Udon Thani	2025-12-18 04:35:37.207
30	30	เลย	Loei	2025-12-18 04:35:37.208
31	31	หนองคาย	Nong Khai	2025-12-18 04:35:37.209
32	32	มหาสารคาม	Maha Sarakham	2025-12-18 04:35:37.21
33	33	ร้อยเอ็ด	Roi Et	2025-12-18 04:35:37.211
34	34	กาฬสินธุ์	Kalasin	2025-12-18 04:35:37.212
35	35	สกลนคร	Sakon Nakhon	2025-12-18 04:35:37.213
36	36	นครพนม	Nakhon Phanom	2025-12-18 04:35:37.214
37	37	มุกดาหาร	Mukdahan	2025-12-18 04:35:37.215
38	38	เชียงใหม่	Chiang Mai	2025-12-18 04:35:37.216
39	39	ลำพูน	Lamphun	2025-12-18 04:35:37.217
40	40	ลำปาง	Lampang	2025-12-18 04:35:37.218
41	41	อุตรดิตถ์	Uttaradit	2025-12-18 04:35:37.218
42	42	แพร่	Phrae	2025-12-18 04:35:37.219
43	43	น่าน	Nan	2025-12-18 04:35:37.22
44	44	พะเยา	Phayao	2025-12-18 04:35:37.221
45	45	เชียงราย	Chiang Rai	2025-12-18 04:35:37.222
46	46	แม่ฮ่องสอน	Mae Hong Son	2025-12-18 04:35:37.223
47	47	นครสวรรค์	Nakhon Sawan	2025-12-18 04:35:37.224
48	48	อุทัยธานี	Uthai Thani	2025-12-18 04:35:37.225
49	49	กำแพงเพชร	Kamphaeng Phet	2025-12-18 04:35:37.226
50	50	ตาก	Tak	2025-12-18 04:35:37.227
51	51	สุโขทัย	Sukhothai	2025-12-18 04:35:37.227
52	52	พิษณุโลก	Phitsanulok	2025-12-18 04:35:37.228
53	53	พิจิตร	Phichit	2025-12-18 04:35:37.23
54	54	เพชรบูรณ์	Phetchabun	2025-12-18 04:35:37.23
55	55	ราชบุรี	Ratchaburi	2025-12-18 04:35:37.232
56	56	กาญจนบุรี	Kanchanaburi	2025-12-18 04:35:37.232
57	57	สุพรรณบุรี	Suphan Buri	2025-12-18 04:35:37.233
58	58	นครปฐม	Nakhon Pathom	2025-12-18 04:35:37.234
59	59	สมุทรสาคร	Samut Sakhon	2025-12-18 04:35:37.235
60	60	สมุทรสงคราม	Samut Songkhram	2025-12-18 04:35:37.236
61	61	เพชรบุรี	Phetchaburi	2025-12-18 04:35:37.237
62	62	ประจวบคีรีขันธ์	Prachuap Khiri Khan	2025-12-18 04:35:37.238
63	63	นครศรีธรรมราช	Nakhon Si Thammarat	2025-12-18 04:35:37.239
64	64	กระบี่	Krabi	2025-12-18 04:35:37.24
65	65	พังงา	Phangnga	2025-12-18 04:35:37.241
66	66	ภูเก็ต	Phuket	2025-12-18 04:35:37.242
67	67	สุราษฎร์ธานี	Surat Thani	2025-12-18 04:35:37.243
68	68	ระนอง	Ranong	2025-12-18 04:35:37.243
69	69	ชุมพร	Chumphon	2025-12-18 04:35:37.244
70	70	สงขลา	Songkhla	2025-12-18 04:35:37.245
71	71	สตูล	Satun	2025-12-18 04:35:37.246
72	72	ตรัง	Trang	2025-12-18 04:35:37.247
73	73	พัทลุง	Phatthalung	2025-12-18 04:35:37.248
74	74	ปัตตานี	Pattani	2025-12-18 04:35:37.249
75	75	ยะลา	Yala	2025-12-18 04:35:37.25
76	76	นราธิวาส	Narathiwat	2025-12-18 04:35:37.251
77	77	บึงกาฬ	Bueng Kan	2025-12-18 04:35:37.252
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, description, icon, color, permissions, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: rubber_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rubber_types (id, code, name, description, category, is_active, created_at, updated_at, deleted_at, deleted_by) FROM stdin;
1	EUDR_CL	EUDR CL	\N	\N	t	2025-12-18 04:35:52.976	2025-12-18 04:35:52.976	\N	\N
2	EUDR_NCL	EUDR North-East CL	\N	\N	t	2025-12-18 04:35:52.978	2025-12-18 04:35:52.978	\N	\N
3	EUDR_USS	EUDR USS	\N	\N	t	2025-12-18 04:35:52.979	2025-12-18 04:35:52.979	\N	\N
4	FSC_CL	FSC CL	\N	\N	t	2025-12-18 04:35:52.98	2025-12-18 04:35:52.98	\N	\N
5	FSC_USS	FSC USS	\N	\N	t	2025-12-18 04:35:52.981	2025-12-18 04:35:52.981	\N	\N
6	North_East_CL	North East CL	\N	\N	t	2025-12-18 04:35:52.982	2025-12-18 04:35:52.982	\N	\N
7	Regular_CL	Regular CL	\N	\N	t	2025-12-18 04:35:52.983	2025-12-18 04:35:52.983	\N	\N
8	Regular_USS	Regular USS	\N	\N	t	2025-12-18 04:35:52.983	2025-12-18 04:35:52.983	\N	\N
\.


--
-- Data for Name: subdistricts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subdistricts (id, code, name_th, name_en, zip_code, created_at, district_id) FROM stdin;
100103	100103	วัดราชบพิธ	Wat Ratchabophit	10200	2025-12-18 04:35:38.506	1001
100104	100104	สำราญราษฎร์	Samran Rat	10200	2025-12-18 04:35:38.508	1001
100105	100105	ศาลเจ้าพ่อเสือ	San Chao Pho Suea	10200	2025-12-18 04:35:38.51	1001
100106	100106	เสาชิงช้า	Sao Chingcha	10200	2025-12-18 04:35:38.512	1001
100107	100107	บวรนิเวศ	Bowon Niwet	10200	2025-12-18 04:35:38.514	1001
100108	100108	ตลาดยอด	Talat Yot	10200	2025-12-18 04:35:38.515	1001
100109	100109	ชนะสงคราม	Chana Songkhram	10200	2025-12-18 04:35:38.517	1001
100110	100110	บ้านพานถม	Ban Phan Thom	10200	2025-12-18 04:35:38.519	1001
100111	100111	บางขุนพรหม	Bang Khun Phrom	10200	2025-12-18 04:35:38.52	1001
100112	100112	วัดสามพระยา	Wat Sam Phraya	10200	2025-12-18 04:35:38.524	1001
100201	100201	ดุสิต	Dusit	10300	2025-12-18 04:35:38.526	1002
100202	100202	วชิรพยาบาล	Wachiraphayaban	10300	2025-12-18 04:35:38.528	1002
100203	100203	สวนจิตรลดา	Suan Chit Lada	10300	2025-12-18 04:35:38.531	1002
100204	100204	สี่แยกมหานาค	Si Yaek Maha Nak	10300	2025-12-18 04:35:38.532	1002
100206	100206	ถนนนครไชยศรี	Thanon Nakhon Chai Si	10300	2025-12-18 04:35:38.534	1002
100301	100301	กระทุ่มราย	Krathum Rai	10530	2025-12-18 04:35:38.536	1003
100302	100302	หนองจอก	Nong Chok	10530	2025-12-18 04:35:38.538	1003
100303	100303	คลองสิบ	Khlong Sip	10530	2025-12-18 04:35:38.539	1003
100304	100304	คลองสิบสอง	Khlong Sip Song	10530	2025-12-18 04:35:38.541	1003
100305	100305	โคกแฝด	Khok Faet	10530	2025-12-18 04:35:38.542	1003
100306	100306	คู้ฝั่งเหนือ	Khu Fang Nuea	10530	2025-12-18 04:35:38.544	1003
100307	100307	ลำผักชี	Lam Phak Chi	10530	2025-12-18 04:35:38.545	1003
100308	100308	ลำต้อยติ่ง	Lam Toiting	10530	2025-12-18 04:35:38.547	1003
100401	100401	มหาพฤฒาราม	Maha Phruettharam	10500	2025-12-18 04:35:38.549	1004
100402	100402	สีลม	Si Lom	10500	2025-12-18 04:35:38.551	1004
100403	100403	สุริยวงศ์	Suriyawong	10500	2025-12-18 04:35:38.552	1004
100404	100404	บางรัก	Bang Rak	10500	2025-12-18 04:35:38.554	1004
100405	100405	สี่พระยา	Si Phraya	10500	2025-12-18 04:35:38.556	1004
100502	100502	อนุสาวรีย์	Anusawari	10220	2025-12-18 04:35:38.557	1005
100508	100508	ท่าแร้ง	Tha Raeng	10220	2025-12-18 04:35:38.559	1005
100601	100601	คลองจั่น	Khlong Chan	10240	2025-12-18 04:35:38.561	1006
100608	100608	หัวหมาก	Hua Mak	10240	2025-12-18 04:35:38.567	1006
100701	100701	รองเมือง	Rong Mueang	10330	2025-12-18 04:35:38.569	1007
100702	100702	วังใหม่	Wang Mai	10330	2025-12-18 04:35:38.571	1007
100703	100703	ปทุมวัน	Pathum Wan	10330	2025-12-18 04:35:38.573	1007
100704	100704	ลุมพินี	Lumphini	10330	2025-12-18 04:35:38.575	1007
100801	100801	ป้อมปราบ	Pom Prap	10100	2025-12-18 04:35:38.576	1008
100802	100802	วัดเทพศิรินทร์	Wat Thep Sirin	10100	2025-12-18 04:35:38.578	1008
100803	100803	คลองมหานาค	Khlong Maha Nak	10100	2025-12-18 04:35:38.579	1008
100804	100804	บ้านบาตร	Ban Bat	10100	2025-12-18 04:35:38.581	1008
100805	100805	วัดโสมนัส	Wat Sommanat	10100	2025-12-18 04:35:38.583	1008
100905	100905	บางจาก	Bang Chak	10260	2025-12-18 04:35:38.584	1009
101001	101001	มีนบุรี	Min Buri	10510	2025-12-18 04:35:38.586	1010
101002	101002	แสนแสบ	Saen Saep	10510	2025-12-18 04:35:38.587	1010
101101	101101	ลาดกระบัง	Lat Krabang	10520	2025-12-18 04:35:38.589	1011
101102	101102	คลองสองต้นนุ่น	Khlong Song Ton Nun	10520	2025-12-18 04:35:38.591	1011
101103	101103	คลองสามประเวศ	Khlong Sam Prawet	10520	2025-12-18 04:35:38.593	1011
101104	101104	ลำปลาทิว	Lam Pla Thio	10520	2025-12-18 04:35:38.595	1011
101105	101105	ทับยาว	Thap Yao	10520	2025-12-18 04:35:38.597	1011
101106	101106	ขุมทอง	Khum Thong	10520	2025-12-18 04:35:38.599	1011
101203	101203	ช่องนนทรี	Chong Nonsi	10120	2025-12-18 04:35:38.601	1012
101204	101204	บางโพงพาง	Bang Phongphang	10120	2025-12-18 04:35:38.602	1012
101301	101301	จักรวรรดิ	Chakkrawat	10100	2025-12-18 04:35:38.604	1013
101302	101302	สัมพันธวงศ์	Samphanthawong	10100	2025-12-18 04:35:38.606	1013
101303	101303	ตลาดน้อย	Talat Noi	10100	2025-12-18 04:35:38.608	1013
101401	101401	สามเสนใน	Samsen Nai	10400	2025-12-18 04:35:38.61	1014
101501	101501	วัดกัลยาณ์	Wat Kanlaya	10600	2025-12-18 04:35:38.612	1015
101502	101502	หิรัญรูจี	Hiran Ruchi	10600	2025-12-18 04:35:38.613	1015
101503	101503	บางยี่เรือ	Bang Yi Ruea	10600	2025-12-18 04:35:38.615	1015
101504	101504	บุคคโล	Bukkhalo	10600	2025-12-18 04:35:38.617	1015
101505	101505	ตลาดพลู	Talat Phlu	10600	2025-12-18 04:35:38.619	1015
101506	101506	ดาวคะนอง	Dao Khanong	10600	2025-12-18 04:35:38.621	1015
101801	101801	สมเด็จเจ้าพระยา	Somdet Chao Phraya	10600	2025-12-18 04:35:38.632	1018
101802	101802	คลองสาน	Khlong San	10600	2025-12-18 04:35:38.633	1018
101803	101803	บางลำภูล่าง	Bang Lamphu Lang	10600	2025-12-18 04:35:38.635	1018
101804	101804	คลองต้นไทร	Khlong Ton Sai	10600	2025-12-18 04:35:38.636	1018
101901	101901	คลองชักพระ	Khlong Chak Phra	10170	2025-12-18 04:35:38.638	1019
101902	101902	ตลิ่งชัน	Taling Chan	10170	2025-12-18 04:35:38.639	1019
101903	101903	ฉิมพลี	Chimphli	10170	2025-12-18 04:35:38.641	1019
101904	101904	บางพรม	Bang Phrom	10170	2025-12-18 04:35:38.642	1019
101905	101905	บางระมาด	Bang Ramat	10170	2025-12-18 04:35:38.643	1019
101907	101907	บางเชือกหนัง	Bang Chueak Nang	10170	2025-12-18 04:35:38.645	1019
102004	102004	ศิริราช	Siri Rat	10700	2025-12-18 04:35:38.646	1020
102005	102005	บ้านช่างหล่อ	Ban Chang Lo	10700	2025-12-18 04:35:38.648	1020
102006	102006	บางขุนนนท์	Bang Khun Non	10700	2025-12-18 04:35:38.65	1020
102007	102007	บางขุนศรี	Bang Khun Si	10700	2025-12-18 04:35:38.651	1020
102009	102009	อรุณอมรินทร์	Arun Ammarin	10700	2025-12-18 04:35:38.652	1020
102105	102105	ท่าข้าม	Tha Kham	10150	2025-12-18 04:35:38.654	1021
102107	102107	แสมดำ	Samae Dam	10150	2025-12-18 04:35:38.656	1021
102201	102201	บางหว้า	Bang Wa	10160	2025-12-18 04:35:38.657	1022
102202	102202	บางด้วน	Bang Duan	10160	2025-12-18 04:35:38.658	1022
102203	102203	บางแค	Bang Kae	10160	2025-12-18 04:35:38.66	1022
102204	102204	บางแคเหนือ	Bang Kae Nua	10160	2025-12-18 04:35:38.662	1022
102205	102205	บางไผ่	Bang Phai	10160	2025-12-18 04:35:38.664	1022
102206	102206	บางจาก	Bang Chak	10160	2025-12-18 04:35:38.665	1022
102207	102207	บางแวก	Bang Waek	10160	2025-12-18 04:35:38.667	1022
102208	102208	คลองขวาง	Khlong Khwang	10160	2025-12-18 04:35:38.669	1022
102209	102209	ปากคลองภาษีเจริญ	Pak Khlong Phasi Charoen	10160	2025-12-18 04:35:38.67	1022
102210	102210	คูหาสวรรค์	Khuha Sawan	10160	2025-12-18 04:35:38.672	1022
102302	102302	หนองแขม	Nong Khaem	10160	2025-12-18 04:35:38.674	1023
102303	102303	หนองค้างพลู	Nong Khang Phlu	10160	2025-12-18 04:35:38.675	1023
102401	102401	ราษฎร์บูรณะ	Rat Burana	10140	2025-12-18 04:35:38.677	1024
102402	102402	บางปะกอก	Bang Pakok	10140	2025-12-18 04:35:38.678	1024
102501	102501	บางพลัด	Bang Phlat	10700	2025-12-18 04:35:38.68	1025
102502	102502	บางอ้อ	Bang O	10700	2025-12-18 04:35:38.682	1025
102503	102503	บางบำหรุ	Bang Bamru	10700	2025-12-18 04:35:38.683	1025
102504	102504	บางยี่ขัน	Bang Yi Khan	10700	2025-12-18 04:35:38.684	1025
102601	102601	ดินแดง	Din Daeng	10400	2025-12-18 04:35:38.686	1026
102701	102701	คลองกุ่ม	Khlong Kum	10240	2025-12-18 04:35:38.687	1027
102702	102702	สะพานสูง	Saphan Sung	10240	2025-12-18 04:35:38.689	1027
102703	102703	คันนายาว	Khan Na Yao	10240	2025-12-18 04:35:38.69	1027
102801	102801	ทุ่งวัดดอน	Thung Wat Don	10120	2025-12-18 04:35:38.692	1028
102802	102802	ยานนาวา	Yan Nawa	10120	2025-12-18 04:35:38.693	1028
102803	102803	ทุ่งมหาเมฆ	Thung Maha Mek	10120	2025-12-18 04:35:38.695	1028
102901	102901	บางซื่อ	Bang Sue	10800	2025-12-18 04:35:38.697	1029
103001	103001	ลาดยาว	Lat Yao	10900	2025-12-18 04:35:38.698	1030
103002	103002	เสนานิคม	Sena Nikhom	10900	2025-12-18 04:35:38.699	1030
103003	103003	จันทรเกษม	Chan Kasem	10900	2025-12-18 04:35:38.7	1030
103004	103004	จอมพล	Chom Phon	10900	2025-12-18 04:35:38.703	1030
103005	103005	จตุจักร	Chatuchak	10900	2025-12-18 04:35:38.704	1030
103101	103101	บางคอแหลม	Bang Kho Laem	10120	2025-12-18 04:35:38.706	1031
103102	103102	วัดพระยาไกร	Wat Phraya Krai	10120	2025-12-18 04:35:38.707	1031
103103	103103	บางโคล่	Bang Khlo	10120	2025-12-18 04:35:38.709	1031
103201	103201	ประเวศ	Prawet	10250	2025-12-18 04:35:38.711	1032
103202	103202	หนองบอน	Nong Bon	10250	2025-12-18 04:35:38.712	1032
103203	103203	ดอกไม้	Dokmai	10250	2025-12-18 04:35:38.713	1032
103204	103204	สวนหลวง	Suan Luang	10250	2025-12-18 04:35:38.715	1032
103301	103301	คลองเตย	Khlong Toei	10110	2025-12-18 04:35:38.716	1033
103302	103302	คลองตัน	Khlong Tan	10110	2025-12-18 04:35:38.717	1033
103303	103303	พระโขนง	Phra Khanong	10110	2025-12-18 04:35:38.719	1033
103304	103304	คลองเตยเหนือ	Khlong Toei Nua	10110	2025-12-18 04:35:38.72	1033
103305	103305	คลองตันเหนือ	Khlong Tan Nua	10110	2025-12-18 04:35:38.721	1033
103306	103306	พระโขนงเหนือ	Phra Khanong Nua	10110	2025-12-18 04:35:38.723	1033
103501	103501	บางขุนเทียน	Bang Khun Thian	10150	2025-12-18 04:35:38.725	1035
103502	103502	บางค้อ	Bang Kho	10150	2025-12-18 04:35:38.727	1035
103503	103503	บางมด	Bang Mot	10150	2025-12-18 04:35:38.729	1035
103504	103504	จอมทอง	Chom Thong	10150	2025-12-18 04:35:38.732	1035
103602	103602	สีกัน	Si Kan	10210	2025-12-18 04:35:38.735	1036
103701	103701	ทุ่งพญาไท	Thung Phaya Thai	10400	2025-12-18 04:35:38.737	1037
103702	103702	ถนนพญาไท	Thanon Phaya Thai	10400	2025-12-18 04:35:38.74	1037
103703	103703	ถนนเพชรบุรี	Thanon Phetchaburi	10400	2025-12-18 04:35:38.742	1037
103704	103704	มักกะสัน	Makkasan	10400	2025-12-18 04:35:38.744	1037
103801	103801	ลาดพร้าว	Lat Phrao	10230	2025-12-18 04:35:38.746	1038
103802	103802	จรเข้บัว	Chorakhe Bua	10230	2025-12-18 04:35:38.748	1038
103901	103901	คลองเตยเหนือ	Khlong Toei Nuea	10110	2025-12-18 04:35:38.749	1039
103902	103902	คลองตันเหนือ	Khlong Tan Nuea	10110	2025-12-18 04:35:38.752	1039
103903	103903	พระโขนงเหนือ	Phra Khanong Nuea	10110	2025-12-18 04:35:38.754	1039
104001	104001	บางแค	Bang Khae	10160	2025-12-18 04:35:38.756	1040
104002	104002	บางแคเหนือ	Bang Khae Nuea	10160	2025-12-18 04:35:38.758	1040
104003	104003	บางไผ่	Bang Phai	10160	2025-12-18 04:35:38.76	1040
104004	104004	หลักสอง	Lak Song	10160	2025-12-18 04:35:38.762	1040
104101	104101	ทุ่งสองห้อง	Thung Song Hong	10210	2025-12-18 04:35:38.764	1041
104102	104102	ตลาดบางเขน	Talat Bang Khen	10210	2025-12-18 04:35:38.766	1041
104201	104201	สายไหม	Sai Mai	10220	2025-12-18 04:35:38.768	1042
104202	104202	ออเงิน	O Ngoen	10220	2025-12-18 04:35:38.77	1042
104203	104203	คลองถนน	Khlong Thanon	10220	2025-12-18 04:35:38.772	1042
104301	104301	คันนายาว	Khan Na Yao	10230	2025-12-18 04:35:38.774	1043
104401	104401	สะพานสูง	Sapan Sung	10240	2025-12-18 04:35:38.776	1044
104501	104501	วังทองหลาง	Wang Thonglang	10310	2025-12-18 04:35:38.779	1045
104601	104601	สามวาตะวันตก	Sam Wa Tawantok	10510	2025-12-18 04:35:38.781	1046
104602	104602	สามวาตะวันออก	Sam Wa Tawan-ok	10510	2025-12-18 04:35:38.784	1046
104603	104603	บางชัน	Bang Chan	10510	2025-12-18 04:35:38.786	1046
104604	104604	ทรายกองดิน	Sai Kong Din	10510	2025-12-18 04:35:38.788	1046
104605	104605	ทรายกองดินใต้	Sai Kong Din Tai	10510	2025-12-18 04:35:38.789	1046
104801	104801	ทวีวัฒนา	Thawi Watthana	10170	2025-12-18 04:35:38.793	1048
104802	104802	ศาลาธรรมสพน์	Sala Thammasop	10170	2025-12-18 04:35:38.794	1048
104901	104901	บางมด	Bang Mot	10140	2025-12-18 04:35:38.796	1049
104902	104902	ทุ่งครุ	Thung Khru	10140	2025-12-18 04:35:38.797	1049
105001	105001	บางบอน	Bang Bon	10150	2025-12-18 04:35:38.799	1050
110101	110101	ปากน้ำ	Pak Nam	10270	2025-12-18 04:35:38.8	1101
110102	110102	สำโรงเหนือ	Samrong Nuea	10270	2025-12-18 04:35:38.801	1101
110103	110103	บางเมือง	Bang Mueang	10270	2025-12-18 04:35:38.803	1101
110104	110104	ท้ายบ้าน	Thai Ban	10280	2025-12-18 04:35:38.804	1101
110108	110108	บางปูใหม่	Bang Pu Mai	10280	2025-12-18 04:35:38.805	1101
110110	110110	แพรกษา	Phraek Sa	10280	2025-12-18 04:35:38.807	1101
110111	110111	บางโปรง	Bang Prong	10270	2025-12-18 04:35:38.808	1101
110112	110112	บางปู	Bang Pu	10270	2025-12-18 04:35:38.81	1101
110113	110113	บางด้วน	Bang Duan	10270	2025-12-18 04:35:38.812	1101
110114	110114	บางเมืองใหม่	Bang Mueang Mai	10270	2025-12-18 04:35:38.813	1101
110115	110115	เทพารักษ์	Thepharak	10270	2025-12-18 04:35:38.814	1101
110116	110116	ท้ายบ้านใหม่	Thai Ban Mai	10280	2025-12-18 04:35:38.816	1101
110117	110117	แพรกษาใหม่	Phraek Sa Mai	10280	2025-12-18 04:35:38.817	1101
110201	110201	บางบ่อ	Bang Bo	10560	2025-12-18 04:35:38.819	1102
110202	110202	บ้านระกาศ	Ban Rakat	10560	2025-12-18 04:35:38.82	1102
110203	110203	บางพลีน้อย	Bang Phli Noi	10560	2025-12-18 04:35:38.821	1102
110204	110204	บางเพรียง	Bang Phriang	10560	2025-12-18 04:35:38.822	1102
110205	110205	คลองด่าน	Khlong Dan	10550	2025-12-18 04:35:38.823	1102
110206	110206	คลองสวน	Khlong Suan	10560	2025-12-18 04:35:38.824	1102
110207	110207	เปร็ง	Preng	10560	2025-12-18 04:35:38.825	1102
110208	110208	คลองนิยมยาตรา	Khlong Niyom Yattra	10560	2025-12-18 04:35:38.826	1102
110301	110301	บางพลีใหญ่	Bang Phli Yai	10540	2025-12-18 04:35:38.827	1103
110302	110302	บางแก้ว	Bang Kaeo	10540	2025-12-18 04:35:38.828	1103
110303	110303	บางปลา	Bang Pla	10540	2025-12-18 04:35:38.829	1103
110304	110304	บางโฉลง	Bang Chalong	10540	2025-12-18 04:35:38.83	1103
110405	110405	บางหญ้าแพรก	Bang Ya Phraek	10130	2025-12-18 04:35:38.837	1104
110406	110406	บางหัวเสือ	Bang Hua Suea	10130	2025-12-18 04:35:38.838	1104
110407	110407	สำโรงใต้	Samrong Tai	10130	2025-12-18 04:35:38.839	1104
110408	110408	บางยอ	Bang Yo	10130	2025-12-18 04:35:38.84	1104
110409	110409	บางกะเจ้า	Bang Kachao	10130	2025-12-18 04:35:38.841	1104
110410	110410	บางน้ำผึ้ง	Bang Namphueng	10130	2025-12-18 04:35:38.842	1104
110411	110411	บางกระสอบ	Bang Krasop	10130	2025-12-18 04:35:38.842	1104
110412	110412	บางกอบัว	Bang Ko Bua	10130	2025-12-18 04:35:38.843	1104
110413	110413	ทรงคนอง	Song Khanong	10130	2025-12-18 04:35:38.844	1104
110414	110414	สำโรง	Samrong	10130	2025-12-18 04:35:38.845	1104
110415	110415	สำโรงกลาง	Samrong Klang	10130	2025-12-18 04:35:38.846	1104
110501	110501	นาเกลือ	Na Kluea	10290	2025-12-18 04:35:38.848	1105
110502	110502	บ้านคลองสวน	Ban Khlong Suan	10290	2025-12-18 04:35:38.849	1105
110503	110503	แหลมฟ้าผ่า	Laem Fa Pha	10290	2025-12-18 04:35:38.85	1105
110504	110504	ปากคลองบางปลากด	Pak Klong Bang Pla Kot	10290	2025-12-18 04:35:38.851	1105
110505	110505	ในคลองบางปลากด	Nai Khlong Bang Pla Kot	10290	2025-12-18 04:35:38.852	1105
110601	110601	บางเสาธง	Bang Sao Thong	10540	2025-12-18 04:35:38.853	1106
110602	110602	ศีรษะจรเข้น้อย	Sisa Chorakhe Noi	10540	2025-12-18 04:35:38.854	1106
110603	110603	ศีรษะจรเข้ใหญ่	Sisa Chorakhe Yai	10540	2025-12-18 04:35:38.855	1106
120101	120101	สวนใหญ่	Suan Yai	11000	2025-12-18 04:35:38.855	1201
120102	120102	ตลาดขวัญ	Talat Khwan	11000	2025-12-18 04:35:38.856	1201
120103	120103	บางเขน	Bang Khen	11000	2025-12-18 04:35:38.857	1201
120104	120104	บางกระสอ	Bang Kraso	11000	2025-12-18 04:35:38.858	1201
120105	120105	ท่าทราย	Tha Sai	11000	2025-12-18 04:35:38.859	1201
120106	120106	บางไผ่	Bang Phai	11000	2025-12-18 04:35:38.86	1201
120107	120107	บางศรีเมือง	Bang Si Mueang	11000	2025-12-18 04:35:38.861	1201
120108	120108	บางกร่าง	Bang Krang	11000	2025-12-18 04:35:38.862	1201
120109	120109	ไทรม้า	Sai Ma	11000	2025-12-18 04:35:38.863	1201
120110	120110	บางรักน้อย	Bang Rak Noi	11000	2025-12-18 04:35:38.864	1201
120201	120201	วัดชลอ	Wat Chalo	11130	2025-12-18 04:35:38.865	1202
120202	120202	บางกรวย	Bang Kruai	11130	2025-12-18 04:35:38.866	1202
120203	120203	บางสีทอง	Bang Si Thong	11130	2025-12-18 04:35:38.867	1202
120204	120204	บางขนุน	Bang Khanun	11130	2025-12-18 04:35:38.868	1202
120205	120205	บางขุนกอง	Bang Khun Kong	11130	2025-12-18 04:35:38.869	1202
120206	120206	บางคูเวียง	Bang Khu Wiang	11130	2025-12-18 04:35:38.87	1202
120207	120207	มหาสวัสดิ์	Maha Sawat	11130	2025-12-18 04:35:38.871	1202
120208	120208	ปลายบาง	Plai Bang	11130	2025-12-18 04:35:38.872	1202
120209	120209	ศาลากลาง	Sala Klang	11130	2025-12-18 04:35:38.873	1202
120301	120301	บางม่วง	Bang Muang	11140	2025-12-18 04:35:38.874	1203
120302	120302	บางแม่นาง	Bang Mae Nang	11140	2025-12-18 04:35:38.875	1203
120303	120303	บางเลน	Bang Len	11140	2025-12-18 04:35:38.876	1203
120304	120304	เสาธงหิน	Sao Thong Hin	11140	2025-12-18 04:35:38.877	1203
120305	120305	บางใหญ่	Bang Yai	11140	2025-12-18 04:35:38.878	1203
120306	120306	บ้านใหม่	Ban Mai	11140	2025-12-18 04:35:38.879	1203
120401	120401	โสนลอย	Sano Loi	11110	2025-12-18 04:35:38.881	1204
120402	120402	บางบัวทอง	Bang Bua Thong	11110	2025-12-18 04:35:38.882	1204
120403	120403	บางรักใหญ่	Bang Rak Yai	11110	2025-12-18 04:35:38.883	1204
120404	120404	บางคูรัด	Bang Khu Rat	11110	2025-12-18 04:35:38.885	1204
120405	120405	ละหาร	Lahan	11110	2025-12-18 04:35:38.886	1204
120406	120406	ลำโพ	Lam Pho	11110	2025-12-18 04:35:38.888	1204
104701	104701	บางนา	Bang Na	10260	2025-12-18 04:35:38.791	1047
120407	120407	พิมลราช	Phimon Rat	11110	2025-12-18 04:35:38.889	1204
120408	120408	บางรักพัฒนา	Bang Rak Phatthana	11110	2025-12-18 04:35:38.89	1204
120501	120501	ไทรน้อย	Sai Noi	11150	2025-12-18 04:35:38.892	1205
120502	120502	ราษฎร์นิยม	Rat Niyom	11150	2025-12-18 04:35:38.893	1205
120503	120503	หนองเพรางาย	Nong Phrao Ngai	11150	2025-12-18 04:35:38.895	1205
120504	120504	ไทรใหญ่	Sai Yai	11150	2025-12-18 04:35:38.896	1205
120505	120505	ขุนศรี	Khun Si	11150	2025-12-18 04:35:38.897	1205
120506	120506	คลองขวาง	Khlong Khwang	11150	2025-12-18 04:35:38.898	1205
120507	120507	ทวีวัฒนา	Thawi Watthana	11150	2025-12-18 04:35:38.9	1205
120601	120601	ปากเกร็ด	Pak Kret	11120	2025-12-18 04:35:38.901	1206
120602	120602	บางตลาด	Bang Talat	11120	2025-12-18 04:35:38.903	1206
120607	120607	ท่าอิฐ	Tha It	11120	2025-12-18 04:35:38.909	1206
120608	120608	เกาะเกร็ด	Ko Kret	11120	2025-12-18 04:35:38.911	1206
120609	120609	อ้อมเกร็ด	Om Kret	11120	2025-12-18 04:35:38.912	1206
120610	120610	คลองข่อย	Khlong Khoi	11120	2025-12-18 04:35:38.913	1206
120611	120611	บางพลับ	Bang Phlap	11120	2025-12-18 04:35:38.914	1206
120612	120612	คลองเกลือ	Khlong Kluea	11120	2025-12-18 04:35:38.916	1206
130101	130101	บางปรอก	Bang Parok	12000	2025-12-18 04:35:38.917	1301
130102	130102	บ้านใหม่	Ban Mai	12000	2025-12-18 04:35:38.918	1301
130103	130103	บ้านกลาง	Ban Klang	12000	2025-12-18 04:35:38.919	1301
130104	130104	บ้านฉาง	Ban Chang	12000	2025-12-18 04:35:38.921	1301
130105	130105	บ้านกระแชง	Ban Krachaeng	12000	2025-12-18 04:35:38.922	1301
130106	130106	บางขะแยง	Bang Khayaeng	12000	2025-12-18 04:35:38.923	1301
130107	130107	บางคูวัด	Bang Khu Wat	12000	2025-12-18 04:35:38.925	1301
130108	130108	บางหลวง	Bang Luang	12000	2025-12-18 04:35:38.926	1301
130109	130109	บางเดื่อ	Bang Duea	12000	2025-12-18 04:35:38.928	1301
130110	130110	บางพูด	Bang Phut	12000	2025-12-18 04:35:38.929	1301
130111	130111	บางพูน	Bang Phun	12000	2025-12-18 04:35:38.931	1301
130112	130112	บางกะดี	Bang Kadi	12000	2025-12-18 04:35:38.932	1301
130113	130113	สวนพริกไทย	Suan Phrikthai	12000	2025-12-18 04:35:38.934	1301
130114	130114	หลักหก	Lak Hok	12000	2025-12-18 04:35:38.935	1301
130201	130201	คลองหนึ่ง	Khlong Nueng	12120	2025-12-18 04:35:38.937	1302
130202	130202	คลองสอง	Khlong Song	12120	2025-12-18 04:35:38.939	1302
130203	130203	คลองสาม	Khlong Sam	12120	2025-12-18 04:35:38.94	1302
130204	130204	คลองสี่	Khlong Si	12120	2025-12-18 04:35:38.942	1302
130205	130205	คลองห้า	Khlong Ha	12120	2025-12-18 04:35:38.943	1302
130206	130206	คลองหก	Khlong Hok	12120	2025-12-18 04:35:38.945	1302
130207	130207	คลองเจ็ด	Khlong Chet	12120	2025-12-18 04:35:38.946	1302
130301	130301	ประชาธิปัตย์	Prachathipat	12130	2025-12-18 04:35:38.948	1303
130302	130302	บึงยี่โถ	Bueng Yitho	12130	2025-12-18 04:35:38.949	1303
130303	130303	รังสิต	Rangsit	12110	2025-12-18 04:35:38.95	1303
130304	130304	ลำผักกูด	Lam Phak Kut	12110	2025-12-18 04:35:38.952	1303
130305	130305	บึงสนั่น	Bueng Sanan	12110	2025-12-18 04:35:38.954	1303
130306	130306	บึงน้ำรักษ์	Bueng Nam Rak	12110	2025-12-18 04:35:38.955	1303
130401	130401	บึงบา	Bueng Ba	12170	2025-12-18 04:35:38.957	1304
130402	130402	บึงบอน	Bueng Bon	12170	2025-12-18 04:35:38.958	1304
130403	130403	บึงกาสาม	Bueng Ka Sam	12170	2025-12-18 04:35:38.96	1304
130404	130404	บึงชำอ้อ	Bueng Cham O	12170	2025-12-18 04:35:38.961	1304
130405	130405	หนองสามวัง	Nong Sam Wang	12170	2025-12-18 04:35:38.962	1304
130406	130406	ศาลาครุ	Sala Khru	12170	2025-12-18 04:35:38.964	1304
130407	130407	นพรัตน์	Noppharat	12170	2025-12-18 04:35:38.966	1304
130501	130501	ระแหง	Rahaeng	12140	2025-12-18 04:35:38.967	1305
130502	130502	ลาดหลุมแก้ว	Lat Lum Kaeo	12140	2025-12-18 04:35:38.969	1305
130503	130503	คูบางหลวง	Khu Bang Luang	12140	2025-12-18 04:35:38.97	1305
130504	130504	คูขวาง	Khu Khwang	12140	2025-12-18 04:35:38.972	1305
130505	130505	คลองพระอุดม	Khlong Phra Udom	12140	2025-12-18 04:35:38.973	1305
130506	130506	บ่อเงิน	Bo Ngoen	12140	2025-12-18 04:35:38.975	1305
130507	130507	หน้าไม้	Na Mai	12140	2025-12-18 04:35:38.976	1305
130601	130601	คูคต	Khu Khot	12130	2025-12-18 04:35:38.978	1306
130602	130602	ลาดสวาย	Lat Sawai	12150	2025-12-18 04:35:38.979	1306
130603	130603	บึงคำพร้อย	Bueng Kham Phroi	12150	2025-12-18 04:35:38.981	1306
130604	130604	ลำลูกกา	Lam Luk Ka	12150	2025-12-18 04:35:38.982	1306
130605	130605	บึงทองหลาง	Bueng Thonglang	12150	2025-12-18 04:35:38.984	1306
130606	130606	ลำไทร	Lam Sai	12150	2025-12-18 04:35:38.985	1306
130607	130607	บึงคอไห	Bueng Kho Hai	12150	2025-12-18 04:35:38.987	1306
130608	130608	พืชอุดม	Phuet Udom	12150	2025-12-18 04:35:38.988	1306
130701	130701	บางเตย	Bang Toei	12160	2025-12-18 04:35:38.99	1307
130702	130702	คลองควาย	Khlong Khwai	12160	2025-12-18 04:35:38.991	1307
130703	130703	สามโคก	Sam Khok	12160	2025-12-18 04:35:38.993	1307
130704	130704	กระแชง	Krachaeng	12160	2025-12-18 04:35:38.995	1307
130705	130705	บางโพธิ์เหนือ	Bang Pho Nuea	12160	2025-12-18 04:35:38.996	1307
130706	130706	เชียงรากใหญ่	Chiang Rak Yai	12160	2025-12-18 04:35:38.998	1307
130709	130709	เชียงรากน้อย	Chiang Rak Noi	12160	2025-12-18 04:35:39.003	1307
130710	130710	บางกระบือ	Bang Krabue	12160	2025-12-18 04:35:39.005	1307
130711	130711	ท้ายเกาะ	Thai Ko	12160	2025-12-18 04:35:39.006	1307
140101	140101	ประตูชัย	Pratu Chai	13000	2025-12-18 04:35:39.008	1401
140102	140102	กะมัง	Kamang	13000	2025-12-18 04:35:39.01	1401
140103	140103	หอรัตนไชย	Ho Rattanachai	13000	2025-12-18 04:35:39.011	1401
140104	140104	หัวรอ	Hua Ro	13000	2025-12-18 04:35:39.013	1401
140105	140105	ท่าวาสุกรี	Tha Wasukri	13000	2025-12-18 04:35:39.015	1401
140106	140106	ไผ่ลิง	Phai Ling	13000	2025-12-18 04:35:39.016	1401
140107	140107	ปากกราน	Pak Kran	13000	2025-12-18 04:35:39.019	1401
140108	140108	ภูเขาทอง	Phukhao Thong	13000	2025-12-18 04:35:39.021	1401
140109	140109	สำเภาล่ม	Samphao Lom	13000	2025-12-18 04:35:39.023	1401
140110	140110	สวนพริก	Suan Phrik	13000	2025-12-18 04:35:39.024	1401
140111	140111	คลองตะเคียน	Khlong Takhian	13000	2025-12-18 04:35:39.026	1401
140112	140112	วัดตูม	Wat Tum	13000	2025-12-18 04:35:39.028	1401
140113	140113	หันตรา	Hantra	13000	2025-12-18 04:35:39.031	1401
140114	140114	ลุมพลี	Lumphli	13000	2025-12-18 04:35:39.033	1401
140115	140115	บ้านใหม่	Ban Mai	13000	2025-12-18 04:35:39.035	1401
140116	140116	บ้านเกาะ	Ban Ko	13000	2025-12-18 04:35:39.038	1401
140117	140117	คลองสวนพลู	Khlong Suan Phlu	13000	2025-12-18 04:35:39.04	1401
140118	140118	คลองสระบัว	Khlong Sa Bua	13000	2025-12-18 04:35:39.042	1401
140119	140119	เกาะเรียน	Ko Rian	13000	2025-12-18 04:35:39.044	1401
140120	140120	บ้านป้อม	Ban Pom	13000	2025-12-18 04:35:39.045	1401
140121	140121	บ้านรุน	Ban Run	13000	2025-12-18 04:35:39.048	1401
140201	140201	ท่าเรือ	Tha Ruea	13130	2025-12-18 04:35:39.05	1402
140202	140202	จำปา	Champa	13130	2025-12-18 04:35:39.052	1402
140203	140203	ท่าหลวง	Tha Luang	13130	2025-12-18 04:35:39.054	1402
140204	140204	บ้านร่อม	Ban Rom	13130	2025-12-18 04:35:39.056	1402
140205	140205	ศาลาลอย	Sala Loi	13130	2025-12-18 04:35:39.058	1402
140206	140206	วังแดง	Wang Daeng	13130	2025-12-18 04:35:39.06	1402
140207	140207	โพธิ์เอน	Pho En	13130	2025-12-18 04:35:39.062	1402
140208	140208	ปากท่า	Pak Tha	13130	2025-12-18 04:35:39.064	1402
140209	140209	หนองขนาก	Nong Khanak	13130	2025-12-18 04:35:39.066	1402
140210	140210	ท่าเจ้าสนุก	Tha Chao Sanuk	13130	2025-12-18 04:35:39.069	1402
140301	140301	นครหลวง	Nakhon Luang	13260	2025-12-18 04:35:39.071	1403
140302	140302	ท่าช้าง	Tha Chang	13260	2025-12-18 04:35:39.073	1403
140303	140303	บ่อโพง	Bo Phong	13260	2025-12-18 04:35:39.076	1403
140304	140304	บ้านชุ้ง	Ban Chung	13260	2025-12-18 04:35:39.079	1403
140305	140305	ปากจั่น	Pak Chan	13260	2025-12-18 04:35:39.081	1403
140306	140306	บางระกำ	Bang Rakam	13260	2025-12-18 04:35:39.083	1403
140307	140307	บางพระครู	Bang Phra Khru	13260	2025-12-18 04:35:39.085	1403
140308	140308	แม่ลา	Mae La	13260	2025-12-18 04:35:39.087	1403
140309	140309	หนองปลิง	Nong Pling	13260	2025-12-18 04:35:39.09	1403
140310	140310	คลองสะแก	Khlong Sakae	13260	2025-12-18 04:35:39.092	1403
140311	140311	สามไถ	Sam Thai	13260	2025-12-18 04:35:39.094	1403
140312	140312	พระนอน	Phra Non	13260	2025-12-18 04:35:39.097	1403
140401	140401	บางไทร	Bang Sai	13190	2025-12-18 04:35:39.099	1404
140402	140402	บางพลี	Bang Phli	13190	2025-12-18 04:35:39.101	1404
140403	140403	สนามชัย	Sanam Chai	13190	2025-12-18 04:35:39.104	1404
140404	140404	บ้านแป้ง	Ban Paeng	13190	2025-12-18 04:35:39.108	1404
140405	140405	หน้าไม้	Na Mai	13190	2025-12-18 04:35:39.114	1404
140406	140406	บางยี่โท	Bang Yi Tho	13190	2025-12-18 04:35:39.12	1404
140407	140407	แคออก	Khae Ok	13190	2025-12-18 04:35:39.123	1404
140408	140408	แคตก	Khae Tok	13190	2025-12-18 04:35:39.126	1404
140409	140409	ช่างเหล็ก	Chang Lek	13190	2025-12-18 04:35:39.128	1404
140410	140410	กระแชง	Krachaeng	13190	2025-12-18 04:35:39.13	1404
140411	140411	บ้านกลึง	Ban Klueng	13190	2025-12-18 04:35:39.131	1404
140412	140412	ช้างน้อย	Chang Noi	13190	2025-12-18 04:35:39.133	1404
140413	140413	ห่อหมก	Homok	13190	2025-12-18 04:35:39.134	1404
140414	140414	ไผ่พระ	Phai Phra	13190	2025-12-18 04:35:39.136	1404
140415	140415	กกแก้วบูรพา	Kok Kaeo Burapha	13190	2025-12-18 04:35:39.137	1404
140416	140416	ไม้ตรา	Mai Tra	13190	2025-12-18 04:35:39.139	1404
140417	140417	บ้านม้า	Ban Ma	13190	2025-12-18 04:35:39.14	1404
140418	140418	บ้านเกาะ	Ban Ko	13190	2025-12-18 04:35:39.142	1404
140422	140422	เชียงรากน้อย	Chiang Rak Noi	13290	2025-12-18 04:35:39.148	1404
140501	140501	บางบาล	Bang Ban	13250	2025-12-18 04:35:39.151	1405
140502	140502	วัดยม	Wat Yom	13250	2025-12-18 04:35:39.152	1405
140503	140503	ไทรน้อย	Sai Noi	13250	2025-12-18 04:35:39.154	1405
140504	140504	สะพานไทย	Saphan Thai	13250	2025-12-18 04:35:39.155	1405
140505	140505	มหาพราหมณ์	Maha Phram	13250	2025-12-18 04:35:39.157	1405
140506	140506	กบเจา	Kop Chao	13250	2025-12-18 04:35:39.158	1405
140507	140507	บ้านคลัง	Ban Khlang	13250	2025-12-18 04:35:39.16	1405
140508	140508	พระขาว	Phra Khao	13250	2025-12-18 04:35:39.161	1405
140509	140509	น้ำเต้า	Namtao	13250	2025-12-18 04:35:39.163	1405
140510	140510	ทางช้าง	Thang Chang	13250	2025-12-18 04:35:39.165	1405
140511	140511	วัดตะกู	Wat Taku	13250	2025-12-18 04:35:39.166	1405
140512	140512	บางหลวง	Bang Luang	13250	2025-12-18 04:35:39.168	1405
140513	140513	บางหลวงโดด	Bang Luang Dot	13250	2025-12-18 04:35:39.169	1405
140514	140514	บางหัก	Bang Hak	13250	2025-12-18 04:35:39.17	1405
140515	140515	บางชะนี	Bang Chani	13250	2025-12-18 04:35:39.172	1405
140516	140516	บ้านกุ่ม	Ban Kum	13250	2025-12-18 04:35:39.173	1405
140601	140601	บ้านเลน	Ban Len	13160	2025-12-18 04:35:39.175	1406
140602	140602	เชียงรากน้อย	Chiang Rak Noi	13180	2025-12-18 04:35:39.176	1406
140603	140603	บ้านโพ	Ban Pho	13160	2025-12-18 04:35:39.178	1406
140604	140604	บ้านกรด	Ban Krot	13160	2025-12-18 04:35:39.179	1406
140605	140605	บางกระสั้น	Bang Krasan	13160	2025-12-18 04:35:39.181	1406
140606	140606	คลองจิก	Khlong Chik	13160	2025-12-18 04:35:39.182	1406
140607	140607	บ้านหว้า	Ban Wa	13160	2025-12-18 04:35:39.183	1406
140608	140608	วัดยม	Wat Yom	13160	2025-12-18 04:35:39.184	1406
140609	140609	บางประแดง	Bang Pradaeng	13160	2025-12-18 04:35:39.186	1406
140610	140610	สามเรือน	Sam Ruean	13160	2025-12-18 04:35:39.187	1406
140611	140611	เกาะเกิด	Ko Koet	13160	2025-12-18 04:35:39.188	1406
140612	140612	บ้านพลับ	Ban Phlap	13160	2025-12-18 04:35:39.19	1406
140613	140613	บ้านแป้ง	Ban Paeng	13160	2025-12-18 04:35:39.191	1406
140614	140614	คุ้งลาน	Khung Lan	13160	2025-12-18 04:35:39.192	1406
140615	140615	ตลิ่งชัน	Taling Chan	13160	2025-12-18 04:35:39.193	1406
140616	140616	บ้านสร้าง	Ban Sang	13170	2025-12-18 04:35:39.195	1406
140617	140617	ตลาดเกรียบ	Talat Kriap	13160	2025-12-18 04:35:39.196	1406
140618	140618	ขนอนหลวง	Khanon Luang	13160	2025-12-18 04:35:39.197	1406
140701	140701	บางปะหัน	Bang Pahan	13220	2025-12-18 04:35:39.198	1407
140702	140702	ขยาย	Khayai	13220	2025-12-18 04:35:39.2	1407
140703	140703	บางเดื่อ	Bang Duea	13220	2025-12-18 04:35:39.201	1407
140704	140704	เสาธง	Sao Thong	13220	2025-12-18 04:35:39.202	1407
140705	140705	ทางกลาง	Thang Klang	13220	2025-12-18 04:35:39.203	1407
140706	140706	บางเพลิง	Bang Phloeng	13220	2025-12-18 04:35:39.205	1407
140707	140707	หันสัง	Hansang	13220	2025-12-18 04:35:39.206	1407
140708	140708	บางนางร้า	Bang Nang Ra	13220	2025-12-18 04:35:39.207	1407
140709	140709	ตานิม	Ta Nim	13220	2025-12-18 04:35:39.208	1407
140710	140710	ทับน้ำ	Thap Nam	13220	2025-12-18 04:35:39.21	1407
140711	140711	บ้านม้า	Ban Ma	13220	2025-12-18 04:35:39.211	1407
140712	140712	ขวัญเมือง	Khwan Mueang	13220	2025-12-18 04:35:39.212	1407
140713	140713	บ้านลี่	Ban Li	13220	2025-12-18 04:35:39.215	1407
140714	140714	โพธิ์สามต้น	Pho Sam Ton	13220	2025-12-18 04:35:39.216	1407
140715	140715	พุทเลา	Phutlao	13220	2025-12-18 04:35:39.218	1407
140716	140716	ตาลเอน	Tan En	13220	2025-12-18 04:35:39.219	1407
140717	140717	บ้านขล้อ	Ban Khlo	13220	2025-12-18 04:35:39.22	1407
140801	140801	ผักไห่	Phak Hai	13120	2025-12-18 04:35:39.222	1408
140802	140802	อมฤต	Ammarit	13120	2025-12-18 04:35:39.223	1408
140803	140803	บ้านแค	Ban Khae	13120	2025-12-18 04:35:39.224	1408
140804	140804	ลาดน้ำเค็ม	Lat Nam Khem	13120	2025-12-18 04:35:39.225	1408
140805	140805	ตาลาน	Ta Lan	13120	2025-12-18 04:35:39.227	1408
140806	140806	ท่าดินแดง	Tha Din Daeng	13120	2025-12-18 04:35:39.228	1408
140807	140807	ดอนลาน	Don Lan	13280	2025-12-18 04:35:39.229	1408
140808	140808	นาคู	Na Khu	13280	2025-12-18 04:35:39.231	1408
140809	140809	กุฎี	Kudi	13120	2025-12-18 04:35:39.232	1408
140810	140810	ลำตะเคียน	Lam Takhian	13280	2025-12-18 04:35:39.233	1408
140813	140813	หนองน้ำใหญ่	Nong Nam Yai	13280	2025-12-18 04:35:39.237	1408
140814	140814	ลาดชิด	Lat Chit	13120	2025-12-18 04:35:39.238	1408
140815	140815	หน้าโคก	Na Khok	13120	2025-12-18 04:35:39.24	1408
140816	140816	บ้านใหญ่	Ban Yai	13120	2025-12-18 04:35:39.241	1408
140901	140901	ภาชี	Phachi	13140	2025-12-18 04:35:39.243	1409
140902	140902	โคกม่วง	Khok Muang	13140	2025-12-18 04:35:39.244	1409
140903	140903	ระโสม	Rasom	13140	2025-12-18 04:35:39.246	1409
140904	140904	หนองน้ำใส	Nong Nam Sai	13140	2025-12-18 04:35:39.247	1409
140905	140905	ดอนหญ้านาง	Don Ya Nang	13140	2025-12-18 04:35:39.249	1409
140906	140906	ไผ่ล้อม	Phai Lom	13140	2025-12-18 04:35:39.25	1409
140907	140907	กระจิว	Krachio	13140	2025-12-18 04:35:39.251	1409
140908	140908	พระแก้ว	Phra Kaeo	13140	2025-12-18 04:35:39.253	1409
141001	141001	ลาดบัวหลวง	Lat Bua Luang	13230	2025-12-18 04:35:39.254	1410
141002	141002	หลักชัย	Lak Chai	13230	2025-12-18 04:35:39.256	1410
141003	141003	สามเมือง	Sam Mueang	13230	2025-12-18 04:35:39.257	1410
141004	141004	พระยาบันลือ	Phraya Banlue	13230	2025-12-18 04:35:39.259	1410
141005	141005	สิงหนาท	Singhanat	13230	2025-12-18 04:35:39.26	1410
141006	141006	คู้สลอด	Khu Salot	13230	2025-12-18 04:35:39.261	1410
141007	141007	คลองพระยาบันลือ	Khlong Phraya Banlue	13230	2025-12-18 04:35:39.263	1410
141101	141101	ลำตาเสา	Lam Ta Sao	13170	2025-12-18 04:35:39.264	1411
141102	141102	บ่อตาโล่	Bo Ta Lo	13170	2025-12-18 04:35:39.266	1411
141103	141103	วังน้อย	Wang Noi	13170	2025-12-18 04:35:39.267	1411
141104	141104	ลำไทร	Lam Sai	13170	2025-12-18 04:35:39.269	1411
141105	141105	สนับทึบ	Sanap Thuep	13170	2025-12-18 04:35:39.27	1411
141106	141106	พยอม	Phayom	13170	2025-12-18 04:35:39.271	1411
141107	141107	หันตะเภา	Han Taphao	13170	2025-12-18 04:35:39.273	1411
141108	141108	วังจุฬา	Wang Chula	13170	2025-12-18 04:35:39.274	1411
141109	141109	ข้าวงาม	Khao Ngam	13170	2025-12-18 04:35:39.276	1411
141110	141110	ชะแมบ	Chamaep	13170	2025-12-18 04:35:39.277	1411
141201	141201	เสนา	Sena	13110	2025-12-18 04:35:39.279	1412
141202	141202	บ้านแพน	Ban Phaen	13110	2025-12-18 04:35:39.28	1412
141203	141203	เจ้าเจ็ด	Chao Chet	13110	2025-12-18 04:35:39.282	1412
141204	141204	สามกอ	Sam Ko	13110	2025-12-18 04:35:39.283	1412
141205	141205	บางนมโค	Bang Nom Kho	13110	2025-12-18 04:35:39.285	1412
141206	141206	หัวเวียง	Hua Wiang	13110	2025-12-18 04:35:39.286	1412
141207	141207	มารวิชัย	Manrawichai	13110	2025-12-18 04:35:39.287	1412
141208	141208	บ้านโพธิ์	Ban Pho	13110	2025-12-18 04:35:39.289	1412
141209	141209	รางจรเข้	Rang Chorakhe	13110	2025-12-18 04:35:39.29	1412
141210	141210	บ้านกระทุ่ม	Ban Krathum	13110	2025-12-18 04:35:39.292	1412
141211	141211	บ้านแถว	Ban Thaeo	13110	2025-12-18 04:35:39.293	1412
141212	141212	ชายนา	Chai Na	13110	2025-12-18 04:35:39.295	1412
141213	141213	สามตุ่ม	Sam Tum	13110	2025-12-18 04:35:39.296	1412
141214	141214	ลาดงา	Lat Nga	13110	2025-12-18 04:35:39.297	1412
141215	141215	ดอนทอง	Don Thong	13110	2025-12-18 04:35:39.299	1412
141216	141216	บ้านหลวง	Ban Luang	13110	2025-12-18 04:35:39.3	1412
141217	141217	เจ้าเสด็จ	Chao Sadet	13110	2025-12-18 04:35:39.302	1412
141301	141301	บางซ้าย	Bang Sai	13270	2025-12-18 04:35:39.304	1413
141302	141302	แก้วฟ้า	Kaeo Fa	13270	2025-12-18 04:35:39.305	1413
141303	141303	เต่าเล่า	Tao Lao	13270	2025-12-18 04:35:39.306	1413
141304	141304	ปลายกลัด	Plai Klat	13270	2025-12-18 04:35:39.308	1413
141305	141305	เทพมงคล	Thep Mongkhon	13270	2025-12-18 04:35:39.309	1413
141306	141306	วังพัฒนา	Wang Phatthana	13270	2025-12-18 04:35:39.311	1413
141401	141401	คานหาม	Khan Ham	13210	2025-12-18 04:35:39.312	1414
141402	141402	บ้านช้าง	Ban Chang	13210	2025-12-18 04:35:39.314	1414
141403	141403	สามบัณฑิต	Sam Bandit	13210	2025-12-18 04:35:39.316	1414
141404	141404	บ้านหีบ	Ban Hip	13210	2025-12-18 04:35:39.317	1414
141405	141405	หนองไม้ซุง	Nong Mai Sung	13210	2025-12-18 04:35:39.318	1414
141406	141406	อุทัย	Uthai	13210	2025-12-18 04:35:39.32	1414
141407	141407	เสนา	Sena	13210	2025-12-18 04:35:39.321	1414
141408	141408	หนองน้ำส้ม	Nong Nam Som	13210	2025-12-18 04:35:39.323	1414
141409	141409	โพสาวหาญ	Pho Sao Han	13210	2025-12-18 04:35:39.324	1414
141410	141410	ธนู	Thanu	13210	2025-12-18 04:35:39.326	1414
141411	141411	ข้าวเม่า	Khao Mao	13210	2025-12-18 04:35:39.327	1414
141501	141501	หัวไผ่	Hua Phai	13150	2025-12-18 04:35:39.329	1415
141502	141502	กะทุ่ม	Kathum	13150	2025-12-18 04:35:39.33	1415
141503	141503	มหาราช	Maha Rat	13150	2025-12-18 04:35:39.332	1415
141504	141504	น้ำเต้า	Namtao	13150	2025-12-18 04:35:39.333	1415
141505	141505	บางนา	Bang Na	13150	2025-12-18 04:35:39.335	1415
141506	141506	โรงช้าง	Rong Chang	13150	2025-12-18 04:35:39.336	1415
141507	141507	เจ้าปลุก	Chao Pluk	13150	2025-12-18 04:35:39.338	1415
141508	141508	พิตเพียน	Phitphian	13150	2025-12-18 04:35:39.339	1415
141509	141509	บ้านนา	Ban Na	13150	2025-12-18 04:35:39.34	1415
141510	141510	บ้านขวาง	Ban Khwang	13150	2025-12-18 04:35:39.342	1415
141511	141511	ท่าตอ	Tha To	13150	2025-12-18 04:35:39.343	1415
141512	141512	บ้านใหม่	Ban Mai	13150	2025-12-18 04:35:39.344	1415
141601	141601	บ้านแพรก	Ban Phraek	13240	2025-12-18 04:35:39.346	1416
141602	141602	บ้านใหม่	Ban Mai	13240	2025-12-18 04:35:39.347	1416
141603	141603	สำพะเนียง	Sam Phaniang	13240	2025-12-18 04:35:39.349	1416
141604	141604	คลองน้อย	Khlong Noi	13240	2025-12-18 04:35:39.35	1416
141605	141605	สองห้อง	Song Hong	13240	2025-12-18 04:35:39.351	1416
150101	150101	ตลาดหลวง	Talat Luang	14000	2025-12-18 04:35:39.353	1501
150102	150102	บางแก้ว	Bang Kaeo	14000	2025-12-18 04:35:39.354	1501
150103	150103	ศาลาแดง	Sala Daeng	14000	2025-12-18 04:35:39.356	1501
150104	150104	ป่างิ้ว	Pa Ngio	14000	2025-12-18 04:35:39.357	1501
150105	150105	บ้านแห	Ban Hae	14000	2025-12-18 04:35:39.359	1501
150106	150106	ตลาดกรวด	Talat Kruat	14000	2025-12-18 04:35:39.36	1501
150107	150107	มหาดไทย	Mahatthai	14000	2025-12-18 04:35:39.361	1501
150108	150108	บ้านอิฐ	Ban It	14000	2025-12-18 04:35:39.363	1501
150109	150109	หัวไผ่	Hua Phai	14000	2025-12-18 04:35:39.364	1501
150110	150110	จำปาหล่อ	Champa Lo	14000	2025-12-18 04:35:39.366	1501
150111	150111	โพสะ	Phosa	14000	2025-12-18 04:35:39.367	1501
150112	150112	บ้านรี	Ban Ri	14000	2025-12-18 04:35:39.368	1501
150113	150113	คลองวัว	Khlong Wua	14000	2025-12-18 04:35:39.369	1501
150114	150114	ย่านซื่อ	Yan Sue	14000	2025-12-18 04:35:39.371	1501
150201	150201	จรเข้ร้อง	Chorakhe Rong	14140	2025-12-18 04:35:39.372	1502
150202	150202	ไชยภูมิ	Chaiyaphum	14140	2025-12-18 04:35:39.374	1502
150203	150203	ชัยฤทธิ์	Chaiyarit	14140	2025-12-18 04:35:39.375	1502
150204	150204	เทวราช	Thewarat	14140	2025-12-18 04:35:39.378	1502
150205	150205	ราชสถิตย์	Ratchasathit	14140	2025-12-18 04:35:39.379	1502
150206	150206	ไชโย	Chaiyo	14140	2025-12-18 04:35:39.381	1502
150207	150207	หลักฟ้า	Lak Fa	14140	2025-12-18 04:35:39.383	1502
150208	150208	ชะไว	Chawai	14140	2025-12-18 04:35:39.386	1502
150209	150209	ตรีณรงค์	Tri Narong	14140	2025-12-18 04:35:39.388	1502
150301	150301	บางปลากด	Bang Pla Kot	14130	2025-12-18 04:35:39.389	1503
150302	150302	ป่าโมก	Pa Mok	14130	2025-12-18 04:35:39.391	1503
150303	150303	สายทอง	Sai Thong	14130	2025-12-18 04:35:39.393	1503
150304	150304	โรงช้าง	Rong Chang	14130	2025-12-18 04:35:39.394	1503
150305	150305	บางเสด็จ	Bang Sadet	14130	2025-12-18 04:35:39.396	1503
150306	150306	นรสิงห์	Norasing	14130	2025-12-18 04:35:39.398	1503
150307	150307	เอกราช	Ekkarat	14130	2025-12-18 04:35:39.399	1503
150308	150308	โผงเผง	Phong Pheng	14130	2025-12-18 04:35:39.401	1503
150401	150401	อ่างแก้ว	Ang Kaeo	14120	2025-12-18 04:35:39.403	1504
150402	150402	อินทประมูล	Inthapramun	14120	2025-12-18 04:35:39.404	1504
150403	150403	บางพลับ	Bang Phlap	14120	2025-12-18 04:35:39.406	1504
150404	150404	หนองแม่ไก่	Nong Mae Kai	14120	2025-12-18 04:35:39.408	1504
150405	150405	รำมะสัก	Ram Ma Sak	14120	2025-12-18 04:35:39.409	1504
150406	150406	บางระกำ	Bang Rakam	14120	2025-12-18 04:35:39.411	1504
150407	150407	โพธิ์รังนก	Pho Rang Nok	14120	2025-12-18 04:35:39.413	1504
150408	150408	องครักษ์	Ongkharak	14120	2025-12-18 04:35:39.414	1504
150409	150409	โคกพุทรา	Khok Phutsa	14120	2025-12-18 04:35:39.416	1504
150410	150410	ยางช้าย	Yang Chai	14120	2025-12-18 04:35:39.417	1504
150411	150411	บ่อแร่	Bo Rae	14120	2025-12-18 04:35:39.419	1504
150412	150412	ทางพระ	Thang Phra	14120	2025-12-18 04:35:39.421	1504
150413	150413	สามง่าม	Sam Ngam	14120	2025-12-18 04:35:39.423	1504
150414	150414	บางเจ้าฉ่า	Bang Chao Cha	14120	2025-12-18 04:35:39.424	1504
150415	150415	คำหยาด	Kham Yat	14120	2025-12-18 04:35:39.426	1504
150501	150501	แสวงหา	Sawaeng Ha	14150	2025-12-18 04:35:39.428	1505
150502	150502	ศรีพราน	Si Phran	14150	2025-12-18 04:35:39.43	1505
150503	150503	บ้านพราน	Ban Phran	14150	2025-12-18 04:35:39.431	1505
150504	150504	วังน้ำเย็น	Wang Nam Yen	14150	2025-12-18 04:35:39.433	1505
150505	150505	สีบัวทอง	Si Bua Thong	14150	2025-12-18 04:35:39.435	1505
150506	150506	ห้วยไผ่	Huai Phai	14150	2025-12-18 04:35:39.437	1505
150507	150507	จำลอง	Chamlong	14150	2025-12-18 04:35:39.438	1505
150601	150601	ไผ่จำศิล	Phai Cham Sin	14110	2025-12-18 04:35:39.44	1506
150602	150602	ศาลเจ้าโรงทอง	San Chao Rong Thong	14110	2025-12-18 04:35:39.442	1506
150603	150603	ไผ่ดำพัฒนา	Phai Dam Phatthana	14110	2025-12-18 04:35:39.443	1506
150604	150604	สาวร้องไห้	Sao Rong Hai	14110	2025-12-18 04:35:39.445	1506
150605	150605	ท่าช้าง	Tha Chang	14110	2025-12-18 04:35:39.447	1506
150606	150606	ยี่ล้น	Yi Lon	14110	2025-12-18 04:35:39.449	1506
150607	150607	บางจัก	Bang Chak	14110	2025-12-18 04:35:39.45	1506
150608	150608	ห้วยคันแหลน	Huai Khan Laen	14110	2025-12-18 04:35:39.452	1506
150609	150609	คลองขนาก	Khlong Khanak	14110	2025-12-18 04:35:39.454	1506
150610	150610	ไผ่วง	Phai Wong	14110	2025-12-18 04:35:39.456	1506
150611	150611	สี่ร้อย	Si Roi	14110	2025-12-18 04:35:39.457	1506
150612	150612	ม่วงเตี้ย	Muang Tia	14110	2025-12-18 04:35:39.459	1506
150613	150613	หัวตะพาน	Hua Taphan	14110	2025-12-18 04:35:39.461	1506
150614	150614	หลักแก้ว	Lak Kaeo	14110	2025-12-18 04:35:39.463	1506
150615	150615	ตลาดใหม่	Talat Mai	14110	2025-12-18 04:35:39.465	1506
150701	150701	สามโก้	Samko	14160	2025-12-18 04:35:39.467	1507
150702	150702	ราษฎรพัฒนา	Ratsadon Phatthana	14160	2025-12-18 04:35:39.468	1507
150703	150703	อบทม	Op Thom	14160	2025-12-18 04:35:39.47	1507
150704	150704	โพธิ์ม่วงพันธ์	Pho Muang Phan	14160	2025-12-18 04:35:39.472	1507
150705	150705	มงคลธรรมนิมิต	Mongkhon Tham Nimit	14160	2025-12-18 04:35:39.474	1507
160101	160101	ทะเลชุบศร	Thale Chup Son	15000	2025-12-18 04:35:39.476	1601
160102	160102	ท่าหิน	Tha Hin	15000	2025-12-18 04:35:39.478	1601
160103	160103	กกโก	Kok Ko	15000	2025-12-18 04:35:39.48	1601
160104	160104	โก่งธนู	Kong Thanu	13240	2025-12-18 04:35:39.482	1601
160105	160105	เขาพระงาม	Khao Phra Ngam	15000	2025-12-18 04:35:39.484	1601
160106	160106	เขาสามยอด	Khao Sam Yot	15000	2025-12-18 04:35:39.486	1601
160107	160107	โคกกะเทียม	Khok Kathiam	15000	2025-12-18 04:35:39.488	1601
160108	160108	โคกลำพาน	Khok Lam Phan	15000	2025-12-18 04:35:39.49	1601
160109	160109	โคกตูม	Khok Tum	15210	2025-12-18 04:35:39.492	1601
160110	160110	งิ้วราย	Ngio Rai	15000	2025-12-18 04:35:39.493	1601
160111	160111	ดอนโพธิ์	Don Pho	15000	2025-12-18 04:35:39.495	1601
160112	160112	ตะลุง	Talung	15000	2025-12-18 04:35:39.498	1601
160114	160114	ท่าแค	Tha Khae	15000	2025-12-18 04:35:39.5	1601
160115	160115	ท่าศาลา	Tha Sala	15000	2025-12-18 04:35:39.502	1601
160116	160116	นิคมสร้างตนเอง	Nikhom Sang Ton-eng	15000	2025-12-18 04:35:39.505	1601
160117	160117	บางขันหมาก	Bang Khan Mak	15000	2025-12-18 04:35:39.507	1601
160118	160118	บ้านข่อย	Ban Khoi	15000	2025-12-18 04:35:39.508	1601
160119	160119	ท้ายตลาด	Thai Talat	15000	2025-12-18 04:35:39.511	1601
160120	160120	ป่าตาล	Pa Tan	15000	2025-12-18 04:35:39.513	1601
160121	160121	พรหมมาสตร์	Phrommat	15000	2025-12-18 04:35:39.516	1601
160122	160122	โพธิ์เก้าต้น	Pho Kao Ton	15000	2025-12-18 04:35:39.518	1601
160123	160123	โพธิ์ตรุ	Pho Tru	15000	2025-12-18 04:35:39.52	1601
160124	160124	สี่คลอง	Si Khlong	15000	2025-12-18 04:35:39.524	1601
160125	160125	ถนนใหญ่	Thanon Yai	15000	2025-12-18 04:35:39.527	1601
160201	160201	พัฒนานิคม	Phatthana Nikhom	15140	2025-12-18 04:35:39.529	1602
160202	160202	ช่องสาริกา	Chong Sarika	15220	2025-12-18 04:35:39.531	1602
160203	160203	มะนาวหวาน	Manao Wan	15140	2025-12-18 04:35:39.533	1602
160204	160204	ดีลัง	Di Lang	15220	2025-12-18 04:35:39.536	1602
160205	160205	โคกสลุง	Khok Salung	15140	2025-12-18 04:35:39.538	1602
160206	160206	ชอนน้อย	Chon Noi	15140	2025-12-18 04:35:39.54	1602
160207	160207	หนองบัว	Nong Bua	15140	2025-12-18 04:35:39.542	1602
160208	160208	ห้วยขุนราม	Huai Khun Ram	18220	2025-12-18 04:35:39.544	1602
160209	160209	น้ำสุด	Nam Sut	15140	2025-12-18 04:35:39.546	1602
160301	160301	โคกสำโรง	Khok Samrong	15120	2025-12-18 04:35:39.549	1603
160302	160302	เกาะแก้ว	Ko Kaeo	15120	2025-12-18 04:35:39.552	1603
160303	160303	ถลุงเหล็ก	Thalung Lek	15120	2025-12-18 04:35:39.554	1603
160304	160304	หลุมข้าว	Lum Khao	15120	2025-12-18 04:35:39.557	1603
160306	160306	คลองเกตุ	Khlong Ket	15120	2025-12-18 04:35:39.561	1603
160307	160307	สะแกราบ	Sakae Rap	15120	2025-12-18 04:35:39.563	1603
160308	160308	เพนียด	Phaniat	15120	2025-12-18 04:35:39.565	1603
160309	160309	วังเพลิง	Wang Phloeng	15120	2025-12-18 04:35:39.568	1603
160310	160310	ดงมะรุม	Dong Marum	15120	2025-12-18 04:35:39.571	1603
160318	160318	วังขอนขว้าง	Wang Khon Khwang	15120	2025-12-18 04:35:39.573	1603
160320	160320	วังจั่น	Wang Chan	15120	2025-12-18 04:35:39.575	1603
160322	160322	หนองแขม	Nong Khaem	15120	2025-12-18 04:35:39.577	1603
160401	160401	ลำนารายณ์	Lam Narai	15130	2025-12-18 04:35:39.579	1604
160402	160402	ชัยนารายณ์	Chai Narai	15130	2025-12-18 04:35:39.582	1604
160403	160403	ศิลาทิพย์	Sila Thip	15130	2025-12-18 04:35:39.585	1604
160404	160404	ห้วยหิน	Huai Hin	15130	2025-12-18 04:35:39.587	1604
160405	160405	ม่วงค่อม	Muang Khom	15230	2025-12-18 04:35:39.589	1604
160406	160406	บัวชุม	Bua Chum	15130	2025-12-18 04:35:39.592	1604
160407	160407	ท่าดินดำ	Tha Din Dam	15130	2025-12-18 04:35:39.594	1604
160408	160408	มะกอกหวาน	Makok Wan	15230	2025-12-18 04:35:39.597	1604
160409	160409	ซับตะเคียน	Sap Takhian	15130	2025-12-18 04:35:39.599	1604
160410	160410	นาโสม	Na Som	15190	2025-12-18 04:35:39.602	1604
160411	160411	หนองยายโต๊ะ	Nong Yai To	15130	2025-12-18 04:35:39.604	1604
160412	160412	เกาะรัง	Ko Rang	15130	2025-12-18 04:35:39.607	1604
160414	160414	ท่ามะนาว	Tha Manao	15130	2025-12-18 04:35:39.609	1604
101507	101507	สำเหร่	Samre	10600	2025-12-18 04:35:38.622	1015
160417	160417	นิคมลำนารายณ์	Nikhom Lam Narai	15130	2025-12-18 04:35:39.612	1604
160418	160418	ชัยบาดาล	Chai Badan	15230	2025-12-18 04:35:39.614	1604
160419	160419	บ้านใหม่สามัคคี	Ban Mai Samakkhi	15130	2025-12-18 04:35:39.617	1604
160422	160422	เขาแหลม	Khao Laem	15130	2025-12-18 04:35:39.619	1604
160501	160501	ท่าวุ้ง	Tha Wung	15150	2025-12-18 04:35:39.621	1605
160502	160502	บางคู้	Bang Khu	15150	2025-12-18 04:35:39.624	1605
160503	160503	โพตลาดแก้ว	Pho Talat Kaeo	15150	2025-12-18 04:35:39.626	1605
160504	160504	บางลี่	Bang Li	15150	2025-12-18 04:35:39.629	1605
160505	160505	บางงา	Bang Nga	15150	2025-12-18 04:35:39.631	1605
160506	160506	โคกสลุด	Khok Salut	15150	2025-12-18 04:35:39.634	1605
160507	160507	เขาสมอคอน	Khao Samo Khon	15180	2025-12-18 04:35:39.636	1605
160508	160508	หัวสำโรง	Hua Samrong	15150	2025-12-18 04:35:39.639	1605
160509	160509	ลาดสาลี่	Lat Sali	15150	2025-12-18 04:35:39.642	1605
160510	160510	บ้านเบิก	Ban Boek	15150	2025-12-18 04:35:39.645	1605
160511	160511	มุจลินท์	Mutchalin	15150	2025-12-18 04:35:39.647	1605
160601	160601	ไผ่ใหญ่	Phai Yai	15110	2025-12-18 04:35:39.65	1606
160602	160602	บ้านทราย	Ban Sai	15110	2025-12-18 04:35:39.653	1606
160603	160603	บ้านกล้วย	Ban Kluai	15110	2025-12-18 04:35:39.655	1606
160604	160604	ดงพลับ	Dong Phlap	15110	2025-12-18 04:35:39.658	1606
160605	160605	บ้านชี	Ban Chi	15180	2025-12-18 04:35:39.66	1606
160606	160606	พุคา	Phu Kha	15110	2025-12-18 04:35:39.662	1606
160607	160607	หินปัก	Hin Pak	15110	2025-12-18 04:35:39.665	1606
160608	160608	บางพึ่ง	Bang Phueng	15110	2025-12-18 04:35:39.667	1606
160609	160609	หนองทรายขาว	Nong Sai Khao	15110	2025-12-18 04:35:39.67	1606
160610	160610	บางกะพี้	Bang Kaphi	15110	2025-12-18 04:35:39.673	1606
160611	160611	หนองเต่า	Nong Tao	15110	2025-12-18 04:35:39.676	1606
160612	160612	โพนทอง	Phon Thong	15110	2025-12-18 04:35:39.679	1606
160613	160613	บางขาม	Bang Kham	15180	2025-12-18 04:35:39.681	1606
160614	160614	ดอนดึง	Don Dueng	15110	2025-12-18 04:35:39.684	1606
160615	160615	ชอนม่วง	Chon Muang	15110	2025-12-18 04:35:39.687	1606
160616	160616	หนองกระเบียน	Nong Krabian	15110	2025-12-18 04:35:39.69	1606
160617	160617	สายห้วยแก้ว	Sai Huai Kaeo	15110	2025-12-18 04:35:39.692	1606
160618	160618	มหาสอน	Maha Son	15110	2025-12-18 04:35:39.695	1606
160619	160619	บ้านหมี่	Ban Mi	15110	2025-12-18 04:35:39.698	1606
160620	160620	เชียงงา	Chiang Nga	15110	2025-12-18 04:35:39.7	1606
160621	160621	หนองเมือง	Nong Mueang	15110	2025-12-18 04:35:39.703	1606
160622	160622	สนามแจง	Sanam Chaeng	15110	2025-12-18 04:35:39.705	1606
160701	160701	ท่าหลวง	Tha Luang	15230	2025-12-18 04:35:39.707	1607
160702	160702	แก่งผักกูด	Kaeng Phak Kut	15230	2025-12-18 04:35:39.71	1607
160703	160703	ซับจำปา	Sap Champa	15230	2025-12-18 04:35:39.713	1607
160704	160704	หนองผักแว่น	Nong Phak Waen	15230	2025-12-18 04:35:39.715	1607
160705	160705	ทะเลวังวัด	Thale Wang Wat	15230	2025-12-18 04:35:39.718	1607
160801	160801	สระโบสถ์	Sa Bot	15240	2025-12-18 04:35:39.723	1608
160802	160802	มหาโพธิ	Maha Phot	15240	2025-12-18 04:35:39.725	1608
160803	160803	ทุ่งท่าช้าง	Thung Tha Chang	15240	2025-12-18 04:35:39.728	1608
160804	160804	ห้วยใหญ่	Huai Yai	15240	2025-12-18 04:35:39.73	1608
160805	160805	นิยมชัย	Niyom Chai	15240	2025-12-18 04:35:39.733	1608
160901	160901	โคกเจริญ	Khok Charoen	15250	2025-12-18 04:35:39.736	1609
160902	160902	ยางราก	Yang Rak	15250	2025-12-18 04:35:39.738	1609
160903	160903	หนองมะค่า	Nong Makha	15250	2025-12-18 04:35:39.74	1609
160904	160904	วังทอง	Wang Thong	15250	2025-12-18 04:35:39.742	1609
160905	160905	โคกแสมสาร	Khok Samae San	15250	2025-12-18 04:35:39.745	1609
161001	161001	ลำสนธิ	Lam Sonthi	15190	2025-12-18 04:35:39.747	1610
161002	161002	ซับสมบูรณ์	Sap Sombun	15190	2025-12-18 04:35:39.75	1610
161003	161003	หนองรี	Nong Ri	15190	2025-12-18 04:35:39.752	1610
161004	161004	กุดตาเพชร	Kut Ta Phet	15190	2025-12-18 04:35:39.755	1610
161005	161005	เขารวก	Khao Ruak	15190	2025-12-18 04:35:39.757	1610
161006	161006	เขาน้อย	Khao Noi	15130	2025-12-18 04:35:39.76	1610
161101	161101	หนองม่วง	Nong Muang	15170	2025-12-18 04:35:39.762	1611
161102	161102	บ่อทอง	Bo Thong	15170	2025-12-18 04:35:39.765	1611
161103	161103	ดงดินแดง	Dong Din Daeng	15170	2025-12-18 04:35:39.767	1611
161104	161104	ชอนสมบูรณ์	Chon Sombun	15170	2025-12-18 04:35:39.769	1611
161105	161105	ยางโทน	Yang Thon	15170	2025-12-18 04:35:39.772	1611
161106	161106	ชอนสารเดช	Chon Saradet	15170	2025-12-18 04:35:39.775	1611
170101	170101	บางพุทรา	Bang Phutsa	16000	2025-12-18 04:35:39.777	1701
170102	170102	บางมัญ	Bang Man	16000	2025-12-18 04:35:39.78	1701
170103	170103	โพกรวม	Phok Ruam	16000	2025-12-18 04:35:39.782	1701
170104	170104	ม่วงหมู่	Muang Mu	16000	2025-12-18 04:35:39.784	1701
170105	170105	หัวไผ่	Hua Phai	16000	2025-12-18 04:35:39.787	1701
170106	170106	ต้นโพธิ์	Ton Pho	16000	2025-12-18 04:35:39.789	1701
170107	170107	จักรสีห์	Chaksi	16000	2025-12-18 04:35:39.792	1701
170108	170108	บางกระบือ	Bang Krabue	16000	2025-12-18 04:35:39.794	1701
170201	170201	สิงห์	Sing	16130	2025-12-18 04:35:39.796	1702
170202	170202	ไม้ดัด	Mai Dat	16130	2025-12-18 04:35:39.799	1702
170203	170203	เชิงกลัด	Choeng Klat	16130	2025-12-18 04:35:39.801	1702
170204	170204	โพชนไก่	Pho Chon Kai	16130	2025-12-18 04:35:39.804	1702
170205	170205	แม่ลา	Mae La	16130	2025-12-18 04:35:39.806	1702
170206	170206	บ้านจ่า	Ban Cha	16130	2025-12-18 04:35:39.808	1702
170207	170207	พักทัน	Phak Than	16130	2025-12-18 04:35:39.81	1702
170208	170208	สระแจง	Sa Chaeng	16130	2025-12-18 04:35:39.812	1702
170301	170301	โพทะเล	Pho Thale	16150	2025-12-18 04:35:39.814	1703
170302	170302	บางระจัน	Bang Rachan	16150	2025-12-18 04:35:39.817	1703
170303	170303	โพสังโฆ	Pho Sangkho	16150	2025-12-18 04:35:39.819	1703
170304	170304	ท่าข้าม	Tha Kham	16150	2025-12-18 04:35:39.822	1703
170305	170305	คอทราย	Kho Sai	16150	2025-12-18 04:35:39.824	1703
170306	170306	หนองกระทุ่ม	Nong Krathum	16150	2025-12-18 04:35:39.827	1703
170401	170401	พระงาม	Phra Ngam	16120	2025-12-18 04:35:39.829	1704
170402	170402	พรหมบุรี	Phrom Buri	16160	2025-12-18 04:35:39.832	1704
170403	170403	บางน้ำเชี่ยว	Bang Nam Chiao	16120	2025-12-18 04:35:39.834	1704
170404	170404	บ้านหม้อ	Ban Mo	16120	2025-12-18 04:35:39.837	1704
170405	170405	บ้านแป้ง	Ban Paeng	16120	2025-12-18 04:35:39.839	1704
170406	170406	หัวป่า	Hua Pa	16120	2025-12-18 04:35:39.842	1704
170407	170407	โรงช้าง	Rong Chang	16120	2025-12-18 04:35:39.844	1704
170501	170501	ถอนสมอ	Thon Samo	16140	2025-12-18 04:35:39.847	1705
170502	170502	โพประจักษ์	Pho Prachak	16140	2025-12-18 04:35:39.85	1705
170503	170503	วิหารขาว	Wihan Khao	16140	2025-12-18 04:35:39.853	1705
170504	170504	พิกุลทอง	Phikun Thong	16140	2025-12-18 04:35:39.855	1705
170601	170601	อินทร์บุรี	In Buri	16110	2025-12-18 04:35:39.857	1706
170602	170602	ประศุก	Prasuk	16110	2025-12-18 04:35:39.86	1706
170603	170603	ทับยา	Thap Ya	16110	2025-12-18 04:35:39.863	1706
170604	170604	งิ้วราย	Ngio Rai	16110	2025-12-18 04:35:39.865	1706
170605	170605	ชีน้ำร้าย	Chi Nam Rai	16110	2025-12-18 04:35:39.868	1706
170606	170606	ท่างาม	Tha Ngam	16110	2025-12-18 04:35:39.87	1706
170607	170607	น้ำตาล	Namtan	16110	2025-12-18 04:35:39.872	1706
170608	170608	ทองเอน	Thong En	16110	2025-12-18 04:35:39.874	1706
170609	170609	ห้วยชัน	Huai Chan	16110	2025-12-18 04:35:39.876	1706
170610	170610	โพธิ์ชัย	Pho Chai	16110	2025-12-18 04:35:39.88	1706
180101	180101	ในเมือง	Nai Mueang	17000	2025-12-18 04:35:39.882	1801
180102	180102	บ้านกล้วย	Ban Kluai	17000	2025-12-18 04:35:39.884	1801
180103	180103	ท่าชัย	Tha Chai	17000	2025-12-18 04:35:39.886	1801
180104	180104	ชัยนาท	Chai Nat	17000	2025-12-18 04:35:39.889	1801
180105	180105	เขาท่าพระ	Khao Tha Phra	17000	2025-12-18 04:35:39.892	1801
180106	180106	หาดท่าเสา	Hat Tha Sao	17000	2025-12-18 04:35:39.894	1801
180107	180107	ธรรมามูล	Thammamun	17000	2025-12-18 04:35:39.896	1801
180108	180108	เสือโฮก	Suea Hok	17000	2025-12-18 04:35:39.898	1801
180109	180109	นางลือ	Nang Lue	17000	2025-12-18 04:35:39.9	1801
180201	180201	คุ้งสำเภา	Khung Samphao	17110	2025-12-18 04:35:39.901	1802
180202	180202	วัดโคก	Wat Khok	17110	2025-12-18 04:35:39.904	1802
180203	180203	ศิลาดาน	Sila Dan	17110	2025-12-18 04:35:39.906	1802
180204	180204	ท่าฉนวน	Tha Chanuan	17110	2025-12-18 04:35:39.908	1802
180205	180205	หางน้ำสาคร	Hang Nam Sakhon	17170	2025-12-18 04:35:39.91	1802
180206	180206	ไร่พัฒนา	Rai Phatthana	17170	2025-12-18 04:35:39.912	1802
180207	180207	อู่ตะเภา	U Taphao	17170	2025-12-18 04:35:39.914	1802
180301	180301	วัดสิงห์	Wat Sing	17120	2025-12-18 04:35:39.916	1803
180302	180302	มะขามเฒ่า	Makham Thao	17120	2025-12-18 04:35:39.918	1803
180303	180303	หนองน้อย	Nong Noi	17120	2025-12-18 04:35:39.92	1803
180304	180304	หนองบัว	Nong Bua	17120	2025-12-18 04:35:39.922	1803
180306	180306	หนองขุ่น	Bo Rae	17120	2025-12-18 04:35:39.923	1803
180307	180307	บ่อแร่	Wang Man	17120	2025-12-18 04:35:39.925	1803
180311	180311	วังหมัน	Wang Man	17120	2025-12-18 04:35:39.926	1803
180401	180401	สรรพยา	Sapphaya	17150	2025-12-18 04:35:39.928	1804
180402	180402	ตลุก	Taluk	17150	2025-12-18 04:35:39.929	1804
180403	180403	เขาแก้ว	Khao Kaeo	17150	2025-12-18 04:35:39.931	1804
180404	180404	โพนางดำตก	Pho Nang Dam Tok	17150	2025-12-18 04:35:39.933	1804
180405	180405	โพนางดำออก	Pho Nang Dam Ok	17150	2025-12-18 04:35:39.935	1804
180406	180406	บางหลวง	Bang Luang	17150	2025-12-18 04:35:39.936	1804
180407	180407	หาดอาษา	Hat Asa	17150	2025-12-18 04:35:39.937	1804
180501	180501	แพรกศรีราชา	Phraek Si Racha	17140	2025-12-18 04:35:39.939	1805
180502	180502	เที่ยงแท้	Thiang Thae	17140	2025-12-18 04:35:39.94	1805
180503	180503	ห้วยกรด	Huai Krot	17140	2025-12-18 04:35:39.941	1805
180504	180504	โพงาม	Pho Ngam	17140	2025-12-18 04:35:39.942	1805
180505	180505	บางขุด	Bang Khut	17140	2025-12-18 04:35:39.944	1805
180506	180506	ดงคอน	Dong Khon	17140	2025-12-18 04:35:39.945	1805
180507	180507	ดอนกำ	Don Kam	17140	2025-12-18 04:35:39.946	1805
180508	180508	ห้วยกรดพัฒนา	Huai Krot Phatthana	17140	2025-12-18 04:35:39.948	1805
180601	180601	หันคา	Hankha	17130	2025-12-18 04:35:39.949	1806
180602	180602	บ้านเชี่ยน	Ban Chian	17130	2025-12-18 04:35:39.951	1806
180605	180605	ไพรนกยูง	Phrai Nok Yung	17130	2025-12-18 04:35:39.952	1806
180606	180606	หนองแซง	Nong Saeng	17160	2025-12-18 04:35:39.953	1806
180607	180607	ห้วยงู	Huai Ngu	17160	2025-12-18 04:35:39.954	1806
180608	180608	วังไก่เถื่อน	Wang Kai Thuean	17130	2025-12-18 04:35:39.956	1806
180609	180609	เด่นใหญ่	Den Yai	17130	2025-12-18 04:35:39.957	1806
180611	180611	สามง่ามท่าโบสถ์	Sam Ngam Tha Bot	17160	2025-12-18 04:35:39.958	1806
180701	180701	หนองมะโมง	Nong Mamong	17120	2025-12-18 04:35:39.96	1807
180702	180702	วังตะเคียน	Wang Takhian	17120	2025-12-18 04:35:39.961	1807
180703	180703	สะพานหิน	Saphan Hin	17120	2025-12-18 04:35:39.962	1807
180704	180704	กุดจอก	Kut Chok	17120	2025-12-18 04:35:39.963	1807
180801	180801	เนินขาม	Noen Kham	17130	2025-12-18 04:35:39.965	1808
180802	180802	กะบกเตี้ย	Kabok Tia	17130	2025-12-18 04:35:39.966	1808
180803	180803	สุขเดือนห้า	Suk Duean Ha	17130	2025-12-18 04:35:39.967	1808
190101	190101	ปากเพรียว	Pak Phriao	18000	2025-12-18 04:35:39.969	1901
190105	190105	ดาวเรือง	Dao Rueang	18000	2025-12-18 04:35:39.97	1901
190106	190106	นาโฉง	Na Chong	18000	2025-12-18 04:35:39.971	1901
190107	190107	โคกสว่าง	Khok Sawang	18000	2025-12-18 04:35:39.972	1901
190108	190108	หนองโน	Nong No	18000	2025-12-18 04:35:39.974	1901
190109	190109	หนองยาว	Nong Yao	18000	2025-12-18 04:35:39.975	1901
190110	190110	ปากข้าวสาร	Pak Khao San	18000	2025-12-18 04:35:39.976	1901
190111	190111	หนองปลาไหล	Nong Pla Lai	18000	2025-12-18 04:35:39.978	1901
190112	190112	กุดนกเปล้า	Kut Nok Plao	18000	2025-12-18 04:35:39.979	1901
190113	190113	ตลิ่งชัน	Taling Chan	18000	2025-12-18 04:35:39.981	1901
190114	190114	ตะกุด	Takut	18000	2025-12-18 04:35:39.982	1901
190201	190201	แก่งคอย	Kaeng Khoi	18110	2025-12-18 04:35:39.983	1902
190202	190202	ทับกวาง	Thap Kwang	18260	2025-12-18 04:35:39.985	1902
190203	190203	ตาลเดี่ยว	Tan Diao	18110	2025-12-18 04:35:39.986	1902
190204	190204	ห้วยแห้ง	Huai Haeng	18110	2025-12-18 04:35:39.988	1902
190205	190205	ท่าคล้อ	Tha Khlo	18110	2025-12-18 04:35:39.989	1902
190206	190206	หินซ้อน	Hin Son	18110	2025-12-18 04:35:39.991	1902
190207	190207	บ้านธาตุ	Ban That	18110	2025-12-18 04:35:39.992	1902
190208	190208	บ้านป่า	Ban Pa	18110	2025-12-18 04:35:39.993	1902
190209	190209	ท่าตูม	Tha Tum	18110	2025-12-18 04:35:39.995	1902
190210	190210	ชะอม	Cha-om	18110	2025-12-18 04:35:39.996	1902
190211	190211	สองคอน	Song Khon	18110	2025-12-18 04:35:39.997	1902
190212	190212	เตาปูน	Tao Pun	18110	2025-12-18 04:35:39.999	1902
190213	190213	ชำผักแพว	Cham Phak Phaeo	18110	2025-12-18 04:35:40	1902
190215	190215	ท่ามะปราง	Tha Maprang	18110	2025-12-18 04:35:40.001	1902
190301	190301	หนองแค	Nong Khae	18140	2025-12-18 04:35:40.003	1903
190302	190302	กุ่มหัก	Kum Hak	18140	2025-12-18 04:35:40.004	1903
190303	190303	คชสิทธิ์	Khotchasit	18250	2025-12-18 04:35:40.006	1903
190304	190304	โคกตูม	Khok Tum	18250	2025-12-18 04:35:40.009	1903
190305	190305	โคกแย้	Khok Yae	18230	2025-12-18 04:35:40.01	1903
190306	190306	บัวลอย	Bua Loi	18230	2025-12-18 04:35:40.012	1903
190307	190307	ไผ่ต่ำ	Phai Tam	18140	2025-12-18 04:35:40.013	1903
190308	190308	โพนทอง	Phon Thong	18250	2025-12-18 04:35:40.014	1903
190309	190309	ห้วยขมิ้น	Huai Khamin	18230	2025-12-18 04:35:40.016	1903
190310	190310	ห้วยทราย	Huai Sai	18230	2025-12-18 04:35:40.017	1903
190311	190311	หนองไข่น้ำ	Nong Khai Nam	18140	2025-12-18 04:35:40.019	1903
190312	190312	หนองแขม	Nong Khaem	18140	2025-12-18 04:35:40.02	1903
190313	190313	หนองจิก	Nong Chik	18230	2025-12-18 04:35:40.021	1903
190314	190314	หนองจรเข้	Nong Chorakhe	18140	2025-12-18 04:35:40.023	1903
190315	190315	หนองนาก	Nong Nak	18230	2025-12-18 04:35:40.024	1903
190316	190316	หนองปลาหมอ	Nong Pla Mo	18140	2025-12-18 04:35:40.025	1903
190317	190317	หนองปลิง	Nong Pling	18140	2025-12-18 04:35:40.027	1903
190318	190318	หนองโรง	Nong Rong	18140	2025-12-18 04:35:40.028	1903
190401	190401	หนองหมู	Nong Mu	18150	2025-12-18 04:35:40.029	1904
190402	190402	บ้านลำ	Ban Lam	18150	2025-12-18 04:35:40.031	1904
190403	190403	คลองเรือ	Khlong Ruea	18150	2025-12-18 04:35:40.032	1904
190404	190404	วิหารแดง	Wihan Daeng	18150	2025-12-18 04:35:40.034	1904
190405	190405	หนองสรวง	Nong Suang	18150	2025-12-18 04:35:40.036	1904
190406	190406	เจริญธรรม	Charoen Tham	18150	2025-12-18 04:35:40.037	1904
190501	190501	หนองแซง	Nong Saeng	18170	2025-12-18 04:35:40.039	1905
190502	190502	หนองควายโซ	Nong Khwai So	18170	2025-12-18 04:35:40.04	1905
190503	190503	หนองหัวโพ	Nong Hua Pho	18170	2025-12-18 04:35:40.042	1905
190504	190504	หนองสีดา	Nong Sida	18170	2025-12-18 04:35:40.043	1905
190505	190505	หนองกบ	Nong Kop	18170	2025-12-18 04:35:40.044	1905
190506	190506	ไก่เส่า	Kai Sao	18170	2025-12-18 04:35:40.046	1905
190507	190507	โคกสะอาด	Khok Sa-at	18170	2025-12-18 04:35:40.047	1905
190508	190508	ม่วงหวาน	Muang Wan	18170	2025-12-18 04:35:40.049	1905
190509	190509	เขาดิน	Khao Din	18170	2025-12-18 04:35:40.05	1905
190601	190601	บ้านหมอ	Ban Mo	18130	2025-12-18 04:35:40.052	1906
190602	190602	บางโขมด	Bang Khamot	18130	2025-12-18 04:35:40.054	1906
190603	190603	สร่างโศก	Sang Sok	18130	2025-12-18 04:35:40.055	1906
190604	190604	ตลาดน้อย	Talat Noi	18130	2025-12-18 04:35:40.056	1906
190605	190605	หรเทพ	Horathep	18130	2025-12-18 04:35:40.058	1906
190606	190606	โคกใหญ่	Khok Yai	18130	2025-12-18 04:35:40.06	1906
190607	190607	ไผ่ขวาง	Phai Khwang	18130	2025-12-18 04:35:40.061	1906
190608	190608	บ้านครัว	Ban Khrua	18270	2025-12-18 04:35:40.062	1906
190609	190609	หนองบัว	Nong Bua	18130	2025-12-18 04:35:40.064	1906
190701	190701	ดอนพุด	Don Phut	18210	2025-12-18 04:35:40.065	1907
190702	190702	ไผ่หลิ่ว	Phai Lio	18210	2025-12-18 04:35:40.067	1907
190703	190703	บ้านหลวง	Ban Luang	18210	2025-12-18 04:35:40.068	1907
190704	190704	ดงตะงาว	Dong Ta-ngao	18210	2025-12-18 04:35:40.07	1907
190801	190801	หนองโดน	Nong Don	18190	2025-12-18 04:35:40.071	1908
190802	190802	บ้านกลับ	Ban Klap	18190	2025-12-18 04:35:40.073	1908
190803	190803	ดอนทอง	Don Thong	18190	2025-12-18 04:35:40.074	1908
190804	190804	บ้านโปร่ง	Ban Prong	18190	2025-12-18 04:35:40.075	1908
190901	190901	พระพุทธบาท	Phra Phutthabat	18120	2025-12-18 04:35:40.077	1909
190902	190902	ขุนโขลน	Khun Khlon	18120	2025-12-18 04:35:40.079	1909
190903	190903	ธารเกษม	Than Kasem	18120	2025-12-18 04:35:40.08	1909
190904	190904	นายาว	Na Yao	18120	2025-12-18 04:35:40.082	1909
190905	190905	พุคำจาน	Phu Kham Chan	18120	2025-12-18 04:35:40.083	1909
190906	190906	เขาวง	Khao Wong	18120	2025-12-18 04:35:40.085	1909
190907	190907	ห้วยป่าหวาย	Huai Pa Wai	18120	2025-12-18 04:35:40.086	1909
190908	190908	พุกร่าง	Phu Krang	18120	2025-12-18 04:35:40.088	1909
190909	190909	หนองแก	Nong Kae	18120	2025-12-18 04:35:40.089	1909
191001	191001	เสาไห้	Sao Hai	18160	2025-12-18 04:35:40.091	1910
101601	101601	วัดอรุณ	Wat Arun	10600	2025-12-18 04:35:38.624	1016
191002	191002	บ้านยาง	Ban Yang	18160	2025-12-18 04:35:40.093	1910
191003	191003	หัวปลวก	Hua Pluak	18160	2025-12-18 04:35:40.094	1910
191004	191004	งิ้วงาม	Ngio Ngam	18160	2025-12-18 04:35:40.096	1910
191005	191005	ศาลารีไทย	Sala Ri Thai	18160	2025-12-18 04:35:40.097	1910
191006	191006	ต้นตาล	Ton Tan	18160	2025-12-18 04:35:40.099	1910
191007	191007	ท่าช้าง	Tha Chang	18160	2025-12-18 04:35:40.101	1910
191008	191008	พระยาทด	Phraya Thot	18160	2025-12-18 04:35:40.102	1910
191009	191009	ม่วงงาม	Muang Ngam	18160	2025-12-18 04:35:40.104	1910
191010	191010	เริงราง	Roeng Rang	18160	2025-12-18 04:35:40.106	1910
191011	191011	เมืองเก่า	Mueang Kao	18160	2025-12-18 04:35:40.107	1910
191012	191012	สวนดอกไม้	Suan Dok Mai	18160	2025-12-18 04:35:40.109	1910
191101	191101	มวกเหล็ก	Muak Lek	18180	2025-12-18 04:35:40.111	1911
191102	191102	มิตรภาพ	Mittraphap	18180	2025-12-18 04:35:40.112	1911
191104	191104	หนองย่างเสือ	Nong Yang Suea	18180	2025-12-18 04:35:40.114	1911
191105	191105	ลำสมพุง	Lam Somphung	18180	2025-12-18 04:35:40.116	1911
191107	191107	ลำพญากลาง	Lam Phaya Klang	18180	2025-12-18 04:35:40.117	1911
191109	191109	ซับสนุ่น	Sap Sanun	18220	2025-12-18 04:35:40.119	1911
191201	191201	แสลงพัน	Salaeng Phan	18220	2025-12-18 04:35:40.121	1912
191202	191202	คำพราน	Kham Phran	18220	2025-12-18 04:35:40.122	1912
191203	191203	วังม่วง	Wang Muang	18220	2025-12-18 04:35:40.124	1912
191301	191301	เขาดินพัฒนา	Khao Din Phatthana	18000	2025-12-18 04:35:40.127	1913
191302	191302	บ้านแก้ง	Ban Kaeng	18000	2025-12-18 04:35:40.13	1913
191303	191303	ผึ้งรวง	Phueng Ruang	18000	2025-12-18 04:35:40.132	1913
191304	191304	พุแค	Phu Khae	18240	2025-12-18 04:35:40.134	1913
191305	191305	ห้วยบง	Huai Bong	18000	2025-12-18 04:35:40.136	1913
191306	191306	หน้าพระลาน	Na Phra Lan	18240	2025-12-18 04:35:40.138	1913
200101	200101	บางปลาสร้อย	Bang Pla Soi	20000	2025-12-18 04:35:40.139	2001
200102	200102	มะขามหย่ง	Makham Yong	20000	2025-12-18 04:35:40.141	2001
200103	200103	บ้านโขด	Ban Khot	20000	2025-12-18 04:35:40.142	2001
200104	200104	แสนสุข	Saen Suk	20000	2025-12-18 04:35:40.144	2001
200105	200105	บ้านสวน	Ban Suan	20000	2025-12-18 04:35:40.145	2001
200106	200106	หนองรี	Nong Ri	20000	2025-12-18 04:35:40.147	2001
200107	200107	นาป่า	Na Pa	20000	2025-12-18 04:35:40.148	2001
200108	200108	หนองข้างคอก	Nong Khang Khok	20000	2025-12-18 04:35:40.15	2001
200109	200109	ดอนหัวฬ่อ	Don Hua Lo	20000	2025-12-18 04:35:40.151	2001
200110	200110	หนองไม้แดง	Nong Mai Daeng	20000	2025-12-18 04:35:40.153	2001
200111	200111	บางทราย	Bang Sai	20000	2025-12-18 04:35:40.154	2001
200112	200112	คลองตำหรุ	Khlong Tamru	20000	2025-12-18 04:35:40.156	2001
200113	200113	เหมือง	Mueang	20130	2025-12-18 04:35:40.157	2001
200114	200114	บ้านปึก	Ban Puek	20130	2025-12-18 04:35:40.159	2001
200115	200115	ห้วยกะปิ	Huai Kapi	20000	2025-12-18 04:35:40.16	2001
200116	200116	เสม็ด	Samet	20130	2025-12-18 04:35:40.162	2001
200117	200117	อ่างศิลา	Ang Sila	20000	2025-12-18 04:35:40.163	2001
200118	200118	สำนักบก	Samnak Bok	20000	2025-12-18 04:35:40.165	2001
200201	200201	บ้านบึง	Ban Bueng	20170	2025-12-18 04:35:40.166	2002
200202	200202	คลองกิ่ว	Khlong Kio	20220	2025-12-18 04:35:40.168	2002
200203	200203	มาบไผ่	Map Phai	20170	2025-12-18 04:35:40.17	2002
200204	200204	หนองซ้ำซาก	Nong Samsak	20170	2025-12-18 04:35:40.171	2002
200205	200205	หนองบอนแดง	Nong Bon Daeng	20170	2025-12-18 04:35:40.173	2002
200206	200206	หนองชาก	Nong Chak	20170	2025-12-18 04:35:40.174	2002
200207	200207	หนองอิรุณ	Nong Irun	20220	2025-12-18 04:35:40.176	2002
200208	200208	หนองไผ่แก้ว	Nong Phai Kaeo	20220	2025-12-18 04:35:40.178	2002
200301	200301	หนองใหญ่	Nong Yai	20190	2025-12-18 04:35:40.179	2003
200302	200302	คลองพลู	Khlong Phlu	20190	2025-12-18 04:35:40.181	2003
200303	200303	หนองเสือช้าง	Nong Suea Chang	20190	2025-12-18 04:35:40.183	2003
200304	200304	ห้างสูง	Hang Sung	20190	2025-12-18 04:35:40.184	2003
200305	200305	เขาซก	Khao Sok	20190	2025-12-18 04:35:40.186	2003
200401	200401	บางละมุง	Bang Lamung	20150	2025-12-18 04:35:40.188	2004
200402	200402	หนองปรือ	Nong Prue	20150	2025-12-18 04:35:40.189	2004
200403	200403	หนองปลาไหล	Nong Pla Lai	20150	2025-12-18 04:35:40.191	2004
200404	200404	โป่ง	Pong	20150	2025-12-18 04:35:40.192	2004
200405	200405	เขาไม้แก้ว	Khao Mai Kaeo	20150	2025-12-18 04:35:40.194	2004
200406	200406	ห้วยใหญ่	Huai Yai	20150	2025-12-18 04:35:40.196	2004
200407	200407	ตะเคียนเตี้ย	Takhian Tia	20150	2025-12-18 04:35:40.197	2004
200408	200408	นาเกลือ	Na Kluea	20150	2025-12-18 04:35:40.199	2004
200501	200501	พานทอง	Phan Thong	20160	2025-12-18 04:35:40.2	2005
200502	200502	หนองตำลึง	Nong Tamlueng	20160	2025-12-18 04:35:40.202	2005
200503	200503	มาบโป่ง	Map Pong	20160	2025-12-18 04:35:40.204	2005
200504	200504	หนองกะขะ	Nong Kakha	20160	2025-12-18 04:35:40.205	2005
200505	200505	หนองหงษ์	Nong Hong	20160	2025-12-18 04:35:40.207	2005
200506	200506	โคกขี้หนอน	Khok Khi Non	20160	2025-12-18 04:35:40.209	2005
200507	200507	บ้านเก่า	Ban Kao	20160	2025-12-18 04:35:40.21	2005
200508	200508	หน้าประดู่	Na Pradu	20160	2025-12-18 04:35:40.212	2005
200509	200509	บางนาง	Bang Nang	20160	2025-12-18 04:35:40.214	2005
200510	200510	เกาะลอย	Ko Loi	20160	2025-12-18 04:35:40.215	2005
200511	200511	บางหัก	Bang Hak	20160	2025-12-18 04:35:40.217	2005
200601	200601	พนัสนิคม	Phanat Nikhom	20140	2025-12-18 04:35:40.218	2006
200602	200602	หน้าพระธาตุ	Na Phra That	20140	2025-12-18 04:35:40.22	2006
200603	200603	วัดหลวง	Wat Luang	20140	2025-12-18 04:35:40.221	2006
200604	200604	บ้านเซิด	Ban Soet	20140	2025-12-18 04:35:40.223	2006
200605	200605	นาเริก	Na Roek	20140	2025-12-18 04:35:40.225	2006
200606	200606	หมอนนาง	Mon Nang	20140	2025-12-18 04:35:40.226	2006
200607	200607	สระสี่เหลี่ยม	Sa Si Liam	20140	2025-12-18 04:35:40.228	2006
200608	200608	วัดโบสถ์	Wat Bot	20140	2025-12-18 04:35:40.23	2006
200609	200609	กุฎโง้ง	Kut Ngong	20140	2025-12-18 04:35:40.231	2006
200610	200610	หัวถนน	Hua Thanon	20140	2025-12-18 04:35:40.233	2006
200611	200611	ท่าข้าม	Tha Kham	20140	2025-12-18 04:35:40.235	2006
200613	200613	หนองปรือ	Nong Prue	20140	2025-12-18 04:35:40.236	2006
200614	200614	หนองขยาด	Nong Khayat	20140	2025-12-18 04:35:40.238	2006
200615	200615	ทุ่งขวาง	Thung Khwang	20140	2025-12-18 04:35:40.24	2006
200616	200616	หนองเหียง	Nong Hiang	20140	2025-12-18 04:35:40.242	2006
200617	200617	นาวังหิน	Na Wang Hin	20140	2025-12-18 04:35:40.244	2006
200618	200618	บ้านช้าง	Ban Chang	20140	2025-12-18 04:35:40.245	2006
200620	200620	โคกเพลาะ	Khok Phlo	20140	2025-12-18 04:35:40.247	2006
200621	200621	ไร่หลักทอง	Rai Lak Thong	20140	2025-12-18 04:35:40.249	2006
200622	200622	นามะตูม	Na Matum	20140	2025-12-18 04:35:40.25	2006
200701	200701	ศรีราชา	Si Racha	20110	2025-12-18 04:35:40.252	2007
200702	200702	สุรศักดิ์	Surasak	20110	2025-12-18 04:35:40.253	2007
200703	200703	ทุ่งสุขลา	Thung Sukhla	20230	2025-12-18 04:35:40.255	2007
200704	200704	บึง	Bueng	20230	2025-12-18 04:35:40.256	2007
200705	200705	หนองขาม	Nong Kham	20110	2025-12-18 04:35:40.257	2007
200706	200706	เขาคันทรง	Khao Khansong	20110	2025-12-18 04:35:40.259	2007
200707	200707	บางพระ	Bang Phra	20110	2025-12-18 04:35:40.261	2007
200708	200708	บ่อวิน	Bo Win	20230	2025-12-18 04:35:40.262	2007
200801	200801	ท่าเทววงษ์	Tha Tewatong	20120	2025-12-18 04:35:40.264	2008
200901	200901	สัตหีบ	Sattahip	20180	2025-12-18 04:35:40.266	2009
200902	200902	นาจอมเทียน	Na Chom Thian	20250	2025-12-18 04:35:40.267	2009
200903	200903	พลูตาหลวง	Phlu Ta Luang	20180	2025-12-18 04:35:40.27	2009
200904	200904	บางเสร่	Bang Sare	20250	2025-12-18 04:35:40.272	2009
200905	200905	แสมสาร	Samaesan	20180	2025-12-18 04:35:40.274	2009
201001	201001	บ่อทอง	Bo Thong	20270	2025-12-18 04:35:40.276	2010
201002	201002	วัดสุวรรณ	Wat Suwan	20270	2025-12-18 04:35:40.278	2010
201003	201003	บ่อกวางทอง	Bo Kwang Thong	20270	2025-12-18 04:35:40.279	2010
201004	201004	ธาตุทอง	That Thong	20270	2025-12-18 04:35:40.281	2010
201005	201005	เกษตรสุวรรณ	Kaset Suwan	20270	2025-12-18 04:35:40.283	2010
201006	201006	พลวงทอง	Phluang Thong	20270	2025-12-18 04:35:40.285	2010
201101	201101	เกาะจันทร์	Ko Chan	20240	2025-12-18 04:35:40.287	2011
201102	201102	ท่าบุญมี	Tha Bun Mi	20240	2025-12-18 04:35:40.289	2011
210101	210101	ท่าประดู่	Tha Pradu	21000	2025-12-18 04:35:40.291	2101
210102	210102	เชิงเนิน	Choeng Noen	21000	2025-12-18 04:35:40.293	2101
210103	210103	ตะพง	Taphong	21000	2025-12-18 04:35:40.295	2101
210104	210104	ปากน้ำ	Pak Nam	21000	2025-12-18 04:35:40.297	2101
210105	210105	เพ	Phe	21160	2025-12-18 04:35:40.299	2101
210106	210106	แกลง	Klaeng	21160	2025-12-18 04:35:40.301	2101
210107	210107	บ้านแลง	Ban Laeng	21000	2025-12-18 04:35:40.305	2101
210108	210108	นาตาขวัญ	Na Ta Khwan	21000	2025-12-18 04:35:40.307	2101
210109	210109	เนินพระ	Noen Phra	21000	2025-12-18 04:35:40.309	2101
210110	210110	กะเฉด	Kachet	21100	2025-12-18 04:35:40.311	2101
210111	210111	ทับมา	Thap Ma	21000	2025-12-18 04:35:40.313	2101
210112	210112	น้ำคอก	Nam Khok	21000	2025-12-18 04:35:40.315	2101
210113	210113	ห้วยโป่ง	Huai Pong	21150	2025-12-18 04:35:40.317	2101
210114	210114	มาบตาพุด	Map Ta Phut	21150	2025-12-18 04:35:40.32	2101
210115	210115	สำนักทอง	Samnak Thong	21100	2025-12-18 04:35:40.322	2101
210201	210201	สำนักท้อน	Samnak Thon	21130	2025-12-18 04:35:40.324	2102
210202	210202	พลา	Phla	21130	2025-12-18 04:35:40.326	2102
210203	210203	บ้านฉาง	Ban Chang	21130	2025-12-18 04:35:40.328	2102
210301	210301	ทางเกวียน	Thang Kwian	21110	2025-12-18 04:35:40.331	2103
210302	210302	วังหว้า	Wang Wa	21110	2025-12-18 04:35:40.334	2103
210303	210303	ชากโดน	Chak Don	21110	2025-12-18 04:35:40.335	2103
210304	210304	เนินฆ้อ	Noen Kho	21110	2025-12-18 04:35:40.337	2103
210305	210305	กร่ำ	Kram	21190	2025-12-18 04:35:40.339	2103
210306	210306	ชากพง	Chak Phong	21190	2025-12-18 04:35:40.342	2103
210307	210307	กระแสบน	Krasae Bon	21110	2025-12-18 04:35:40.345	2103
210308	210308	บ้านนา	Ban Na	21110	2025-12-18 04:35:40.346	2103
210309	210309	ทุ่งควายกิน	Thung Khwai Kin	21110	2025-12-18 04:35:40.348	2103
210310	210310	กองดิน	Kong Din	22160	2025-12-18 04:35:40.35	2103
210311	210311	คลองปูน	Khlong Pun	21170	2025-12-18 04:35:40.351	2103
210312	210312	พังราด	Phang Rat	21110	2025-12-18 04:35:40.353	2103
210313	210313	ปากน้ำกระแส	Pak Nam Krasae	21170	2025-12-18 04:35:40.354	2103
210317	210317	ห้วยยาง	Huai Yang	21110	2025-12-18 04:35:40.356	2103
210318	210318	สองสลึง	Song Salueng	21110	2025-12-18 04:35:40.358	2103
210401	210401	วังจันทร์	Wang Chan	21210	2025-12-18 04:35:40.359	2104
210402	210402	ชุมแสง	Chum Saeng	21210	2025-12-18 04:35:40.361	2104
210403	210403	ป่ายุบใน	Pa Yup Nai	21210	2025-12-18 04:35:40.362	2104
210404	210404	พลงตาเอี่ยม	Phlong Ta Iam	21210	2025-12-18 04:35:40.364	2104
210501	210501	บ้านค่าย	Ban Khai	21120	2025-12-18 04:35:40.366	2105
210502	210502	หนองละลอก	Nong Lalok	21120	2025-12-18 04:35:40.368	2105
210503	210503	หนองตะพาน	Nong Taphan	21120	2025-12-18 04:35:40.369	2105
210504	210504	ตาขัน	Ta Khan	21120	2025-12-18 04:35:40.371	2105
210505	210505	บางบุตร	Bang But	21120	2025-12-18 04:35:40.373	2105
210506	210506	หนองบัว	Nong Bua	21120	2025-12-18 04:35:40.374	2105
210507	210507	ชากบก	Chak Bok	21120	2025-12-18 04:35:40.376	2105
210601	210601	ปลวกแดง	Pluak Daeng	21140	2025-12-18 04:35:40.378	2106
210602	210602	ตาสิทธิ์	Ta Sit	21140	2025-12-18 04:35:40.379	2106
210603	210603	ละหาร	Lahan	21140	2025-12-18 04:35:40.381	2106
210604	210604	แม่น้ำคู้	Maenam Khu	21140	2025-12-18 04:35:40.383	2106
210605	210605	มาบยางพร	Map Yang Phon	21140	2025-12-18 04:35:40.386	2106
210606	210606	หนองไร่	Nong Rai	21140	2025-12-18 04:35:40.387	2106
210701	210701	น้ำเป็น	Nam Pen	21110	2025-12-18 04:35:40.389	2107
210702	210702	ห้วยทับมอญ	Huai Thap Mon	21110	2025-12-18 04:35:40.392	2107
210703	210703	ชำฆ้อ	Cham Kho	21110	2025-12-18 04:35:40.394	2107
210704	210704	เขาน้อย	Khao Noy	21110	2025-12-18 04:35:40.396	2107
210801	210801	นิคมพัฒนา	Nikhom Phatthana	21180	2025-12-18 04:35:40.398	2108
210802	210802	มาบข่า	Map Kha	21180	2025-12-18 04:35:40.4	2108
210803	210803	พนานิคม	Phana Nikhom	21180	2025-12-18 04:35:40.401	2108
210804	210804	มะขามคู่	Makham Khu	21180	2025-12-18 04:35:40.403	2108
220101	220101	ตลาด	Talat	22000	2025-12-18 04:35:40.405	2201
220102	220102	วัดใหม่	Wat Mai	22000	2025-12-18 04:35:40.407	2201
220103	220103	คลองนารายณ์	Khlong Narai	22000	2025-12-18 04:35:40.41	2201
220104	220104	เกาะขวาง	Ko Khwang	22000	2025-12-18 04:35:40.412	2201
220105	220105	คมบาง	Khom Bang	22000	2025-12-18 04:35:40.414	2201
220106	220106	ท่าช้าง	Tha Chang	22000	2025-12-18 04:35:40.416	2201
220107	220107	จันทนิมิต	Chanthanimit	22000	2025-12-18 04:35:40.417	2201
220108	220108	บางกะจะ	Bang Kacha	22000	2025-12-18 04:35:40.419	2201
220109	220109	แสลง	Salaeng	22000	2025-12-18 04:35:40.422	2201
220110	220110	หนองบัว	Nong Bua	22000	2025-12-18 04:35:40.425	2201
220111	220111	พลับพลา	Phlapphla	22000	2025-12-18 04:35:40.427	2201
220201	220201	ขลุง	Khlung	22110	2025-12-18 04:35:40.428	2202
220203	220203	เกวียนหัก	Kwian Hak	22110	2025-12-18 04:35:40.431	2202
220204	220204	ตะปอน	Tapon	22110	2025-12-18 04:35:40.432	2202
220205	220205	บางชัน	Bang Chan	22110	2025-12-18 04:35:40.434	2202
220206	220206	วันยาว	Wan Yao	22110	2025-12-18 04:35:40.436	2202
220207	220207	ซึ้ง	Sueng	22110	2025-12-18 04:35:40.438	2202
220208	220208	มาบไพ	Map Phai	22110	2025-12-18 04:35:40.439	2202
220209	220209	วังสรรพรส	Wang Sappharot	22110	2025-12-18 04:35:40.441	2202
220210	220210	ตรอกนอง	Trok Nong	22110	2025-12-18 04:35:40.442	2202
220211	220211	ตกพรม	Tok Phrom	22110	2025-12-18 04:35:40.444	2202
220212	220212	บ่อเวฬุ	Bo Welu	22150	2025-12-18 04:35:40.445	2202
220301	220301	ท่าใหม่	Tha Mai	22120	2025-12-18 04:35:40.447	2203
220302	220302	ยายร้า	Yai Ra	22120	2025-12-18 04:35:40.45	2203
220303	220303	สีพยา	Si Phaya	22120	2025-12-18 04:35:40.451	2203
220304	220304	บ่อพุ	Bo Phu	22120	2025-12-18 04:35:40.452	2203
220305	220305	พลอยแหวน	Phloi Waen	22120	2025-12-18 04:35:40.454	2203
220306	220306	เขาวัว	Khao Wua	22120	2025-12-18 04:35:40.456	2203
220307	220307	เขาบายศรี	Khao Baisi	22120	2025-12-18 04:35:40.457	2203
220308	220308	สองพี่น้อง	Song Phi Nong	22120	2025-12-18 04:35:40.459	2203
220309	220309	ทุ่งเบญจา	Ramphan	22170	2025-12-18 04:35:40.461	2203
220311	220311	รำพัน	Ramphan	22170	2025-12-18 04:35:40.463	2203
220312	220312	โขมง	Khamong	22170	2025-12-18 04:35:40.465	2203
220313	220313	ตะกาดเง้า	Takat Ngao	22120	2025-12-18 04:35:40.467	2203
220314	220314	คลองขุด	Khlong Khut	22120	2025-12-18 04:35:40.468	2203
220324	220324	เขาแก้ว	Khao Kaeo	22170	2025-12-18 04:35:40.47	2203
220401	220401	ทับไทร	Thap Sai	22140	2025-12-18 04:35:40.472	2204
220402	220402	โป่งน้ำร้อน	Pong Nam Ron	22140	2025-12-18 04:35:40.474	2204
220404	220404	หนองตาคง	Nong Ta Khong	22140	2025-12-18 04:35:40.477	2204
220409	220409	เทพนิมิต	Thep Nimit	22140	2025-12-18 04:35:40.478	2204
220410	220410	คลองใหญ่	Khlong Yai	22140	2025-12-18 04:35:40.479	2204
220501	220501	มะขาม	Makham	22150	2025-12-18 04:35:40.481	2205
220502	220502	ท่าหลวง	Tha Luang	22150	2025-12-18 04:35:40.483	2205
220503	220503	ปัถวี	Patthawi	22150	2025-12-18 04:35:40.485	2205
220504	220504	วังแซ้ม	Wang Saem	22150	2025-12-18 04:35:40.489	2205
220506	220506	ฉมัน	Chaman	22150	2025-12-18 04:35:40.492	2205
220508	220508	อ่างคีรี	Ang Khiri	22150	2025-12-18 04:35:40.495	2205
220601	220601	ปากน้ำแหลมสิงห์	Pak Nam Laem Sing	22130	2025-12-18 04:35:40.497	2206
220602	220602	เกาะเปริด	Ko Proet	22130	2025-12-18 04:35:40.5	2206
220603	220603	หนองชิ่ม	Nong Chim	22130	2025-12-18 04:35:40.502	2206
220604	220604	พลิ้ว	Phlio	22190	2025-12-18 04:35:40.504	2206
220605	220605	คลองน้ำเค็ม	Khlong Nam Khem	22190	2025-12-18 04:35:40.506	2206
220606	220606	บางสระเก้า	Bang Sa Kao	22190	2025-12-18 04:35:40.508	2206
220607	220607	บางกะไชย	Bang Kachai	22120	2025-12-18 04:35:40.511	2206
220701	220701	ปะตง	Patong	22180	2025-12-18 04:35:40.512	2207
220702	220702	ทุ่งขนาน	Thung Khanan	22180	2025-12-18 04:35:40.514	2207
220703	220703	ทับช้าง	Thap Chang	22180	2025-12-18 04:35:40.517	2207
220704	220704	ทรายขาว	Sai Khao	22180	2025-12-18 04:35:40.519	2207
220705	220705	สะตอน	Saton	22180	2025-12-18 04:35:40.521	2207
220801	220801	แก่งหางแมว	Kaeng Hang Maeo	22160	2025-12-18 04:35:40.525	2208
220802	220802	ขุนซ่อง	Khun Song	22160	2025-12-18 04:35:40.527	2208
220803	220803	สามพี่น้อง	Sam Phi Nong	22160	2025-12-18 04:35:40.529	2208
220804	220804	พวา	Phawa	22160	2025-12-18 04:35:40.531	2208
220805	220805	เขาวงกต	Khao Wongkot	22160	2025-12-18 04:35:40.532	2208
220901	220901	นายายอาม	Na Yai Am	22160	2025-12-18 04:35:40.534	2209
220902	220902	วังโตนด	Wang Tanot	22170	2025-12-18 04:35:40.536	2209
220903	220903	กระแจะ	Krachae	22170	2025-12-18 04:35:40.538	2209
220904	220904	สนามไชย	Sanam Chai	22170	2025-12-18 04:35:40.54	2209
220905	220905	ช้างข้าม	Chang Kham	22160	2025-12-18 04:35:40.541	2209
220906	220906	วังใหม่	Wang Mai	22170	2025-12-18 04:35:40.543	2209
160706	160706	หัวลำ	Hua Lam	15230	2025-12-18 04:35:39.72	1607
221001	221001	ชากไทย	Chak Thai	22210	2025-12-18 04:35:40.545	2210
221002	221002	พลวง	Phluang	22210	2025-12-18 04:35:40.546	2210
221003	221003	ตะเคียนทอง	Takhian Thong	22210	2025-12-18 04:35:40.548	2210
221004	221004	คลองพลู	Khlong Phlu	22210	2025-12-18 04:35:40.55	2210
221005	221005	จันทเขลม	Chanthakhlem	22210	2025-12-18 04:35:40.553	2210
230101	230101	บางพระ	Bang Phra	23000	2025-12-18 04:35:40.555	2301
230102	230102	หนองเสม็ด	Nong Samet	23000	2025-12-18 04:35:40.557	2301
230103	230103	หนองโสน	Nong Sano	23000	2025-12-18 04:35:40.559	2301
230104	230104	หนองคันทรง	Nong Khan Song	23000	2025-12-18 04:35:40.562	2301
230105	230105	ห้วงน้ำขาว	Huang Nam Khao	23000	2025-12-18 04:35:40.563	2301
230106	230106	อ่าวใหญ่	Ao Yai	23000	2025-12-18 04:35:40.566	2301
230107	230107	วังกระแจะ	Wang Krachae	23000	2025-12-18 04:35:40.568	2301
230108	230108	ห้วยแร้ง	Huai Raeng	23000	2025-12-18 04:35:40.57	2301
230109	230109	เนินทราย	Noen Sai	23000	2025-12-18 04:35:40.572	2301
230110	230110	ท่าพริก	Tha Phrik	23000	2025-12-18 04:35:40.574	2301
230111	230111	ท่ากุ่ม	Tha Kum	23000	2025-12-18 04:35:40.575	2301
230112	230112	ตะกาง	Takang	23000	2025-12-18 04:35:40.577	2301
230113	230113	ชำราก	Chamrak	23000	2025-12-18 04:35:40.579	2301
230114	230114	แหลมกลัด	Laem Klat	23000	2025-12-18 04:35:40.58	2301
230201	230201	คลองใหญ่	Khlong Yai	23110	2025-12-18 04:35:40.582	2302
230202	230202	ไม้รูด	Mai Rut	23110	2025-12-18 04:35:40.584	2302
230203	230203	หาดเล็ก	Hat Lek	23110	2025-12-18 04:35:40.585	2302
230301	230301	เขาสมิง	Khao Saming	23130	2025-12-18 04:35:40.587	2303
230302	230302	แสนตุ้ง	Saen Tung	23150	2025-12-18 04:35:40.588	2303
230303	230303	วังตะเคียน	Wang Takhian	23130	2025-12-18 04:35:40.59	2303
230304	230304	ท่าโสม	Tha Som	23150	2025-12-18 04:35:40.592	2303
230305	230305	สะตอ	Sato	23150	2025-12-18 04:35:40.594	2303
230306	230306	ประณีต	Pranit	23150	2025-12-18 04:35:40.596	2303
230307	230307	เทพนิมิต	Thep Nimit	23150	2025-12-18 04:35:40.598	2303
230308	230308	ทุ่งนนทรี	Thung Nonsi	23130	2025-12-18 04:35:40.6	2303
230401	230401	บ่อพลอย	Bo Phloi	23140	2025-12-18 04:35:40.602	2304
230402	230402	ช้างทูน	Chang Thun	23140	2025-12-18 04:35:40.604	2304
230403	230403	ด่านชุมพล	Dan Chumphon	23140	2025-12-18 04:35:40.606	2304
230404	230404	หนองบอน	Nong Bon	23140	2025-12-18 04:35:40.608	2304
230405	230405	นนทรีย์	Nonsi	23140	2025-12-18 04:35:40.611	2304
230501	230501	แหลมงอบ	Laem Ngop	23120	2025-12-18 04:35:40.613	2305
230502	230502	น้ำเชี่ยว	Nam Chiao	23120	2025-12-18 04:35:40.617	2305
230503	230503	บางปิด	Bang Pit	23120	2025-12-18 04:35:40.619	2305
230507	230507	คลองใหญ่	Khlong Yai	23120	2025-12-18 04:35:40.621	2305
230601	230601	เกาะหมาก	Ko Mak	23000	2025-12-18 04:35:40.623	2306
230602	230602	เกาะกูด	Ko Kut	23000	2025-12-18 04:35:40.625	2306
230701	230701	เกาะช้าง	Ko Chang	23170	2025-12-18 04:35:40.627	2307
230702	230702	เกาะช้างใต้	Ko Chang Tai	23170	2025-12-18 04:35:40.63	2307
240101	240101	หน้าเมือง	Na Mueang	24000	2025-12-18 04:35:40.632	2401
240102	240102	ท่าไข่	Tha Khai	24000	2025-12-18 04:35:40.634	2401
240103	240103	บ้านใหม่	Ban Mai	24000	2025-12-18 04:35:40.636	2401
240104	240104	คลองนา	Khlong Na	24000	2025-12-18 04:35:40.638	2401
240105	240105	บางตีนเป็ด	Khlong Na	24000	2025-12-18 04:35:40.64	2401
240106	240106	บางไผ่	Bang Phai	24000	2025-12-18 04:35:40.642	2401
240107	240107	คลองจุกกระเฌอ	Khlong Chuk Krachoe	24000	2025-12-18 04:35:40.644	2401
240108	240108	บางแก้ว	Bang Kaeo	24000	2025-12-18 04:35:40.646	2401
240109	240109	บางขวัญ	Bang Khwan	24000	2025-12-18 04:35:40.648	2401
240110	240110	คลองนครเนื่องเขต	Khlong Nakhon Nueang Khet	24000	2025-12-18 04:35:40.65	2401
240111	240111	วังตะเคียน	Wang Takhian	24000	2025-12-18 04:35:40.652	2401
240112	240112	โสธร	Sothon	24000	2025-12-18 04:35:40.653	2401
240113	240113	บางพระ	Bang Phra	24000	2025-12-18 04:35:40.656	2401
240114	240114	บางกะไห	Bang Kahai	24000	2025-12-18 04:35:40.658	2401
240115	240115	หนามแดง	Nam Daeng	24000	2025-12-18 04:35:40.66	2401
240116	240116	คลองเปรง	Khlong Preng	24000	2025-12-18 04:35:40.662	2401
240117	240117	คลองอุดมชลจร	Khlong Udom Chonlachon	24000	2025-12-18 04:35:40.664	2401
240118	240118	คลองหลวงแพ่ง	Khlong Luang Phaeng	24000	2025-12-18 04:35:40.666	2401
240119	240119	บางเตย	Bang Toei	24000	2025-12-18 04:35:40.668	2401
240201	240201	บางคล้า	Bang Khla	24110	2025-12-18 04:35:40.67	2402
240204	240204	บางสวน	Bang Suan	24110	2025-12-18 04:35:40.672	2402
240208	240208	บางกระเจ็ด	Bang Krachet	24110	2025-12-18 04:35:40.674	2402
240209	240209	ปากน้ำ	Pak Nam	24110	2025-12-18 04:35:40.676	2402
240210	240210	ท่าทองหลาง	Tha Thonglang	24110	2025-12-18 04:35:40.679	2402
240211	240211	สาวชะโงก	Sao Cha-ngok	24110	2025-12-18 04:35:40.68	2402
240212	240212	เสม็ดเหนือ	Samet Nuea	24110	2025-12-18 04:35:40.683	2402
240213	240213	เสม็ดใต้	Samet Tai	24110	2025-12-18 04:35:40.685	2402
240214	240214	หัวไทร	Hua Sai	24110	2025-12-18 04:35:40.687	2402
240301	240301	บางน้ำเปรี้ยว	Bang Nam Priao	24150	2025-12-18 04:35:40.689	2403
240302	240302	บางขนาก	Bang Khanak	24150	2025-12-18 04:35:40.692	2403
240303	240303	สิงโตทอง	Singto Thong	24150	2025-12-18 04:35:40.694	2403
240304	240304	หมอนทอง	Mon Thong	24150	2025-12-18 04:35:40.696	2403
240305	240305	บึงน้ำรักษ์	Bueng Nam Rak	24170	2025-12-18 04:35:40.698	2403
240306	240306	ดอนเกาะกา	Don Ko Ka	24170	2025-12-18 04:35:40.699	2403
240307	240307	โยธะกา	Yothaka	24150	2025-12-18 04:35:40.701	2403
240308	240308	ดอนฉิมพลี	Don Chimphli	24170	2025-12-18 04:35:40.702	2403
101602	101602	วัดท่าพระ	Wat Tha Phra	10600	2025-12-18 04:35:38.625	1016
240309	240309	ศาลาแดง	Sala Daeng	24000	2025-12-18 04:35:40.704	2403
240310	240310	โพรงอากาศ	Phrong Akat	24150	2025-12-18 04:35:40.706	2403
240401	240401	บางปะกง	Bang Pakong	24130	2025-12-18 04:35:40.707	2404
240402	240402	ท่าสะอ้าน	Tha Sa-an	24130	2025-12-18 04:35:40.71	2404
240403	240403	บางวัว	Bang Wua	24180	2025-12-18 04:35:40.711	2404
240404	240404	บางสมัคร	Bang Samak	24180	2025-12-18 04:35:40.713	2404
240405	240405	บางผึ้ง	Bang Phueng	24130	2025-12-18 04:35:40.715	2404
240406	240406	บางเกลือ	Bang Kluea	24180	2025-12-18 04:35:40.717	2404
240407	240407	สองคลอง	Song Khlong	24130	2025-12-18 04:35:40.719	2404
240408	240408	หนองจอก	Nong Chok	24130	2025-12-18 04:35:40.722	2404
240409	240409	พิมพา	Phimpha	24130	2025-12-18 04:35:40.724	2404
240410	240410	ท่าข้าม	Tha Kham	24130	2025-12-18 04:35:40.726	2404
240411	240411	หอมศีล	Hom Sin	24180	2025-12-18 04:35:40.728	2404
240412	240412	เขาดิน	Khao Din	24130	2025-12-18 04:35:40.731	2404
240501	240501	บ้านโพธิ์	Ban Pho	24140	2025-12-18 04:35:40.732	2405
240502	240502	เกาะไร่	Ko Rai	24140	2025-12-18 04:35:40.734	2405
240503	240503	คลองขุด	Khlong Khut	24140	2025-12-18 04:35:40.737	2405
240504	240504	คลองบ้านโพธิ์	Khlong Ban Pho	24140	2025-12-18 04:35:40.738	2405
240505	240505	คลองประเวศ	Khlong Prawet	24140	2025-12-18 04:35:40.741	2405
240506	240506	ดอนทราย	Don Sai	24140	2025-12-18 04:35:40.743	2405
240507	240507	เทพราช	Theppharat	24140	2025-12-18 04:35:40.745	2405
240508	240508	ท่าพลับ	Tha Phlap	24140	2025-12-18 04:35:40.749	2405
240509	240509	หนองตีนนก	Nong Tin Nok	24140	2025-12-18 04:35:40.751	2405
240510	240510	หนองบัว	Nong Bua	24140	2025-12-18 04:35:40.754	2405
240511	240511	บางซ่อน	Bang Son	24140	2025-12-18 04:35:40.756	2405
240512	240512	บางกรูด	Bang Krut	24140	2025-12-18 04:35:40.758	2405
240513	240513	แหลมประดู่	Laem Pradu	24140	2025-12-18 04:35:40.761	2405
240514	240514	ลาดขวาง	Lat Khwang	24140	2025-12-18 04:35:40.763	2405
240515	240515	สนามจันทร์	Sanam Chan	24140	2025-12-18 04:35:40.765	2405
240516	240516	แสนภูดาษ	Saen Phu Dat	24140	2025-12-18 04:35:40.768	2405
240517	240517	สิบเอ็ดศอก	Sip Et Sok	24140	2025-12-18 04:35:40.77	2405
240601	240601	เกาะขนุน	Ko Khanun	24120	2025-12-18 04:35:40.772	2406
240602	240602	บ้านซ่อง	Ban Song	24120	2025-12-18 04:35:40.775	2406
240603	240603	พนมสารคาม	Phanom Sarakham	24120	2025-12-18 04:35:40.777	2406
240604	240604	เมืองเก่า	Mueang Kao	24120	2025-12-18 04:35:40.779	2406
240605	240605	หนองยาว	Nong Yao	24120	2025-12-18 04:35:40.782	2406
240606	240606	ท่าถ่าน	Tha Than	24120	2025-12-18 04:35:40.785	2406
240607	240607	หนองแหน	Nong Nae	24120	2025-12-18 04:35:40.787	2406
240608	240608	เขาหินซ้อน	Khao Hin Son	24120	2025-12-18 04:35:40.789	2406
240701	240701	บางคา	Bang Kha	24120	2025-12-18 04:35:40.792	2407
240702	240702	เมืองใหม่	Mueang Mai	24120	2025-12-18 04:35:40.794	2407
240703	240703	ดงน้อย	Dong Noi	24120	2025-12-18 04:35:40.797	2407
240801	240801	คู้ยายหมี	Khu Yai Mi	24160	2025-12-18 04:35:40.799	2408
240802	240802	ท่ากระดาน	Tha Kradan	24160	2025-12-18 04:35:40.802	2408
240803	240803	ทุ่งพระยา	Thung Phraya	24160	2025-12-18 04:35:40.804	2408
240805	240805	ลาดกระทิง	Lat Krathing	24160	2025-12-18 04:35:40.807	2408
240901	240901	แปลงยาว	Plaeng Yao	24190	2025-12-18 04:35:40.809	2409
240902	240902	วังเย็น	Wang Yen	24190	2025-12-18 04:35:40.812	2409
240903	240903	หัวสำโรง	Hua Samrong	24190	2025-12-18 04:35:40.814	2409
240904	240904	หนองไม้แก่น	Nong Mai Kaen	24190	2025-12-18 04:35:40.817	2409
241001	241001	ท่าตะเกียบ	Tha Takiap	24160	2025-12-18 04:35:40.819	2410
241002	241002	คลองตะเกรา	Khlong Takrao	24160	2025-12-18 04:35:40.822	2410
241101	241101	ก้อนแก้ว	Kon Kaeo	24000	2025-12-18 04:35:40.824	2411
241102	241102	คลองเขื่อน	Khlong Khuean	24000	2025-12-18 04:35:40.827	2411
241103	241103	บางเล่า	Bang Lao	24000	2025-12-18 04:35:40.829	2411
241104	241104	บางโรง	Bang Rong	24000	2025-12-18 04:35:40.831	2411
241105	241105	บางตลาด	Bang Talat	24110	2025-12-18 04:35:40.833	2411
250101	250101	หน้าเมือง	Na Mueang	25000	2025-12-18 04:35:40.836	2501
250102	250102	รอบเมือง	Na Mueang	25000	2025-12-18 04:35:40.838	2501
250103	250103	วัดโบสถ์	Wat Bot	25000	2025-12-18 04:35:40.84	2501
250104	250104	บางเดชะ	Bang Decha	25000	2025-12-18 04:35:40.843	2501
250105	250105	ท่างาม	Tha Ngam	25000	2025-12-18 04:35:40.845	2501
250106	250106	บางบริบูรณ์	Bang Boribun	25000	2025-12-18 04:35:40.849	2501
250107	250107	ดงพระราม	Dong Phra Ram	25000	2025-12-18 04:35:40.852	2501
250108	250108	บ้านพระ	Ban Phra	25230	2025-12-18 04:35:40.855	2501
250109	250109	โคกไม้ลาย	Khok Mai Lai	25230	2025-12-18 04:35:40.858	2501
250110	250110	ไม้เค็ด	Mai Khet	25230	2025-12-18 04:35:40.86	2501
250111	250111	ดงขี้เหล็ก	Dong Khilek	25000	2025-12-18 04:35:40.863	2501
250112	250112	เนินหอม	Noen Hom	25230	2025-12-18 04:35:40.866	2501
250113	250113	โนนห้อม	Non Hom	25000	2025-12-18 04:35:40.868	2501
250201	250201	กบินทร์	Kabin	25110	2025-12-18 04:35:40.87	2502
250202	250202	เมืองเก่า	Mueang Kao	25240	2025-12-18 04:35:40.873	2502
250203	250203	วังดาล	Wang Dan	25110	2025-12-18 04:35:40.875	2502
250204	250204	นนทรี	Nonsi	25110	2025-12-18 04:35:40.878	2502
250205	250205	ย่านรี	Yan Ri	25110	2025-12-18 04:35:40.88	2502
250206	250206	วังตะเคียน	Wang Takhian	25110	2025-12-18 04:35:40.883	2502
250207	250207	หาดนางแก้ว	Hat Nang Kaeo	25110	2025-12-18 04:35:40.885	2502
250208	250208	ลาดตะเคียน	Lat Takhian	25110	2025-12-18 04:35:40.888	2502
250209	250209	บ้านนา	Ban Na	25110	2025-12-18 04:35:40.891	2502
250210	250210	บ่อทอง	Bo Thong	25110	2025-12-18 04:35:40.893	2502
250211	250211	หนองกี่	Nong Ki	25110	2025-12-18 04:35:40.895	2502
250212	250212	นาแขม	Na Khaem	25110	2025-12-18 04:35:40.897	2502
250213	250213	เขาไม้แก้ว	Khao Mai Kaeo	25110	2025-12-18 04:35:40.9	2502
250214	250214	วังท่าช้าง	Wang Tha Chang	25110	2025-12-18 04:35:40.902	2502
250301	250301	นาดี	Na Di	25220	2025-12-18 04:35:40.904	2503
250302	250302	สำพันตา	Samphan Ta	25220	2025-12-18 04:35:40.905	2503
250303	250303	สะพานหิน	Saphan Hin	25220	2025-12-18 04:35:40.907	2503
250304	250304	ทุ่งโพธิ์	Thung Pho	25220	2025-12-18 04:35:40.909	2503
250305	250305	แก่งดินสอ	Kaeng Dinso	25220	2025-12-18 04:35:40.912	2503
250306	250306	บุพราหมณ์	Bu Phram	25220	2025-12-18 04:35:40.913	2503
250601	250601	บ้านสร้าง	Ban Sang	25150	2025-12-18 04:35:40.915	2506
250602	250602	บางกระเบา	Bang Krabao	25150	2025-12-18 04:35:40.917	2506
250603	250603	บางเตย	Bang Toei	25150	2025-12-18 04:35:40.919	2506
250604	250604	บางยาง	Bang Yang	25150	2025-12-18 04:35:40.92	2506
250605	250605	บางแตน	Bang Taen	25150	2025-12-18 04:35:40.922	2506
250606	250606	บางพลวง	Bang Phluang	25150	2025-12-18 04:35:40.923	2506
250607	250607	บางปลาร้า	Bang Pla Ra	25150	2025-12-18 04:35:40.925	2506
250608	250608	บางขาม	Bang Kham	25150	2025-12-18 04:35:40.927	2506
250609	250609	กระทุ่มแพ้ว	Krathum Phaeo	25150	2025-12-18 04:35:40.928	2506
250702	250702	เกาะลอย	Ko Loi	25130	2025-12-18 04:35:40.932	2507
250703	250703	บ้านหอย	Ban Hoi	25130	2025-12-18 04:35:40.934	2507
250704	250704	หนองแสง	Nong Saeng	25130	2025-12-18 04:35:40.936	2507
250705	250705	ดงบัง	Dong Bang	25130	2025-12-18 04:35:40.938	2507
250706	250706	คำโตนด	Kham Tanot	25130	2025-12-18 04:35:40.94	2507
250707	250707	บุฝ้าย	Bu Fai	25130	2025-12-18 04:35:40.942	2507
250708	250708	หนองแก้ว	Nong Kaeo	25130	2025-12-18 04:35:40.944	2507
250709	250709	โพธิ์งาม	Pho Ngam	25130	2025-12-18 04:35:40.946	2507
250801	250801	ศรีมหาโพธิ	Si Maha Phot	25140	2025-12-18 04:35:40.948	2508
250802	250802	สัมพันธ์	Samphan	25140	2025-12-18 04:35:40.951	2508
250803	250803	บ้านทาม	Ban Tham	25140	2025-12-18 04:35:40.953	2508
250804	250804	ท่าตูม	Tha Tum	25140	2025-12-18 04:35:40.955	2508
250805	250805	บางกุ้ง	Bang Kung	25140	2025-12-18 04:35:40.958	2508
250806	250806	ดงกระทงยาม	Dong Krathong Yam	25140	2025-12-18 04:35:40.96	2508
250807	250807	หนองโพรง	Nong Phrong	25140	2025-12-18 04:35:40.962	2508
250808	250808	หัวหว้า	Hua Wa	25140	2025-12-18 04:35:40.964	2508
250809	250809	หาดยาง	Hat Yang	25140	2025-12-18 04:35:40.966	2508
250810	250810	กรอกสมบูรณ์	Krok Sombun	25140	2025-12-18 04:35:40.968	2508
250901	250901	โคกปีบ	Khok Pip	25190	2025-12-18 04:35:40.971	2509
250902	250902	โคกไทย	Khok Thai	25190	2025-12-18 04:35:40.973	2509
250903	250903	คู้ลำพัน	Khu Lam Phan	25190	2025-12-18 04:35:40.975	2509
250904	250904	ไผ่ชะเลือด	Phai Cha Lueat	25190	2025-12-18 04:35:40.977	2509
260101	260101	นครนายก	Nakhon Nayok	26000	2025-12-18 04:35:40.979	2601
260102	260102	ท่าช้าง	Tha Chang	26000	2025-12-18 04:35:40.982	2601
260103	260103	บ้านใหญ่	Ban Yai	26000	2025-12-18 04:35:40.984	2601
260104	260104	วังกระโจม	Wang Krachom	26000	2025-12-18 04:35:40.986	2601
260105	260105	ท่าทราย	Tha Sai	26000	2025-12-18 04:35:40.99	2601
260106	260106	ดอนยอ	Don Yo	26000	2025-12-18 04:35:40.993	2601
260107	260107	ศรีจุฬา	Si Chula	26000	2025-12-18 04:35:40.996	2601
260108	260108	ดงละคร	Dong Lakhon	26000	2025-12-18 04:35:40.998	2601
260109	260109	ศรีนาวา	Si Nawa	26000	2025-12-18 04:35:41.001	2601
260110	260110	สาริกา	Sarika	26000	2025-12-18 04:35:41.004	2601
260111	260111	หินตั้ง	Hin Tang	26000	2025-12-18 04:35:41.008	2601
260112	260112	เขาพระ	Khao Phra	26000	2025-12-18 04:35:41.01	2601
260113	260113	พรหมณี	Phrommani	26000	2025-12-18 04:35:41.012	2601
260201	260201	เกาะหวาย	Ko Wai	26130	2025-12-18 04:35:41.014	2602
260202	260202	เกาะโพธิ์	Ko Pho	26130	2025-12-18 04:35:41.017	2602
260203	260203	ปากพลี	Pak Phli	26130	2025-12-18 04:35:41.019	2602
260204	260204	โคกกรวด	Khok Kruat	26130	2025-12-18 04:35:41.022	2602
260205	260205	ท่าเรือ	Tha Ruea	26130	2025-12-18 04:35:41.025	2602
260206	260206	หนองแสง	Nong Saeng	26130	2025-12-18 04:35:41.027	2602
260207	260207	นาหินลาด	Na Hin Lat	26130	2025-12-18 04:35:41.03	2602
260301	260301	บ้านนา	Ban Na	26110	2025-12-18 04:35:41.032	2603
260302	260302	บ้านพร้าว	Ban Phrao	26110	2025-12-18 04:35:41.034	2603
260303	260303	บ้านพริก	Ban Phrik	26110	2025-12-18 04:35:41.036	2603
260304	260304	อาษา	Asa	26110	2025-12-18 04:35:41.039	2603
260305	260305	ทองหลาง	Thonglang	26110	2025-12-18 04:35:41.041	2603
260306	260306	บางอ้อ	Bang O	26110	2025-12-18 04:35:41.044	2603
260307	260307	พิกุลออก	Phikun Ok	26110	2025-12-18 04:35:41.046	2603
260308	260308	ป่าขะ	Pa Kha	26110	2025-12-18 04:35:41.049	2603
260309	260309	เขาเพิ่ม	Khao Phoem	26110	2025-12-18 04:35:41.051	2603
260310	260310	ศรีกะอาง	Si Ka-ang	26110	2025-12-18 04:35:41.054	2603
260401	260401	พระอาจารย์	Phra Achan	26120	2025-12-18 04:35:41.056	2604
260402	260402	บึงศาล	Bueng San	26120	2025-12-18 04:35:41.059	2604
260403	260403	ศีรษะกระบือ	Sisa Krabue	26120	2025-12-18 04:35:41.062	2604
260404	260404	โพธิ์แทน	Pho Thaen	26120	2025-12-18 04:35:41.066	2604
260405	260405	บางสมบูรณ์	Bang Sombun	26120	2025-12-18 04:35:41.068	2604
260406	260406	ทรายมูล	Sai Mun	26120	2025-12-18 04:35:41.071	2604
260407	260407	บางปลากด	Bang Pla Kot	26120	2025-12-18 04:35:41.074	2604
260408	260408	บางลูกเสือ	Bang Luk Suea	26120	2025-12-18 04:35:41.077	2604
260409	260409	องครักษ์	Ongkharak	26120	2025-12-18 04:35:41.08	2604
260410	260410	ชุมพล	Chumphon	26120	2025-12-18 04:35:41.083	2604
260411	260411	คลองใหญ่	Khlong Yai	26120	2025-12-18 04:35:41.085	2604
270101	270101	สระแก้ว	Sa Kaeo	27000	2025-12-18 04:35:41.088	2701
270102	270102	บ้านแก้ง	Ban Kaeng	27000	2025-12-18 04:35:41.091	2701
270103	270103	ศาลาลำดวน	Sala Lamduan	27000	2025-12-18 04:35:41.094	2701
270104	270104	โคกปี่ฆ้อง	Khok Pi Khong	27000	2025-12-18 04:35:41.097	2701
270105	270105	ท่าแยก	Tha Yaek	27000	2025-12-18 04:35:41.1	2701
270106	270106	ท่าเกษม	Tha Kasem	27000	2025-12-18 04:35:41.102	2701
270108	270108	สระขวัญ	Sa Khwan	27000	2025-12-18 04:35:41.105	2701
270111	270111	หนองบอน	Nong Bon	27000	2025-12-18 04:35:41.108	2701
270201	270201	คลองหาด	Khlong Hat	27260	2025-12-18 04:35:41.111	2702
270202	270202	ไทยอุดม	Thai Udom	27260	2025-12-18 04:35:41.113	2702
270203	270203	ซับมะกรูด	Sap Makrut	27260	2025-12-18 04:35:41.116	2702
270204	270204	ไทรเดี่ยว	Sai Diao	27260	2025-12-18 04:35:41.12	2702
270205	270205	คลองไก่เถื่อน	Khlong Kai Thuean	27260	2025-12-18 04:35:41.123	2702
270206	270206	เบญจขร	Benchakhon	27260	2025-12-18 04:35:41.126	2702
270207	270207	ไทรทอง	Sai Thong	27260	2025-12-18 04:35:41.129	2702
270301	270301	ตาพระยา	Ta Phraya	27180	2025-12-18 04:35:41.131	2703
270302	270302	ทัพเสด็จ	Thap Sadet	27180	2025-12-18 04:35:41.134	2703
270306	270306	ทัพราช	Thap Rat	27180	2025-12-18 04:35:41.137	2703
270307	270307	ทัพไทย	Thap Thai	27180	2025-12-18 04:35:41.14	2703
270309	270309	โคคลาน	Kho Khlan	27180	2025-12-18 04:35:41.146	2703
270401	270401	วังน้ำเย็น	Wang Nam Yen	27210	2025-12-18 04:35:41.151	2704
270403	270403	ตาหลังใน	Ta Lang Nai	27210	2025-12-18 04:35:41.158	2704
270405	270405	คลองหินปูน	Khlong Hin Pun	27210	2025-12-18 04:35:41.162	2704
270406	270406	ทุ่งมหาเจริญ	Thung Maha Charoen	27210	2025-12-18 04:35:41.164	2704
270501	270501	วัฒนานคร	Watthana Nakhon	27160	2025-12-18 04:35:41.166	2705
270502	270502	ท่าเกวียน	Tha Kwian	27160	2025-12-18 04:35:41.168	2705
270503	270503	ผักขะ	Phak Kha	27160	2025-12-18 04:35:41.17	2705
270504	270504	โนนหมากเค็ง	Non Mak Kheng	27160	2025-12-18 04:35:41.172	2705
270505	270505	หนองน้ำใส	Nong Nam Sai	27160	2025-12-18 04:35:41.174	2705
270506	270506	ช่องกุ่ม	Chong Kum	27160	2025-12-18 04:35:41.176	2705
270507	270507	หนองแวง	Nong Waeng	27160	2025-12-18 04:35:41.178	2705
270508	270508	แซร์ออ	Sae-o	27160	2025-12-18 04:35:41.18	2705
270509	270509	หนองหมากฝ้าย	Nong Mak Fai	27160	2025-12-18 04:35:41.182	2705
270510	270510	หนองตะเคียนบอน	Nong Takhian Bon	27160	2025-12-18 04:35:41.184	2705
270511	270511	ห้วยโจด	Huai Chot	27160	2025-12-18 04:35:41.186	2705
270601	270601	อรัญประเทศ	Aranprathet	27120	2025-12-18 04:35:41.188	2706
270602	270602	เมืองไผ่	Mueang Phai	27120	2025-12-18 04:35:41.19	2706
270603	270603	หันทราย	Han Sai	27120	2025-12-18 04:35:41.192	2706
270604	270604	คลองน้ำใส	Khlong Nam Sai	27120	2025-12-18 04:35:41.194	2706
270605	270605	ท่าข้าม	Tha Kham	27120	2025-12-18 04:35:41.196	2706
270606	270606	ป่าไร่	Pa Rai	27120	2025-12-18 04:35:41.198	2706
270607	270607	ทับพริก	Thap Phrik	27120	2025-12-18 04:35:41.2	2706
270608	270608	บ้านใหม่หนองไทร	Ban Mai Nong Sai	27120	2025-12-18 04:35:41.202	2706
270609	270609	ผ่านศึก	Phan Suek	27120	2025-12-18 04:35:41.204	2706
270610	270610	หนองสังข์	Nong Sang	27120	2025-12-18 04:35:41.206	2706
270611	270611	คลองทับจันทร์	Khlong Thap Chan	27120	2025-12-18 04:35:41.209	2706
270612	270612	ฟากห้วย	Fak Huai	27120	2025-12-18 04:35:41.211	2706
270613	270613	บ้านด่าน	Ban Dan	27120	2025-12-18 04:35:41.213	2706
270701	270701	เขาฉกรรจ์	Khao Chakan	27000	2025-12-18 04:35:41.215	2707
270702	270702	หนองหว้า	Nong Wa	27000	2025-12-18 04:35:41.217	2707
270703	270703	พระเพลิง	Phra Phloeng	27000	2025-12-18 04:35:41.219	2707
270704	270704	เขาสามสิบ	Khao Sam Sip	27000	2025-12-18 04:35:41.221	2707
270801	270801	โคกสูง	Khok Sung	27120	2025-12-18 04:35:41.223	2708
270802	270802	หนองม่วง	Nong Muang	27180	2025-12-18 04:35:41.225	2708
270803	270803	หนองแวง	Nong Waeng	27180	2025-12-18 04:35:41.227	2708
270804	270804	โนนหมากมุ่น	Non Mak Mun	27120	2025-12-18 04:35:41.229	2708
270901	270901	วังสมบูรณ์	Wang Sombun	27250	2025-12-18 04:35:41.231	2709
270902	270902	วังใหม่	Wang Mai	27250	2025-12-18 04:35:41.233	2709
270903	270903	วังทอง	Wang Thong	27250	2025-12-18 04:35:41.234	2709
300101	300101	ในเมือง	Nai Mueang	30000	2025-12-18 04:35:41.236	3001
300102	300102	โพธิ์กลาง	Pho Klang	30000	2025-12-18 04:35:41.238	3001
300103	300103	หนองจะบก	Nong Chabok	30000	2025-12-18 04:35:41.24	3001
300104	300104	โคกสูง	Khok Sung	30310	2025-12-18 04:35:41.241	3001
300105	300105	มะเริง	Maroeng	30000	2025-12-18 04:35:41.244	3001
300106	300106	หนองระเวียง	Nong Rawiang	30000	2025-12-18 04:35:41.247	3001
300107	300107	ปรุใหญ่	Pru Yai	30000	2025-12-18 04:35:41.249	3001
300108	300108	หมื่นไวย	Muen Wai	30000	2025-12-18 04:35:41.251	3001
300109	300109	พลกรัง	Phon Krang	30000	2025-12-18 04:35:41.254	3001
300110	300110	หนองไผ่ล้อม	Nong Phai Lom	30000	2025-12-18 04:35:41.256	3001
300111	300111	หัวทะเล	Hua Thale	30000	2025-12-18 04:35:41.257	3001
300112	300112	บ้านเกาะ	Ban Ko	30000	2025-12-18 04:35:41.259	3001
300113	300113	บ้านใหม่	Ban Mai	30000	2025-12-18 04:35:41.262	3001
300114	300114	พุดซา	Phutsa	30000	2025-12-18 04:35:41.264	3001
300115	300115	บ้านโพธิ์	Ban Pho	30310	2025-12-18 04:35:41.266	3001
300116	300116	จอหอ	Cho Ho	30310	2025-12-18 04:35:41.268	3001
300117	300117	โคกกรวด	Khok Kruat	30280	2025-12-18 04:35:41.27	3001
300118	300118	ไชยมงคล	Chai Mongkhon	30000	2025-12-18 04:35:41.272	3001
300119	300119	หนองบัวศาลา	Nong Bua Sala	30000	2025-12-18 04:35:41.274	3001
300120	300120	สุรนารี	Suranari	30000	2025-12-18 04:35:41.276	3001
300121	300121	สีมุม	Si Mum	30000	2025-12-18 04:35:41.278	3001
300122	300122	ตลาด	Talat	30310	2025-12-18 04:35:41.281	3001
300123	300123	พะเนา	Phanao	30000	2025-12-18 04:35:41.283	3001
300124	300124	หนองกระทุ่ม	Nong Krathum	30000	2025-12-18 04:35:41.285	3001
300125	300125	หนองไข่น้ำ	Nong Khai Nam	30310	2025-12-18 04:35:41.286	3001
300201	300201	แชะ	Chae	30250	2025-12-18 04:35:41.288	3002
300202	300202	เฉลียง	Chaliang	30250	2025-12-18 04:35:41.29	3002
300203	300203	ครบุรี	Khon Buri	30250	2025-12-18 04:35:41.292	3002
300204	300204	โคกกระชาย	Khok Krachai	30250	2025-12-18 04:35:41.294	3002
300205	300205	จระเข้หิน	Chorakhe Hin	30250	2025-12-18 04:35:41.296	3002
300206	300206	มาบตะโกเอน	Map Tako En	30250	2025-12-18 04:35:41.298	3002
300207	300207	อรพิมพ์	Oraphim	30250	2025-12-18 04:35:41.3	3002
300208	300208	บ้านใหม่	Ban Mai	30250	2025-12-18 04:35:41.301	3002
300209	300209	ลำเพียก	Lam Phiak	30250	2025-12-18 04:35:41.303	3002
300210	300210	ครบุรีใต้	Khon Buri Tai	30250	2025-12-18 04:35:41.305	3002
300211	300211	ตะแบกบาน	Tabaek Ban	30250	2025-12-18 04:35:41.307	3002
300212	300212	สระว่านพระยา	Sa Wan Phraya	30250	2025-12-18 04:35:41.309	3002
300301	300301	เสิงสาง	Soeng Sang	30330	2025-12-18 04:35:41.311	3003
300302	300302	สระตะเคียน	Sa Takhian	30330	2025-12-18 04:35:41.313	3003
300303	300303	โนนสมบูรณ์	Non Sombun	30330	2025-12-18 04:35:41.315	3003
300304	300304	กุดโบสถ์	Kut Bot	30330	2025-12-18 04:35:41.317	3003
300305	300305	สุขไพบูลย์	Suk Phaibun	30330	2025-12-18 04:35:41.319	3003
300306	300306	บ้านราษฎร์	Ban Rat	30330	2025-12-18 04:35:41.321	3003
300401	300401	เมืองคง	Mueang Khong	30260	2025-12-18 04:35:41.323	3004
300402	300402	คูขาด	Khu Khat	30260	2025-12-18 04:35:41.325	3004
300403	300403	เทพาลัย	Thephalai	30260	2025-12-18 04:35:41.327	3004
300404	300404	ตาจั่น	Ta Chan	30260	2025-12-18 04:35:41.329	3004
300405	300405	บ้านปรางค์	Ban Prang	30260	2025-12-18 04:35:41.33	3004
300406	300406	หนองมะนาว	Nong Manao	30260	2025-12-18 04:35:41.332	3004
300407	300407	หนองบัว	Nong Bua	30260	2025-12-18 04:35:41.334	3004
300408	300408	โนนเต็ง	Non Teng	30260	2025-12-18 04:35:41.336	3004
300409	300409	ดอนใหญ่	Don Yai	30260	2025-12-18 04:35:41.338	3004
300410	300410	ขามสมบูรณ์	Kham Sombun	30260	2025-12-18 04:35:41.34	3004
300501	300501	บ้านเหลื่อม	Ban Lueam	30350	2025-12-18 04:35:41.343	3005
300502	300502	วังโพธิ์	Wang Pho	30350	2025-12-18 04:35:41.345	3005
300503	300503	โคกกระเบื้อง	Khok Krabueang	30350	2025-12-18 04:35:41.347	3005
300504	300504	ช่อระกา	Cho Raka	30350	2025-12-18 04:35:41.349	3005
300601	300601	จักราช	Chakkarat	30230	2025-12-18 04:35:41.352	3006
300602	300602	ท่าช้าง	Tha Chang	30230	2025-12-18 04:35:41.359	3006
300603	300603	ทองหลาง	Thonglang	30230	2025-12-18 04:35:41.363	3006
300604	300604	สีสุก	Si Suk	30230	2025-12-18 04:35:41.366	3006
300605	300605	หนองขาม	Nong Kham	30230	2025-12-18 04:35:41.369	3006
300606	300606	หนองงูเหลือม	Nong Ngu Luam	30230	2025-12-18 04:35:41.372	3006
300607	300607	หนองพลวง	Nong Phluang	30230	2025-12-18 04:35:41.376	3006
300608	300608	หนองยาง	Nong Yang	30230	2025-12-18 04:35:41.38	3006
300610	300610	ศรีละกอ	Si Lako	30230	2025-12-18 04:35:41.386	3006
300611	300611	คลองเมือง	Khlong Mueang	30230	2025-12-18 04:35:41.388	3006
300612	300612	ช้างทอง	Chang Thong	30230	2025-12-18 04:35:41.39	3006
300613	300613	หินโคน	Hin Khon	30230	2025-12-18 04:35:41.393	3006
300701	300701	กระโทก	Krathok	30190	2025-12-18 04:35:41.396	3007
300702	300702	พลับพลา	Phlapphla	30190	2025-12-18 04:35:41.399	3007
300703	300703	ท่าอ่าง	Tha Ang	30190	2025-12-18 04:35:41.401	3007
300704	300704	ทุ่งอรุณ	Thung Arun	30190	2025-12-18 04:35:41.404	3007
300705	300705	ท่าลาดขาว	Tha Lat Khao	30190	2025-12-18 04:35:41.406	3007
300706	300706	ท่าจะหลุง	Tha Chalung	30190	2025-12-18 04:35:41.408	3007
300707	300707	ท่าเยี่ยม	Tha Yiam	30190	2025-12-18 04:35:41.41	3007
300708	300708	โชคชัย	Chok Chai	30190	2025-12-18 04:35:41.412	3007
300709	300709	ละลมใหม่พัฒนา	Lalom Mai Phatthana	30190	2025-12-18 04:35:41.415	3007
300710	300710	ด่านเกวียน	Dan Kwian	30190	2025-12-18 04:35:41.417	3007
300801	300801	กุดพิมาน	Kut Phiman	30210	2025-12-18 04:35:41.419	3008
300802	300802	ด่านขุนทด	Dan Khun Thot	30210	2025-12-18 04:35:41.421	3008
300803	300803	ด่านนอก	Dan Nok	30210	2025-12-18 04:35:41.423	3008
300804	300804	ด่านใน	Dan Nai	30210	2025-12-18 04:35:41.425	3008
300805	300805	ตะเคียน	Takhian	30210	2025-12-18 04:35:41.427	3008
300806	300806	บ้านเก่า	Ban Kao	30210	2025-12-18 04:35:41.429	3008
300807	300807	บ้านแปรง	Ban Praeng	36220	2025-12-18 04:35:41.431	3008
300808	300808	พันชนะ	Phan Chana	30210	2025-12-18 04:35:41.434	3008
300809	300809	สระจรเข้	Sa Chorakhe	30210	2025-12-18 04:35:41.436	3008
300810	300810	หนองกราด	Nong Krat	30210	2025-12-18 04:35:41.438	3008
300811	300811	หนองบัวตะเกียด	Nong Bua Takiat	30210	2025-12-18 04:35:41.44	3008
300812	300812	หนองบัวละคร	Nong Bua Lakhon	30210	2025-12-18 04:35:41.441	3008
300813	300813	หินดาด	Hin Dat	30210	2025-12-18 04:35:41.443	3008
300815	300815	ห้วยบง	Huai Bong	30210	2025-12-18 04:35:41.445	3008
300817	300817	โนนเมืองพัฒนา	Non Mueang Phatthana	30210	2025-12-18 04:35:41.447	3008
300818	300818	หนองไทร	Nong Sai	36220	2025-12-18 04:35:41.449	3008
300901	300901	โนนไทย	Non Thai	30220	2025-12-18 04:35:41.451	3009
300902	300902	ด่านจาก	Dan Chak	30220	2025-12-18 04:35:41.453	3009
300903	300903	กำปัง	Kampang	30220	2025-12-18 04:35:41.455	3009
300904	300904	สำโรง	Samrong	30220	2025-12-18 04:35:41.457	3009
300905	300905	ค้างพลู	Khang Phlu	30220	2025-12-18 04:35:41.46	3009
300906	300906	บ้านวัง	Ban Wang	30220	2025-12-18 04:35:41.462	3009
300907	300907	บัลลังก์	Banlang	30220	2025-12-18 04:35:41.464	3009
300908	300908	สายออ	Sai O	30220	2025-12-18 04:35:41.466	3009
300909	300909	ถนนโพธิ์	Thanon Pho	30220	2025-12-18 04:35:41.468	3009
300910	300910	พังเทียม	Phung Theam	30220	2025-12-18 04:35:41.47	3009
300911	300911	สระพระ	Sra Pra	30220	2025-12-18 04:35:41.472	3009
300912	300912	ทัพรั้ง	Tup Rang	30220	2025-12-18 04:35:41.474	3009
300913	300913	หนองหอย	Nong Hoi	30220	2025-12-18 04:35:41.477	3009
300914	300914	มะค่า	Makha	30220	2025-12-18 04:35:41.479	3009
300915	300915	มาบกราด	Mab Krad	30220	2025-12-18 04:35:41.481	3009
301001	301001	โนนสูง	Non Sung	30160	2025-12-18 04:35:41.483	3010
301002	301002	ใหม่	Mai	30160	2025-12-18 04:35:41.485	3010
301003	301003	โตนด	Tanot	30160	2025-12-18 04:35:41.488	3010
301004	301004	บิง	Bing	30160	2025-12-18 04:35:41.49	3010
301005	301005	ดอนชมพู	Don Chomphu	30160	2025-12-18 04:35:41.493	3010
301006	301006	ธารปราสาท	Than Prasat	30240	2025-12-18 04:35:41.495	3010
301007	301007	หลุมข้าว	Lum Khao	30160	2025-12-18 04:35:41.497	3010
301008	301008	มะค่า	Makha	30160	2025-12-18 04:35:41.5	3010
301009	301009	พลสงคราม	Phon Songkhram	30160	2025-12-18 04:35:41.502	3010
301010	301010	จันอัด	Chan-at	30160	2025-12-18 04:35:41.505	3010
301011	301011	ขามเฒ่า	Kham Thao	30160	2025-12-18 04:35:41.507	3010
301012	301012	ด่านคล้า	Dan Khla	30160	2025-12-18 04:35:41.509	3010
301013	301013	ลำคอหงษ์	Lam Kho Hong	30160	2025-12-18 04:35:41.511	3010
301014	301014	เมืองปราสาท	Mueang Prasat	30160	2025-12-18 04:35:41.513	3010
301015	301015	ดอนหวาย	Don Wai	30160	2025-12-18 04:35:41.516	3010
301016	301016	ลำมูล	Lam Mun	30160	2025-12-18 04:35:41.518	3010
301101	301101	ขามสะแกแสง	Kham Sakaesaeng	30290	2025-12-18 04:35:41.52	3011
301102	301102	โนนเมือง	Non Mueang	30290	2025-12-18 04:35:41.524	3011
301103	301103	เมืองนาท	Mueang Nat	30290	2025-12-18 04:35:41.526	3011
301104	301104	ชีวึก	Chiwuek	30290	2025-12-18 04:35:41.528	3011
301105	301105	พะงาด	Pha-ngat	30290	2025-12-18 04:35:41.53	3011
301106	301106	หนองหัวฟาน	Nong Hua Fan	30290	2025-12-18 04:35:41.532	3011
301107	301107	เมืองเกษตร	Mueang Kaset	30290	2025-12-18 04:35:41.534	3011
301201	301201	บัวใหญ่	Bua Yai	30120	2025-12-18 04:35:41.536	3012
301203	301203	ห้วยยาง	Huai Yang	30120	2025-12-18 04:35:41.538	3012
301204	301204	เสมาใหญ่	Sema Yai	30120	2025-12-18 04:35:41.541	3012
301206	301206	ดอนตะหนิน	Don Tanin	30120	2025-12-18 04:35:41.543	3012
301207	301207	หนองบัวสะอาด	Nong Bua Sa-at	30120	2025-12-18 04:35:41.546	3012
301208	301208	โนนทองหลาง	Non Thonglang	30120	2025-12-18 04:35:41.548	3012
301209	301209	หนองหว้า	Nong Wha	30120	2025-12-18 04:35:41.551	3012
301210	301210	บัวลาย	Bua Lai	30120	2025-12-18 04:35:41.553	3012
301212	301212	โพนทอง	Pon Thong	30120	2025-12-18 04:35:41.558	3012
301214	301214	กุดจอก	Kut Chok	30120	2025-12-18 04:35:41.56	3012
301215	301215	ด่านช้าง	Dan Chang	30120	2025-12-18 04:35:41.562	3012
301216	301216	โนนจาน	Non Jan	30120	2025-12-18 04:35:41.565	3012
301218	301218	สามเมือง	Sam Muang	30120	2025-12-18 04:35:41.567	3012
301220	301220	ขุนทอง	Khun Thong	30120	2025-12-18 04:35:41.569	3012
301221	301221	หนองตาดใหญ่	Nong Tad Yai	30120	2025-12-18 04:35:41.572	3012
301222	301222	เมืองพะไล	Mueang Pa Lai	30120	2025-12-18 04:35:41.574	3012
301223	301223	โนนประดู่	Non Pradoo	30120	2025-12-18 04:35:41.577	3012
301224	301224	หนองแจ้งใหญ่	Nong Chaeng Yai	30120	2025-12-18 04:35:41.579	3012
301301	301301	ประทาย	Prathai	30180	2025-12-18 04:35:41.581	3013
301303	301303	กระทุ่มราย	Krathum Rai	30180	2025-12-18 04:35:41.584	3013
301304	301304	วังไม้แดง	Wang Mai Daeng	30180	2025-12-18 04:35:41.586	3013
301306	301306	ตลาดไทร	Talat Sai	30180	2025-12-18 04:35:41.588	3013
301307	301307	หนองพลวง	Nong Phluang	30180	2025-12-18 04:35:41.591	3013
301308	301308	หนองค่าย	Nong Khai	30180	2025-12-18 04:35:41.593	3013
301309	301309	หันห้วยทราย	Han Huai Sai	30180	2025-12-18 04:35:41.595	3013
301310	301310	ดอนมัน	Don Man	30180	2025-12-18 04:35:41.598	3013
301313	301313	นางรำ	Nang Ram	30180	2025-12-18 04:35:41.6	3013
301314	301314	โนนเพ็ด	Non Phet	30180	2025-12-18 04:35:41.602	3013
301315	301315	ทุ่งสว่าง	Thung Sawang	30180	2025-12-18 04:35:41.605	3013
301317	301317	โคกกลาง	Khok Klang	30180	2025-12-18 04:35:41.607	3013
301318	301318	เมืองโดน	Mueang Don	30180	2025-12-18 04:35:41.61	3013
301401	301401	เมืองปัก	Mueang Pak	30150	2025-12-18 04:35:41.612	3014
301402	301402	ตะคุ	Takhu	30150	2025-12-18 04:35:41.615	3014
301403	301403	โคกไทย	Khok Thai	30150	2025-12-18 04:35:41.617	3014
301404	301404	สำโรง	Samrong	30150	2025-12-18 04:35:41.62	3014
301405	301405	ตะขบ	Takhop	30150	2025-12-18 04:35:41.622	3014
301406	301406	นกออก	Nok Ok	30150	2025-12-18 04:35:41.624	3014
301407	301407	ดอน	Don	30150	2025-12-18 04:35:41.627	3014
301409	301409	ตูม	Tum	30150	2025-12-18 04:35:41.629	3014
301410	301410	งิ้ว	Ngio	30150	2025-12-18 04:35:41.631	3014
301411	301411	สะแกราช	Sakae Rat	30150	2025-12-18 04:35:41.634	3014
301412	301412	ลำนางแก้ว	Lam Nang Kaeo	30150	2025-12-18 04:35:41.636	3014
301416	301416	ภูหลวง	Phu Luang	30150	2025-12-18 04:35:41.638	3014
301417	301417	ธงชัยเหนือ	Thong Chai Nuea	30150	2025-12-18 04:35:41.641	3014
301418	301418	สุขเกษม	Suk Kasem	30150	2025-12-18 04:35:41.643	3014
301419	301419	เกษมทรัพย์	Kasem Sap	30150	2025-12-18 04:35:41.646	3014
301420	301420	บ่อปลาทอง	Bo Pla Thong	30150	2025-12-18 04:35:41.648	3014
301501	301501	ในเมือง	Nai Mueang	30110	2025-12-18 04:35:41.651	3015
301502	301502	สัมฤทธิ์	Samrit	30110	2025-12-18 04:35:41.653	3015
301503	301503	โบสถ์	Bot	30110	2025-12-18 04:35:41.656	3015
301504	301504	กระเบื้องใหญ่	Krabueang Yai	30110	2025-12-18 04:35:41.659	3015
301505	301505	ท่าหลวง	Tha Luang	30110	2025-12-18 04:35:41.661	3015
301506	301506	รังกาใหญ่	Rang Ka Yai	30110	2025-12-18 04:35:41.664	3015
301507	301507	ชีวาน	Chiwan	30110	2025-12-18 04:35:41.666	3015
301508	301508	นิคมสร้างตนเอง	Nikhom Sang Ton-eng	30110	2025-12-18 04:35:41.668	3015
301509	301509	กระชอน	Krachon	30110	2025-12-18 04:35:41.671	3015
301510	301510	ดงใหญ่	Dong Yai	30110	2025-12-18 04:35:41.674	3015
301511	301511	ธารละหลอด	Than Lalot	30110	2025-12-18 04:35:41.676	3015
301512	301512	หนองระเวียง	Nong Rawiang	30110	2025-12-18 04:35:41.678	3015
301601	301601	ห้วยแถลง	Huai Thalaeng	30240	2025-12-18 04:35:41.681	3016
301602	301602	ทับสวาย	Thap Sawai	30240	2025-12-18 04:35:41.683	3016
301603	301603	เมืองพลับพลา	Mueang Phlapphla	30240	2025-12-18 04:35:41.686	3016
301604	301604	หลุ่งตะเคียน	Lung Takhian	30240	2025-12-18 04:35:41.689	3016
301605	301605	หินดาด	Hin Dat	30240	2025-12-18 04:35:41.691	3016
301606	301606	งิ้ว	Ngio	30240	2025-12-18 04:35:41.694	3016
301607	301607	กงรถ	Kong Rot	30240	2025-12-18 04:35:41.696	3016
301608	301608	หลุ่งประดู่	Lung Pradu	30240	2025-12-18 04:35:41.699	3016
301609	301609	ตะโก	Tako	30240	2025-12-18 04:35:41.702	3016
301610	301610	ห้วยแคน	Huai Khaen	30240	2025-12-18 04:35:41.704	3016
301701	301701	ชุมพวง	Chum Phuang	30270	2025-12-18 04:35:41.707	3017
301702	301702	ประสุข	Prasuk	30270	2025-12-18 04:35:41.709	3017
301703	301703	ท่าลาด	Tha Lat	30270	2025-12-18 04:35:41.712	3017
301704	301704	สาหร่าย	Sarai	30270	2025-12-18 04:35:41.714	3017
301705	301705	ตลาดไทร	Talat Sai	30270	2025-12-18 04:35:41.717	3017
301706	301706	ช่องแมว	Chong Maew	30270	2025-12-18 04:35:41.719	3017
301707	301707	ขุย	Kui	30270	2025-12-18 04:35:41.722	3017
301710	301710	โนนรัง	Non Rang	30270	2025-12-18 04:35:41.725	3017
301711	301711	บ้านยาง	Ban Yang	30270	2025-12-18 04:35:41.728	3017
301714	301714	หนองหลัก	Nong Lak	30270	2025-12-18 04:35:41.73	3017
301715	301715	ไพล	Plai	30270	2025-12-18 04:35:41.733	3017
301716	301716	โนนตูม	Non Tum	30270	2025-12-18 04:35:41.736	3017
301717	301717	โนนยอ	Non Yo	30270	2025-12-18 04:35:41.738	3017
301801	301801	สูงเนิน	Sung Noen	30170	2025-12-18 04:35:41.741	3018
301802	301802	เสมา	Sema	30170	2025-12-18 04:35:41.743	3018
301803	301803	โคราช	Khorat	30170	2025-12-18 04:35:41.745	3018
301804	301804	บุ่งขี้เหล็ก	Bung Khilek	30170	2025-12-18 04:35:41.748	3018
301805	301805	โนนค่า	Non Kha	30170	2025-12-18 04:35:41.75	3018
301806	301806	โค้งยาง	Khong Yang	30170	2025-12-18 04:35:41.753	3018
301807	301807	มะเกลือเก่า	Makluea Kao	30170	2025-12-18 04:35:41.755	3018
301808	301808	มะเกลือใหม่	Makluea Mai	30170	2025-12-18 04:35:41.758	3018
301809	301809	นากลาง	Na Klang	30380	2025-12-18 04:35:41.761	3018
301810	301810	หนองตะไก้	Nong Takai	30380	2025-12-18 04:35:41.764	3018
301811	301811	กุดจิก	Kut Chik	30380	2025-12-18 04:35:41.767	3018
301901	301901	ขามทะเลสอ	Kham Thale So	30280	2025-12-18 04:35:41.77	3019
301902	301902	โป่งแดง	Pong Daeng	30280	2025-12-18 04:35:41.773	3019
301903	301903	พันดุง	Phan Dung	30280	2025-12-18 04:35:41.776	3019
301904	301904	หนองสรวง	Nong Suang	30280	2025-12-18 04:35:41.779	3019
301905	301905	บึงอ้อ	Bueng O	30280	2025-12-18 04:35:41.781	3019
302001	302001	สีคิ้ว	Sikhio	30140	2025-12-18 04:35:41.785	3020
302002	302002	บ้านหัน	Ban Han	30140	2025-12-18 04:35:41.788	3020
302003	302003	กฤษณา	Kritsana	30140	2025-12-18 04:35:41.791	3020
302004	302004	ลาดบัวขาว	Lat Bua Khao	30340	2025-12-18 04:35:41.794	3020
302005	302005	หนองหญ้าขาว	Nong Ya Khao	30140	2025-12-18 04:35:41.796	3020
302006	302006	กุดน้อย	Kut Noi	30140	2025-12-18 04:35:41.799	3020
302007	302007	หนองน้ำใส	Nong Nam Sai	30140	2025-12-18 04:35:41.802	3020
302008	302008	วังโรงใหญ่	Wang Rong Yai	30140	2025-12-18 04:35:41.806	3020
302009	302009	มิตรภาพ	Mittraphap	30140	2025-12-18 04:35:41.809	3020
302010	302010	คลองไผ่	Khlong Phai	30340	2025-12-18 04:35:41.811	3020
302011	302011	ดอนเมือง	Don Mueang	30140	2025-12-18 04:35:41.814	3020
302012	302012	หนองบัวน้อย	Nong Bua Noi	30140	2025-12-18 04:35:41.817	3020
302101	302101	ปากช่อง	Pak Chong	30130	2025-12-18 04:35:41.82	3021
302102	302102	กลางดง	Klang Dong	30320	2025-12-18 04:35:41.823	3021
302103	302103	จันทึก	Chanthuek	30130	2025-12-18 04:35:41.826	3021
302104	302104	วังกะทะ	Wang Katha	30130	2025-12-18 04:35:41.829	3021
302105	302105	หมูสี	Mu Si	30130	2025-12-18 04:35:41.832	3021
302106	302106	หนองสาหร่าย	Nong Sarai	30130	2025-12-18 04:35:41.835	3021
302107	302107	ขนงพระ	Khanong Phra	30130	2025-12-18 04:35:41.84	3021
302108	302108	โป่งตาลอง	Pong Talong	30130	2025-12-18 04:35:41.842	3021
302109	302109	คลองม่วง	Khlong Muang	30130	2025-12-18 04:35:41.845	3021
302110	302110	หนองน้ำแดง	Nong Nam Daeng	30130	2025-12-18 04:35:41.847	3021
302111	302111	วังไทร	Wang Sai	30130	2025-12-18 04:35:41.849	3021
302112	302112	พญาเย็น	Phaya Yen	30320	2025-12-18 04:35:41.851	3021
302201	302201	หนองบุนนาก	Nong Bunnak	30410	2025-12-18 04:35:41.854	3022
302202	302202	สารภี	Saraphi	30410	2025-12-18 04:35:41.856	3022
302203	302203	ไทยเจริญ	Thai Charoen	30410	2025-12-18 04:35:41.858	3022
302204	302204	หนองหัวแรต	Nong Hua Raet	30410	2025-12-18 04:35:41.861	3022
302205	302205	แหลมทอง	Laem Thong	30410	2025-12-18 04:35:41.864	3022
302206	302206	หนองตะไก้	Nong Takai	30410	2025-12-18 04:35:41.867	3022
302207	302207	ลุงเขว้า	Lung Khwao	30410	2025-12-18 04:35:41.869	3022
302208	302208	หนองไม้ไผ่	Nong Mai Phai	30410	2025-12-18 04:35:41.872	3022
302209	302209	บ้านใหม่	Ban Mai	30410	2025-12-18 04:35:41.874	3022
302301	302301	แก้งสนามนาง	Kaeng Sanam Nang	30440	2025-12-18 04:35:41.877	3023
302302	302302	โนนสำราญ	Non Samran	30440	2025-12-18 04:35:41.88	3023
302303	302303	บึงพะไล	Bueng Phalai	30440	2025-12-18 04:35:41.883	3023
302304	302304	สีสุก	Si Suk	30440	2025-12-18 04:35:41.885	3023
302305	302305	บึงสำโรง	Bueng Samrong	30440	2025-12-18 04:35:41.887	3023
302401	302401	โนนแดง	Non Daeng	30360	2025-12-18 04:35:41.89	3024
302402	302402	โนนตาเถร	Non Ta Then	30360	2025-12-18 04:35:41.893	3024
302403	302403	สำพะเนียง	Samphaniang	30360	2025-12-18 04:35:41.895	3024
302404	302404	วังหิน	Wang Hin	30360	2025-12-18 04:35:41.898	3024
302405	302405	ดอนยาวใหญ่	Don Yao Yai	30360	2025-12-18 04:35:41.901	3024
302501	302501	วังน้ำเขียว	Wang Nam Khiao	30370	2025-12-18 04:35:41.903	3025
302502	302502	วังหมี	Wang Mi	30370	2025-12-18 04:35:41.907	3025
302503	302503	ระเริง	Raroeng	30150	2025-12-18 04:35:41.909	3025
302504	302504	อุดมทรัพย์	Udom Sap	30370	2025-12-18 04:35:41.912	3025
302505	302505	ไทยสามัคคี	Thai Samakkhi	30370	2025-12-18 04:35:41.915	3025
302601	302601	สำนักตะคร้อ	Samnak Takhro	30210	2025-12-18 04:35:41.918	3026
302602	302602	หนองแวง	Nong Waeng	30210	2025-12-18 04:35:41.92	3026
302603	302603	บึงปรือ	Bueng Prue	30210	2025-12-18 04:35:41.923	3026
302604	302604	วังยายทอง	Wang Yai Thong	30210	2025-12-18 04:35:41.926	3026
302701	302701	เมืองยาง	Mueang Yang	30270	2025-12-18 04:35:41.928	3027
302702	302702	กระเบื้องนอก	Krabueang Nok	30270	2025-12-18 04:35:41.931	3027
302703	302703	ละหานปลาค้าว	Lahan Pla Khao	30270	2025-12-18 04:35:41.934	3027
302704	302704	โนนอุดม	Non Udom	30270	2025-12-18 04:35:41.937	3027
302801	302801	สระพระ	Sa Phra	30220	2025-12-18 04:35:41.939	3028
302802	302802	มาบกราด	Map Krat	30220	2025-12-18 04:35:41.942	3028
302803	302803	พังเทียม	Phang Thiam	30220	2025-12-18 04:35:41.945	3028
302804	302804	ทัพรั้ง	Thap Rang	30220	2025-12-18 04:35:41.948	3028
302805	302805	หนองหอย	Nong Hoi	30220	2025-12-18 04:35:41.951	3028
302901	302901	ขุย	Khui	30270	2025-12-18 04:35:41.954	3029
302902	302902	บ้านยาง	Ban Yang	30270	2025-12-18 04:35:41.956	3029
302903	302903	ช่องแมว	Chong Maeo	30270	2025-12-18 04:35:41.958	3029
302904	302904	ไพล	Phlai	30270	2025-12-18 04:35:41.961	3029
303001	303001	เมืองพะไล	Mueang Phalai	30120	2025-12-18 04:35:41.964	3030
303002	303002	โนนจาน	Non Chan	30120	2025-12-18 04:35:41.967	3030
303003	303003	บัวลาย	Bua Lai	30120	2025-12-18 04:35:41.97	3030
303004	303004	หนองหว้า	Nong Wa	30120	2025-12-18 04:35:41.973	3030
303101	303101	สีดา	Sida	30430	2025-12-18 04:35:41.976	3031
303102	303102	โพนทอง	Phon Thong	30430	2025-12-18 04:35:41.979	3031
303103	303103	โนนประดู่	Non Pradu	30430	2025-12-18 04:35:41.982	3031
303104	303104	สามเมือง	Sam Mueang	30430	2025-12-18 04:35:41.985	3031
303105	303105	หนองตาดใหญ่	Nong Tat Yai	30430	2025-12-18 04:35:41.988	3031
303201	303201	ช้างทอง	Chang Thong	30230	2025-12-18 04:35:41.991	3032
303202	303202	ท่าช้าง	Tha Chang	30230	2025-12-18 04:35:41.994	3032
303203	303203	พระพุทธ	Phra Phut	30230	2025-12-18 04:35:41.997	3032
303204	303204	หนองงูเหลือม	Nong Ngu Lueam	30000	2025-12-18 04:35:42	3032
303205	303205	หนองยาง	Nong Yang	30230	2025-12-18 04:35:42.003	3032
310101	310101	ในเมือง	Nai Mueang	31000	2025-12-18 04:35:42.007	3101
310102	310102	อิสาณ	Isan	31000	2025-12-18 04:35:42.01	3101
310103	310103	เสม็ด	Samet	31000	2025-12-18 04:35:42.013	3101
310104	310104	บ้านบัว	Ban Bua	31000	2025-12-18 04:35:42.016	3101
310105	310105	สะแกโพรง	Sakae Phrong	31000	2025-12-18 04:35:42.019	3101
310106	310106	สวายจีก	Sawai Chik	31000	2025-12-18 04:35:42.022	3101
310108	310108	บ้านยาง	Ban Yang	31000	2025-12-18 04:35:42.025	3101
310112	310112	พระครู	Phra Khru	31000	2025-12-18 04:35:42.028	3101
310113	310113	ถลุงเหล็ก	Thalung Lek	31000	2025-12-18 04:35:42.032	3101
310114	310114	หนองตาด	Nong Tat	31000	2025-12-18 04:35:42.035	3101
310117	310117	ลุมปุ๊ก	Lumpuk	31000	2025-12-18 04:35:42.038	3101
310118	310118	สองห้อง	Song Hong	31000	2025-12-18 04:35:42.041	3101
310119	310119	บัวทอง	Bua Thong	31000	2025-12-18 04:35:42.044	3101
310120	310120	ชุมเห็ด	Chum Het	31000	2025-12-18 04:35:42.047	3101
310122	310122	หลักเขต	Lak Khet	31000	2025-12-18 04:35:42.051	3101
310125	310125	สะแกซำ	Sakae Sam	31000	2025-12-18 04:35:42.054	3101
310126	310126	กลันทา	Kalantha	31000	2025-12-18 04:35:42.058	3101
310127	310127	กระสัง	Krasang	31000	2025-12-18 04:35:42.06	3101
310128	310128	เมืองฝาง	Mueang Fang	31000	2025-12-18 04:35:42.063	3101
310201	310201	คูเมือง	Khu Mueang	31190	2025-12-18 04:35:42.066	3102
310202	310202	ปะเคียบ	Pakhiap	31190	2025-12-18 04:35:42.069	3102
310203	310203	บ้านแพ	Ban Phae	31190	2025-12-18 04:35:42.073	3102
310204	310204	พรสำราญ	Phon Samran	31190	2025-12-18 04:35:42.076	3102
310205	310205	หินเหล็กไฟ	Hin Lek Fai	31190	2025-12-18 04:35:42.079	3102
310206	310206	ตูมใหญ่	Tum Yai	31190	2025-12-18 04:35:42.082	3102
310207	310207	หนองขมาร	Nong Khaman	31190	2025-12-18 04:35:42.085	3102
310301	310301	กระสัง	Krasang	31160	2025-12-18 04:35:42.088	3103
310302	310302	ลำดวน	Lamduan	31160	2025-12-18 04:35:42.091	3103
310303	310303	สองชั้น	Song Chan	31160	2025-12-18 04:35:42.095	3103
310304	310304	สูงเนิน	Sung Noen	31160	2025-12-18 04:35:42.098	3103
310305	310305	หนองเต็ง	Nong Teng	31160	2025-12-18 04:35:42.101	3103
310306	310306	เมืองไผ่	Mueang Phai	31160	2025-12-18 04:35:42.104	3103
310307	310307	ชุมแสง	Chum Saeng	31160	2025-12-18 04:35:42.107	3103
310308	310308	บ้านปรือ	Ban Prue	31160	2025-12-18 04:35:42.11	3103
310309	310309	ห้วยสำราญ	Huai Samran	31160	2025-12-18 04:35:42.113	3103
310310	310310	กันทรารมย์	Kanthararom	31160	2025-12-18 04:35:42.116	3103
310311	310311	ศรีภูมิ	Si Phum	31160	2025-12-18 04:35:42.119	3103
310401	310401	นางรอง	Nang Rong	31110	2025-12-18 04:35:42.121	3104
310403	310403	สะเดา	Sadao	31110	2025-12-18 04:35:42.124	3104
310405	310405	ชุมแสง	Chum Saeng	31110	2025-12-18 04:35:42.127	3104
310406	310406	หนองโบสถ์	Nong Bot	31110	2025-12-18 04:35:42.13	3104
310408	310408	หนองกง	Nong Kong	31110	2025-12-18 04:35:42.133	3104
310413	310413	ถนนหัก	Thanon Hak	31110	2025-12-18 04:35:42.136	3104
310414	310414	หนองไทร	Nong Sai	31110	2025-12-18 04:35:42.139	3104
310415	310415	ก้านเหลือง	Kan Lueang	31110	2025-12-18 04:35:42.142	3104
310416	310416	บ้านสิงห์	Ban Sing	31110	2025-12-18 04:35:42.145	3104
310417	310417	ลำไทรโยง	Lam Sai Yong	31110	2025-12-18 04:35:42.147	3104
310418	310418	ทรัพย์พระยา	Sap Phraya	31110	2025-12-18 04:35:42.15	3104
310424	310424	หนองยายพิมพ์	Nong Yai Phim	31110	2025-12-18 04:35:42.153	3104
310425	310425	หัวถนน	Hua Thanon	31110	2025-12-18 04:35:42.156	3104
310426	310426	ทุ่งแสงทอง	Thung Saeng Thong	31110	2025-12-18 04:35:42.16	3104
310427	310427	หนองโสน	Nong Sano	31110	2025-12-18 04:35:42.163	3104
310501	310501	หนองกี่	Nong Ki	31210	2025-12-18 04:35:42.166	3105
310502	310502	เย้ยปราสาท	Yoei Prasat	31210	2025-12-18 04:35:42.169	3105
310503	310503	เมืองไผ่	Mueang Phai	31210	2025-12-18 04:35:42.172	3105
310504	310504	ดอนอะราง	Don Arang	31210	2025-12-18 04:35:42.175	3105
310505	310505	โคกสว่าง	Khok Sawang	31210	2025-12-18 04:35:42.178	3105
310506	310506	ทุ่งกระตาดพัฒนา	Thung Kratat Phatthana	31210	2025-12-18 04:35:42.18	3105
310507	310507	ทุ่งกระเต็น	Thung Kraten	31210	2025-12-18 04:35:42.185	3105
310508	310508	ท่าโพธิ์ชัย	Tha Pho Chai	31210	2025-12-18 04:35:42.188	3105
310509	310509	โคกสูง	Khok Sung	31210	2025-12-18 04:35:42.191	3105
310510	310510	บุกระสัง	Bu Krasang	31210	2025-12-18 04:35:42.194	3105
310601	310601	ละหานทราย	Lahan Sai	31170	2025-12-18 04:35:42.197	3106
310603	310603	ตาจง	Ta Chong	31170	2025-12-18 04:35:42.2	3106
310604	310604	สำโรงใหม่	Samrong Mai	31170	2025-12-18 04:35:42.203	3106
310607	310607	หนองแวง	Nong Waeng	31170	2025-12-18 04:35:42.207	3106
310610	310610	หนองตะครอง	Nong Trakhrong	31170	2025-12-18 04:35:42.209	3106
310611	310611	โคกว่าน	Khok Wan	31170	2025-12-18 04:35:42.212	3106
310701	310701	ประโคนชัย	Prakhon Chai	31140	2025-12-18 04:35:42.215	3107
310702	310702	แสลงโทน	Salaeng Thon	31140	2025-12-18 04:35:42.218	3107
310703	310703	บ้านไทร	Ban Sai	31140	2025-12-18 04:35:42.221	3107
310705	310705	ละเวี้ย	Lawia	31140	2025-12-18 04:35:42.224	3107
310706	310706	จรเข้มาก	Chorakhe Mak	31140	2025-12-18 04:35:42.227	3107
310707	310707	ปังกู	Pang Ku	31140	2025-12-18 04:35:42.231	3107
310708	310708	โคกย่าง	Khok Yang	31140	2025-12-18 04:35:42.234	3107
310710	310710	โคกม้า	Khok Ma	31140	2025-12-18 04:35:42.237	3107
310713	310713	ไพศาล	Phaisan	31140	2025-12-18 04:35:42.24	3107
310714	310714	ตะโกตาพิ	Tako Taphi	31140	2025-12-18 04:35:42.243	3107
310715	310715	เขาคอก	Khao Khok	31140	2025-12-18 04:35:42.246	3107
310716	310716	หนองบอน	Nong Bon	31140	2025-12-18 04:35:42.249	3107
310718	310718	โคกมะขาม	Khok Makham	31140	2025-12-18 04:35:42.251	3107
310719	310719	โคกตูม	Khok Tum	31140	2025-12-18 04:35:42.255	3107
310720	310720	ประทัดบุ	Prathat Bu	31140	2025-12-18 04:35:42.258	3107
310721	310721	สี่เหลี่ยม	Si Liam	31140	2025-12-18 04:35:42.261	3107
310801	310801	บ้านกรวด	Ban Kruat	31180	2025-12-18 04:35:42.265	3108
310802	310802	โนนเจริญ	Non Charoen	31180	2025-12-18 04:35:42.268	3108
310803	310803	หนองไม้งาม	Nong Mai Ngam	31180	2025-12-18 04:35:42.271	3108
310804	310804	ปราสาท	Prasat	31180	2025-12-18 04:35:42.274	3108
310805	310805	สายตะกู	Sai Taku	31180	2025-12-18 04:35:42.278	3108
310806	310806	หินลาด	Hin Lat	31180	2025-12-18 04:35:42.281	3108
310807	310807	บึงเจริญ	Bueng Charoen	31180	2025-12-18 04:35:42.284	3108
310808	310808	จันทบเพชร	Chanthop Phet	31180	2025-12-18 04:35:42.287	3108
310809	310809	เขาดินเหนือ	Khao Din Nuea	31180	2025-12-18 04:35:42.289	3108
310901	310901	พุทไธสง	Phutthaisong	31120	2025-12-18 04:35:42.293	3109
310902	310902	มะเฟือง	Mafueang	31120	2025-12-18 04:35:42.296	3109
310903	310903	บ้านจาน	Ban Chan	31120	2025-12-18 04:35:42.299	3109
310906	310906	บ้านเป้า	Ban Pao	31120	2025-12-18 04:35:42.302	3109
310907	310907	บ้านแวง	Ban Waeng	31120	2025-12-18 04:35:42.305	3109
310909	310909	บ้านยาง	Ban Yang	31120	2025-12-18 04:35:42.308	3109
310910	310910	หายโศก	Hai Sok	31120	2025-12-18 04:35:42.311	3109
311001	311001	ลำปลายมาศ	Lam Plai Mat	31130	2025-12-18 04:35:42.314	3110
311002	311002	หนองคู	Nong Khu	31130	2025-12-18 04:35:42.317	3110
311003	311003	แสลงพัน	Salaeng Phan	31130	2025-12-18 04:35:42.32	3110
311004	311004	ทะเมนชัย	Thamen Chai	31130	2025-12-18 04:35:42.323	3110
311005	311005	ตลาดโพธิ์	Talat Pho	31130	2025-12-18 04:35:42.326	3110
311006	311006	หนองกะทิง	Nong Kathing	31130	2025-12-18 04:35:42.329	3110
311007	311007	โคกกลาง	Khok Klang	31130	2025-12-18 04:35:42.333	3110
311008	311008	โคกสะอาด	Khok Sa-at	31130	2025-12-18 04:35:42.336	3110
311009	311009	เมืองแฝก	Mueang Faek	31130	2025-12-18 04:35:42.339	3110
311010	311010	บ้านยาง	Ban Yang	31130	2025-12-18 04:35:42.342	3110
311011	311011	ผไทรินทร์	Phathairin	31130	2025-12-18 04:35:42.345	3110
311012	311012	โคกล่าม	Khok Lam	31130	2025-12-18 04:35:42.348	3110
311013	311013	หินโคน	Hin Khon	31130	2025-12-18 04:35:42.351	3110
311014	311014	หนองบัวโคก	Nong Bua Khok	31130	2025-12-18 04:35:42.354	3110
311015	311015	บุโพธิ์	Bu Pho	31130	2025-12-18 04:35:42.357	3110
311016	311016	หนองโดน	Nong Don	31130	2025-12-18 04:35:42.36	3110
311101	311101	สตึก	Satuek	31150	2025-12-18 04:35:42.363	3111
311102	311102	นิคม	Nikhom	31150	2025-12-18 04:35:42.365	3111
311103	311103	ทุ่งวัง	Thung Wang	31150	2025-12-18 04:35:42.368	3111
311104	311104	เมืองแก	Mueang Kae	31150	2025-12-18 04:35:42.371	3111
311105	311105	หนองใหญ่	Nong Yai	31150	2025-12-18 04:35:42.374	3111
311106	311106	ร่อนทอง	Ron Thong	31150	2025-12-18 04:35:42.377	3111
311109	311109	ดอนมนต์	Don Mon	31150	2025-12-18 04:35:42.379	3111
311110	311110	ชุมแสง	Chum Saeng	31150	2025-12-18 04:35:42.382	3111
311111	311111	ท่าม่วง	Tha Muang	31150	2025-12-18 04:35:42.386	3111
311112	311112	สะแก	Sakae	31150	2025-12-18 04:35:42.39	3111
311114	311114	สนามชัย	Sanam Chai	31150	2025-12-18 04:35:42.393	3111
311115	311115	กระสัง	Krasang	31150	2025-12-18 04:35:42.398	3111
311201	311201	ปะคำ	Pakham	31220	2025-12-18 04:35:42.4	3112
311202	311202	ไทยเจริญ	Thai Charoen	31220	2025-12-18 04:35:42.402	3112
311203	311203	หนองบัว	Nong Bua	31220	2025-12-18 04:35:42.405	3112
311204	311204	โคกมะม่วง	Khok Mamuang	31220	2025-12-18 04:35:42.407	3112
311205	311205	หูทำนบ	Hu Thamnop	31220	2025-12-18 04:35:42.409	3112
311301	311301	นาโพธิ์	Na Pho	31230	2025-12-18 04:35:42.412	3113
311302	311302	บ้านคู	Ban Khu	31230	2025-12-18 04:35:42.414	3113
311303	311303	บ้านดู่	Ban Du	31230	2025-12-18 04:35:42.416	3113
311304	311304	ดอนกอก	Don Kok	31230	2025-12-18 04:35:42.418	3113
311305	311305	ศรีสว่าง	Si Sawang	31230	2025-12-18 04:35:42.42	3113
311401	311401	สระแก้ว	Sa Kaeo	31240	2025-12-18 04:35:42.422	3114
311402	311402	ห้วยหิน	Huai Hin	31240	2025-12-18 04:35:42.425	3114
311403	311403	ไทยสามัคคี	Thai Samakkhi	31240	2025-12-18 04:35:42.427	3114
311404	311404	หนองชัยศรี	Nong Chai Si	31240	2025-12-18 04:35:42.43	3114
311405	311405	เสาเดียว	Sao Diao	31240	2025-12-18 04:35:42.432	3114
311406	311406	เมืองฝ้าย	Mueang Fai	31240	2025-12-18 04:35:42.435	3114
311407	311407	สระทอง	Sa Thong	31240	2025-12-18 04:35:42.438	3114
311501	311501	จันดุม	Chan Dum	31250	2025-12-18 04:35:42.44	3115
311502	311502	โคกขมิ้น	Khok Khamin	31250	2025-12-18 04:35:42.445	3115
311503	311503	ป่าชัน	Pa Chan	31250	2025-12-18 04:35:42.448	3115
311504	311504	สะเดา	Sadao	31250	2025-12-18 04:35:42.451	3115
311505	311505	สำโรง	Samrong	31250	2025-12-18 04:35:42.453	3115
311601	311601	ห้วยราช	Huai Rat	31000	2025-12-18 04:35:42.455	3116
311602	311602	สามแวง	Sam Waeng	31000	2025-12-18 04:35:42.456	3116
311603	311603	ตาเสา	Ta Sao	31000	2025-12-18 04:35:42.458	3116
311604	311604	บ้านตะโก	Ban Tako	31000	2025-12-18 04:35:42.459	3116
311605	311605	สนวน	Sanuan	31000	2025-12-18 04:35:42.46	3116
311606	311606	โคกเหล็ก	Khok Lek	31000	2025-12-18 04:35:42.462	3116
311607	311607	เมืองโพธิ์	Mueang Pho	31000	2025-12-18 04:35:42.463	3116
311608	311608	ห้วยราชา	Huai Racha	31000	2025-12-18 04:35:42.464	3116
311701	311701	โนนสุวรรณ	Non Suwan	31110	2025-12-18 04:35:42.465	3117
311702	311702	ทุ่งจังหัน	Thung Changhan	31110	2025-12-18 04:35:42.467	3117
311703	311703	โกรกแก้ว	Krok Kaeo	31110	2025-12-18 04:35:42.468	3117
311704	311704	ดงอีจาน	Dong I Chan	31110	2025-12-18 04:35:42.469	3117
311801	311801	ชำนิ	Chamni	31110	2025-12-18 04:35:42.47	3118
311802	311802	หนองปล่อง	Nong Plong	31110	2025-12-18 04:35:42.471	3118
311803	311803	เมืองยาง	Mueang Yang	31110	2025-12-18 04:35:42.472	3118
311804	311804	ช่อผกา	Cho Phaka	31110	2025-12-18 04:35:42.473	3118
311805	311805	ละลวด	Laluat	31110	2025-12-18 04:35:42.474	3118
311806	311806	โคกสนวน	Khok Sanuan	31110	2025-12-18 04:35:42.475	3118
311901	311901	หนองแวง	Nong Waeng	31120	2025-12-18 04:35:42.476	3119
311902	311902	ทองหลาง	Thonglang	31120	2025-12-18 04:35:42.477	3119
311903	311903	แดงใหญ่	Daeng Yai	31120	2025-12-18 04:35:42.478	3119
311904	311904	กู่สวนแตง	Ku Suan Taeng	31120	2025-12-18 04:35:42.48	3119
311905	311905	หนองเยือง	Nong Yueang	31120	2025-12-18 04:35:42.481	3119
312001	312001	โนนดินแดง	Non Din Daeng	31260	2025-12-18 04:35:42.482	3120
312002	312002	ส้มป่อย	Som Poi	31260	2025-12-18 04:35:42.483	3120
312003	312003	ลำนางรอง	Lam Nang Rong	31260	2025-12-18 04:35:42.484	3120
312101	312101	บ้านด่าน	Ban Dan	31000	2025-12-18 04:35:42.485	3121
312102	312102	ปราสาท	Prasat	31000	2025-12-18 04:35:42.486	3121
312103	312103	วังเหนือ	Wang Nuea	31000	2025-12-18 04:35:42.487	3121
312104	312104	โนนขวาง	Non Khwang	31000	2025-12-18 04:35:42.488	3121
312201	312201	แคนดง	Khaen Dong	31150	2025-12-18 04:35:42.489	3122
312202	312202	ดงพลอง	Dong Phlong	31150	2025-12-18 04:35:42.49	3122
312203	312203	สระบัว	Sa Bua	31150	2025-12-18 04:35:42.491	3122
312204	312204	หัวฝาย	Hua Fai	31150	2025-12-18 04:35:42.492	3122
312301	312301	เจริญสุข	Charoen Suk	31110	2025-12-18 04:35:42.493	3123
312302	312302	ตาเป๊ก	Ta Pek	31110	2025-12-18 04:35:42.494	3123
312303	312303	อีสานเขต	Isan Khet	31110	2025-12-18 04:35:42.495	3123
312304	312304	ถาวร	Thawon	31170	2025-12-18 04:35:42.496	3123
312305	312305	ยายแย้มวัฒนา	Yai Yaem Watthana	31170	2025-12-18 04:35:42.497	3123
320101	320101	ในเมือง	Nai Mueang	32000	2025-12-18 04:35:42.498	3201
320102	320102	ตั้งใจ	Tang Chai	32000	2025-12-18 04:35:42.5	3201
320103	320103	เพี้ยราม	Phia Ram	32000	2025-12-18 04:35:42.501	3201
320104	320104	นาดี	Na Di	32000	2025-12-18 04:35:42.502	3201
320105	320105	ท่าสว่าง	Tha Sawang	32000	2025-12-18 04:35:42.503	3201
320106	320106	สลักได	Salakdai	32000	2025-12-18 04:35:42.504	3201
320107	320107	ตาอ็อง	Ta Ong	32000	2025-12-18 04:35:42.505	3201
320109	320109	สำโรง	Samrong	32000	2025-12-18 04:35:42.506	3201
320110	320110	แกใหญ่	Kae Yai	32000	2025-12-18 04:35:42.507	3201
320111	320111	นอกเมือง	Nok Mueang	32000	2025-12-18 04:35:42.508	3201
320112	320112	คอโค	Kho Kho	32000	2025-12-18 04:35:42.509	3201
320113	320113	สวาย	Sawai	32000	2025-12-18 04:35:42.51	3201
320114	320114	เฉนียง	Chaniang	32000	2025-12-18 04:35:42.511	3201
320116	320116	เทนมีย์	Thenmi	32000	2025-12-18 04:35:42.512	3201
320118	320118	นาบัว	Na Bua	32000	2025-12-18 04:35:42.513	3201
320119	320119	เมืองที	Mueang Thi	32000	2025-12-18 04:35:42.514	3201
320120	320120	ราม	Ram	32000	2025-12-18 04:35:42.515	3201
320121	320121	บุฤาษี	Bu Ruesi	32000	2025-12-18 04:35:42.517	3201
320122	320122	ตระแสง	Trasaeng	32000	2025-12-18 04:35:42.518	3201
320125	320125	แสลงพันธ์	Salaeng Phan	32000	2025-12-18 04:35:42.519	3201
101701	101701	ห้วยขวาง	Huai Khwang	10310	2025-12-18 04:35:38.627	1017
320126	320126	กาเกาะ	Ka Ko	32000	2025-12-18 04:35:42.52	3201
320201	320201	ชุมพลบุรี	Chumphon Buri	32190	2025-12-18 04:35:42.521	3202
320202	320202	นาหนองไผ่	Na Nong Phai	32190	2025-12-18 04:35:42.522	3202
320203	320203	ไพรขลา	Phrai Khla	32190	2025-12-18 04:35:42.523	3202
320204	320204	ศรีณรงค์	Si Narong	32190	2025-12-18 04:35:42.524	3202
320205	320205	ยะวึก	Yawuek	32190	2025-12-18 04:35:42.526	3202
320206	320206	เมืองบัว	Mueang Bua	32190	2025-12-18 04:35:42.527	3202
320207	320207	สระขุด	Sa Khut	32190	2025-12-18 04:35:42.529	3202
320208	320208	กระเบื้อง	Krabueang	32190	2025-12-18 04:35:42.532	3202
320209	320209	หนองเรือ	Nong Ruea	32190	2025-12-18 04:35:42.533	3202
320301	320301	ท่าตูม	Tha Tum	32120	2025-12-18 04:35:42.535	3203
320302	320302	กระโพ	Krapho	32120	2025-12-18 04:35:42.536	3203
320303	320303	พรมเทพ	Phrom Thep	32120	2025-12-18 04:35:42.537	3203
320304	320304	โพนครก	Phon Khrok	32120	2025-12-18 04:35:42.538	3203
320305	320305	เมืองแก	Mueang Kae	32120	2025-12-18 04:35:42.539	3203
320306	320306	บะ	Ba	32120	2025-12-18 04:35:42.54	3203
320307	320307	หนองบัว	Nong Bua	32120	2025-12-18 04:35:42.541	3203
320308	320308	บัวโคก	Bua Khok	32120	2025-12-18 04:35:42.542	3203
320309	320309	หนองเมธี	Nong Methi	32120	2025-12-18 04:35:42.543	3203
320310	320310	ทุ่งกุลา	Thung Kula	32120	2025-12-18 04:35:42.545	3203
320401	320401	จอมพระ	Chom Phra	32180	2025-12-18 04:35:42.546	3204
320402	320402	เมืองลีง	Mueang Ling	32180	2025-12-18 04:35:42.547	3204
320403	320403	กระหาด	Krahat	32180	2025-12-18 04:35:42.548	3204
320404	320404	บุแกรง	Bu Kraeng	32180	2025-12-18 04:35:42.55	3204
320405	320405	หนองสนิท	Nong Sanit	32180	2025-12-18 04:35:42.551	3204
320406	320406	บ้านผือ	Ban Phue	32180	2025-12-18 04:35:42.552	3204
320407	320407	ลุ่มระวี	Lum Rawi	32180	2025-12-18 04:35:42.553	3204
320408	320408	ชุมแสง	Chum Saeng	32180	2025-12-18 04:35:42.554	3204
320409	320409	เป็นสุข	Pen Suk	32180	2025-12-18 04:35:42.555	3204
320501	320501	กังแอน	Kang-aen	32140	2025-12-18 04:35:42.556	3205
320502	320502	ทมอ	Thamo	32140	2025-12-18 04:35:42.557	3205
320503	320503	ไพล	Phlai	32140	2025-12-18 04:35:42.558	3205
320504	320504	ปรือ	Prue	32140	2025-12-18 04:35:42.559	3205
320505	320505	ทุ่งมน	Thung Mon	32140	2025-12-18 04:35:42.56	3205
320506	320506	ตาเบา	Ta Bao	32140	2025-12-18 04:35:42.561	3205
320507	320507	หนองใหญ่	Nong Yai	32140	2025-12-18 04:35:42.562	3205
320508	320508	โคกยาง	Khok Yang	32140	2025-12-18 04:35:42.563	3205
320509	320509	โคกสะอาด	Khok Sa-at	32140	2025-12-18 04:35:42.564	3205
320510	320510	บ้านไทร	Ban Sai	32140	2025-12-18 04:35:42.565	3205
320511	320511	โชคนาสาม	Chok Na Sam	32140	2025-12-18 04:35:42.566	3205
320512	320512	เชื้อเพลิง	Chuea Phloeng	32140	2025-12-18 04:35:42.567	3205
320513	320513	ปราสาททนง	Prasat Thanong	32140	2025-12-18 04:35:42.568	3205
320514	320514	ตานี	Tani	32140	2025-12-18 04:35:42.569	3205
320515	320515	บ้านพลวง	Ban Phluang	32140	2025-12-18 04:35:42.57	3205
320516	320516	กันตวจระมวล	Kantuat Ramuan	32140	2025-12-18 04:35:42.571	3205
320517	320517	สมุด	Samut	32140	2025-12-18 04:35:42.572	3205
320518	320518	ประทัดบุ	Prathat Bu	32140	2025-12-18 04:35:42.574	3205
320601	320601	กาบเชิง	Kap Choeng	32210	2025-12-18 04:35:42.575	3206
320604	320604	คูตัน	Khu Tan	32210	2025-12-18 04:35:42.575	3206
320605	320605	ด่าน	Dan	32210	2025-12-18 04:35:42.576	3206
320606	320606	แนงมุด	Naeng Mut	32210	2025-12-18 04:35:42.577	3206
320607	320607	โคกตะเคียน	Khok Takhian	32210	2025-12-18 04:35:42.578	3206
320610	320610	ตะเคียน	Takhian	32210	2025-12-18 04:35:42.579	3206
320701	320701	รัตนบุรี	Rattanaburi	32130	2025-12-18 04:35:42.58	3207
320702	320702	ธาตุ	That	32130	2025-12-18 04:35:42.581	3207
320703	320703	แก	Kae	32130	2025-12-18 04:35:42.582	3207
320704	320704	ดอนแรด	Don Raet	32130	2025-12-18 04:35:42.583	3207
320705	320705	หนองบัวทอง	Nong Bua Thong	32130	2025-12-18 04:35:42.584	3207
320706	320706	หนองบัวบาน	Nong Bua Ban	32130	2025-12-18 04:35:42.585	3207
320709	320709	ไผ่	Phai	32130	2025-12-18 04:35:42.586	3207
320711	320711	เบิด	Boet	32130	2025-12-18 04:35:42.587	3207
320713	320713	น้ำเขียว	Nam Khiao	32130	2025-12-18 04:35:42.588	3207
320714	320714	กุดขาคีม	Kut Kha Khim	32130	2025-12-18 04:35:42.589	3207
320715	320715	ยางสว่าง	Yang Sawang	32130	2025-12-18 04:35:42.59	3207
320716	320716	ทับใหญ่	Thap Ya	32130	2025-12-18 04:35:42.591	3207
320801	320801	สนม	Sanom	32160	2025-12-18 04:35:42.592	3208
320802	320802	โพนโก	Phon Ko	32160	2025-12-18 04:35:42.593	3208
320803	320803	หนองระฆัง	Nong Rakhang	32160	2025-12-18 04:35:42.594	3208
320804	320804	นานวน	Na Nuan	32160	2025-12-18 04:35:42.595	3208
320805	320805	แคน	Khaen	32160	2025-12-18 04:35:42.596	3208
320806	320806	หัวงัว	Hua Ngua	32160	2025-12-18 04:35:42.597	3208
320807	320807	หนองอียอ	Nong I Yo	32160	2025-12-18 04:35:42.598	3208
320901	320901	ระแงง	Ra-ngaeng	32110	2025-12-18 04:35:42.599	3209
320902	320902	ตรึม	Truem	32110	2025-12-18 04:35:42.6	3209
320903	320903	จารพัต	Charaphat	32110	2025-12-18 04:35:42.601	3209
320905	320905	แตล	Taen	32110	2025-12-18 04:35:42.603	3209
320906	320906	หนองบัว	Nong Bua	32110	2025-12-18 04:35:42.604	3209
320907	320907	คาละแมะ	Khalamae	32110	2025-12-18 04:35:42.605	3209
320908	320908	หนองเหล็ก	Nong Lek	32110	2025-12-18 04:35:42.606	3209
320909	320909	หนองขวาว	Nong Khwao	32110	2025-12-18 04:35:42.607	3209
320910	320910	ช่างปี่	Chang Pi	32110	2025-12-18 04:35:42.608	3209
320911	320911	กุดหวาย	Kut Wai	32110	2025-12-18 04:35:42.609	3209
320912	320912	ขวาวใหญ่	Khwao Yai	32110	2025-12-18 04:35:42.61	3209
320913	320913	นารุ่ง	Na Rung	32110	2025-12-18 04:35:42.611	3209
320914	320914	ตรมไพร	Trom Phrai	32110	2025-12-18 04:35:42.612	3209
320915	320915	ผักไหม	Phak Mai	32110	2025-12-18 04:35:42.613	3209
321001	321001	สังขะ	Sangkha	32150	2025-12-18 04:35:42.614	3210
321002	321002	ขอนแตก	Khon Taek	32150	2025-12-18 04:35:42.615	3210
321006	321006	ดม	Dom	32150	2025-12-18 04:35:42.616	3210
321007	321007	พระแก้ว	Phra Kaeo	32150	2025-12-18 04:35:42.617	3210
321008	321008	บ้านจารย์	Ban Chan	32150	2025-12-18 04:35:42.618	3210
321009	321009	กระเทียม	Krathiam	32150	2025-12-18 04:35:42.619	3210
321010	321010	สะกาด	Sakat	32150	2025-12-18 04:35:42.62	3210
321011	321011	ตาตุม	Ta Tum	32150	2025-12-18 04:35:42.621	3210
321012	321012	ทับทัน	Thap Than	32150	2025-12-18 04:35:42.622	3210
321013	321013	ตาคง	Ta Khong	32150	2025-12-18 04:35:42.623	3210
321015	321015	บ้านชบ	Ban Chop	32150	2025-12-18 04:35:42.624	3210
321017	321017	เทพรักษา	Thep Raksa	32150	2025-12-18 04:35:42.625	3210
321101	321101	ลำดวน	Lamduan	32220	2025-12-18 04:35:42.626	3211
321102	321102	โชคเหนือ	Chok Nuea	32220	2025-12-18 04:35:42.627	3211
321103	321103	อู่โลก	U Lok	32220	2025-12-18 04:35:42.628	3211
321104	321104	ตรำดม	Tram Dom	32220	2025-12-18 04:35:42.63	3211
321105	321105	ตระเปียงเตีย	Trapiang Tia	32220	2025-12-18 04:35:42.632	3211
321201	321201	สำโรงทาบ	Samrong Thap	32170	2025-12-18 04:35:42.634	3212
321202	321202	หนองไผ่ล้อม	Nong Phai Lom	32170	2025-12-18 04:35:42.638	3212
321203	321203	กระออม	Kra-om	32170	2025-12-18 04:35:42.64	3212
321204	321204	หนองฮะ	Nong Ha	32170	2025-12-18 04:35:42.641	3212
321205	321205	ศรีสุข	Si Suk	32170	2025-12-18 04:35:42.643	3212
321206	321206	เกาะแก้ว	Ko Kaeo	32170	2025-12-18 04:35:42.645	3212
321207	321207	หมื่นศรี	Muen Si	32170	2025-12-18 04:35:42.647	3212
321208	321208	เสม็จ	Samet	32170	2025-12-18 04:35:42.648	3212
321209	321209	สะโน	Sano	32170	2025-12-18 04:35:42.649	3212
321210	321210	ประดู่	Pradu	32170	2025-12-18 04:35:42.65	3212
321301	321301	บัวเชด	Buachet	32230	2025-12-18 04:35:42.651	3213
321302	321302	สะเดา	Sadao	32230	2025-12-18 04:35:42.652	3213
321303	321303	จรัส	Charat	32230	2025-12-18 04:35:42.653	3213
321304	321304	ตาวัง	Ta Wang	32230	2025-12-18 04:35:42.654	3213
321305	321305	อาโพน	A Phon	32230	2025-12-18 04:35:42.655	3213
321306	321306	สำเภาลูน	Samphao Lun	32230	2025-12-18 04:35:42.656	3213
321401	321401	บักได	Bakdai	32140	2025-12-18 04:35:42.657	3214
321402	321402	โคกกลาง	Khok Klang	32140	2025-12-18 04:35:42.658	3214
321403	321403	จีกแดก	Chik Daek	32140	2025-12-18 04:35:42.659	3214
321404	321404	ตาเมียง	Ta Miang	32140	2025-12-18 04:35:42.66	3214
321501	321501	ณรงค์	Narong	32150	2025-12-18 04:35:42.661	3215
321502	321502	แจนแวน	Chaenwaen	32150	2025-12-18 04:35:42.662	3215
321503	321503	ตรวจ	Truat	32150	2025-12-18 04:35:42.668	3215
321504	321504	หนองแวง	Nong Waeng	32150	2025-12-18 04:35:42.67	3215
321505	321505	ศรีสุข	Si Suk	32150	2025-12-18 04:35:42.672	3215
321601	321601	เขวาสินรินทร์	Khwao Sinarin	32000	2025-12-18 04:35:42.673	3216
321602	321602	บึง	Bueng	32000	2025-12-18 04:35:42.674	3216
321603	321603	ตากูก	Ta Kuk	32000	2025-12-18 04:35:42.675	3216
321604	321604	ปราสาททอง	Prasat Thong	32000	2025-12-18 04:35:42.676	3216
321605	321605	บ้านแร่	Ban Rae	32000	2025-12-18 04:35:42.677	3216
321701	321701	หนองหลวง	Nong Luang	32130	2025-12-18 04:35:42.678	3217
321702	321702	คำผง	Kham Phong	32130	2025-12-18 04:35:42.679	3217
321704	321704	ระเวียง	Rawiang	32130	2025-12-18 04:35:42.681	3217
321705	321705	หนองเทพ	Nong Thep	32130	2025-12-18 04:35:42.682	3217
330101	330101	เมืองเหนือ	Mueang Nuea	33000	2025-12-18 04:35:42.683	3301
330102	330102	เมืองใต้	Mueang Tai	33000	2025-12-18 04:35:42.684	3301
330103	330103	คูซอด	Khu Sot	33000	2025-12-18 04:35:42.685	3301
330104	330104	ซำ	Sam	33000	2025-12-18 04:35:42.686	3301
330105	330105	จาน	Chan	33000	2025-12-18 04:35:42.687	3301
330106	330106	ตะดอบ	Tadop	33000	2025-12-18 04:35:42.688	3301
330107	330107	หนองครก	Nong Khrok	33000	2025-12-18 04:35:42.689	3301
330111	330111	โพนข่า	Phon Kha	33000	2025-12-18 04:35:42.69	3301
330112	330112	โพนค้อ	Phon Kho	33000	2025-12-18 04:35:42.691	3301
330115	330115	โพนเขวา	Phon Khwao	33000	2025-12-18 04:35:42.692	3301
330116	330116	หญ้าปล้อง	Ya Plong	33000	2025-12-18 04:35:42.693	3301
330118	330118	ทุ่ม	Thum	33000	2025-12-18 04:35:42.694	3301
330119	330119	หนองไฮ	Nong Hai	33000	2025-12-18 04:35:42.695	3301
330121	330121	หนองแก้ว	Nong Kaeo	33000	2025-12-18 04:35:42.696	3301
330122	330122	น้ำคำ	Nam Kham	33000	2025-12-18 04:35:42.697	3301
330123	330123	โพธิ์	Pho	33000	2025-12-18 04:35:42.698	3301
330124	330124	หมากเขียบ	Mak Khiap	33000	2025-12-18 04:35:42.699	3301
330127	330127	หนองไผ่	Nong Phai	33000	2025-12-18 04:35:42.7	3301
330201	330201	ยางชุมน้อย	Yang Chum Noi	33190	2025-12-18 04:35:42.702	3302
330202	330202	ลิ้นฟ้า	Lin Fa	33190	2025-12-18 04:35:42.703	3302
330203	330203	คอนกาม	Khon Kam	33190	2025-12-18 04:35:42.703	3302
330204	330204	โนนคูณ	Non Khun	33190	2025-12-18 04:35:42.705	3302
330205	330205	กุดเมืองฮาม	Kut Mueang Ham	33190	2025-12-18 04:35:42.706	3302
330206	330206	บึงบอน	Bueng Bon	33190	2025-12-18 04:35:42.707	3302
330207	330207	ยางชุมใหญ่	Yang Chum Yai	33190	2025-12-18 04:35:42.708	3302
330301	330301	ดูน	Dun	33130	2025-12-18 04:35:42.709	3303
330302	330302	โนนสัง	Non Sang	33130	2025-12-18 04:35:42.71	3303
330303	330303	หนองหัวช้าง	Nong Hua Chang	33130	2025-12-18 04:35:42.711	3303
330304	330304	ยาง	Yang	33130	2025-12-18 04:35:42.712	3303
330305	330305	หนองแวง	Nong Waeng	33130	2025-12-18 04:35:42.713	3303
330306	330306	หนองแก้ว	Nong Kaeo	33130	2025-12-18 04:35:42.714	3303
330307	330307	ทาม	Tham	33130	2025-12-18 04:35:42.715	3303
330308	330308	ละทาย	Lathai	33130	2025-12-18 04:35:42.716	3303
330309	330309	เมืองน้อย	Mueang Noi	33130	2025-12-18 04:35:42.717	3303
101702	101702	บางกะปิ	Bang Kapi	10310	2025-12-18 04:35:38.629	1017
330310	330310	อีปาด	I Pat	33130	2025-12-18 04:35:42.718	3303
330311	330311	บัวน้อย	Bua Noi	33130	2025-12-18 04:35:42.719	3303
330312	330312	หนองบัว	Nong Bua	33130	2025-12-18 04:35:42.72	3303
330313	330313	ดู่	Du	33130	2025-12-18 04:35:42.721	3303
330314	330314	ผักแพว	Phak Phaeo	33130	2025-12-18 04:35:42.722	3303
330315	330315	จาน	Chan	33130	2025-12-18 04:35:42.723	3303
330320	330320	คำเนียม	Kham Niam	33130	2025-12-18 04:35:42.724	3303
330401	330401	บึงมะลู	Bueng Malu	33110	2025-12-18 04:35:42.725	3304
330402	330402	กุดเสลา	Kut Salao	33110	2025-12-18 04:35:42.726	3304
330405	330405	สังเม็ก	Sang Mek	33110	2025-12-18 04:35:42.728	3304
330406	330406	น้ำอ้อม	Nam Om	33110	2025-12-18 04:35:42.729	3304
330407	330407	ละลาย	Lalai	33110	2025-12-18 04:35:42.73	3304
330408	330408	รุง	Rung	33110	2025-12-18 04:35:42.731	3304
330411	330411	จานใหญ่	Chan Yai	33110	2025-12-18 04:35:42.733	3304
330412	330412	ภูเงิน	Phu Ngoen	33110	2025-12-18 04:35:42.734	3304
330413	330413	ชำ	Cham	33110	2025-12-18 04:35:42.735	3304
330414	330414	กระแชง	Krachaeng	33110	2025-12-18 04:35:42.736	3304
330415	330415	โนนสำราญ	Non Samran	33110	2025-12-18 04:35:42.737	3304
330416	330416	หนองหญ้าลาด	Nong Ya Lat	33110	2025-12-18 04:35:42.738	3304
330419	330419	เสาธงชัย	Sao Thong Chai	33110	2025-12-18 04:35:42.739	3304
330420	330420	ขนุน	Khanun	33110	2025-12-18 04:35:42.74	3304
330421	330421	สวนกล้วย	Suan Kluai	33110	2025-12-18 04:35:42.741	3304
330423	330423	เวียงเหนือ	Wiang Nuea	33110	2025-12-18 04:35:42.742	3304
330424	330424	ทุ่งใหญ่	Thung Yai	33110	2025-12-18 04:35:42.743	3304
330425	330425	ภูผาหมอก	Phu Pha Mok	33110	2025-12-18 04:35:42.744	3304
330501	330501	กันทรารมย์	Kanthararom	33140	2025-12-18 04:35:42.745	3305
330502	330502	จะกง	Chakong	33140	2025-12-18 04:35:42.746	3305
330503	330503	ใจดี	Chai Di	33140	2025-12-18 04:35:42.747	3305
330504	330504	ดองกำเม็ด	Dong Kammet	33140	2025-12-18 04:35:42.748	3305
330505	330505	โสน	Sano	33140	2025-12-18 04:35:42.749	3305
330506	330506	ปรือใหญ่	Prue Yai	33140	2025-12-18 04:35:42.75	3305
330507	330507	สะเดาใหญ่	Sadao Yai	33140	2025-12-18 04:35:42.751	3305
330508	330508	ตาอุด	Ta Ut	33140	2025-12-18 04:35:42.752	3305
330509	330509	ห้วยเหนือ	Huai Nuea	33140	2025-12-18 04:35:42.752	3305
330510	330510	ห้วยใต้	Huai Tai	33140	2025-12-18 04:35:42.754	3305
330511	330511	หัวเสือ	Hua Suea	33140	2025-12-18 04:35:42.755	3305
330513	330513	ตะเคียน	Takhian	33140	2025-12-18 04:35:42.756	3305
330515	330515	นิคมพัฒนา	Nikhom Phatthana	33140	2025-12-18 04:35:42.757	3305
330517	330517	โคกเพชร	Khok Phet	33140	2025-12-18 04:35:42.758	3305
330518	330518	ปราสาท	Prasat	33140	2025-12-18 04:35:42.759	3305
330521	330521	สำโรงตาเจ็น	Samrong Ta Chen	33140	2025-12-18 04:35:42.76	3305
330522	330522	ห้วยสำราญ	Huai Samran	33140	2025-12-18 04:35:42.761	3305
330524	330524	กฤษณา	Kritsana	33140	2025-12-18 04:35:42.762	3305
330525	330525	ลมศักดิ์	Lom Sak	33140	2025-12-18 04:35:42.763	3305
330526	330526	หนองฉลอง	Nong Chalong	33140	2025-12-18 04:35:42.764	3305
330527	330527	ศรีตระกูล	Si Trakun	33140	2025-12-18 04:35:42.765	3305
330528	330528	ศรีสะอาด	Si Sa-at	33140	2025-12-18 04:35:42.765	3305
330601	330601	ไพรบึง	Phrai Bueng	33180	2025-12-18 04:35:42.766	3306
330602	330602	ดินแดง	Din Daeng	33180	2025-12-18 04:35:42.767	3306
330603	330603	ปราสาทเยอ	Prasat Yoe	33180	2025-12-18 04:35:42.768	3306
330604	330604	สำโรงพลัน	Samrong Phlan	33180	2025-12-18 04:35:42.769	3306
330605	330605	สุขสวัสดิ์	Suk Sawat	33180	2025-12-18 04:35:42.77	3306
330606	330606	โนนปูน	Non Pun	33180	2025-12-18 04:35:42.771	3306
330701	330701	พิมาย	Phimai	33170	2025-12-18 04:35:42.772	3307
330702	330702	กู่	Ku	33170	2025-12-18 04:35:42.773	3307
330703	330703	หนองเชียงทูน	Nong Chiang Thun	33170	2025-12-18 04:35:42.774	3307
330704	330704	ตูม	Tum	33170	2025-12-18 04:35:42.775	3307
330705	330705	สมอ	Samo	33170	2025-12-18 04:35:42.776	3307
330706	330706	โพธิ์ศรี	Pho Si	33170	2025-12-18 04:35:42.777	3307
330707	330707	สำโรงปราสาท	Samrong Prasat	33170	2025-12-18 04:35:42.778	3307
330708	330708	ดู่	Du	33170	2025-12-18 04:35:42.781	3307
330709	330709	สวาย	Sawai	33170	2025-12-18 04:35:42.784	3307
330710	330710	พิมายเหนือ	Phimai Nuea	33170	2025-12-18 04:35:42.787	3307
330801	330801	สิ	Si	33150	2025-12-18 04:35:42.789	3308
330802	330802	บักดอง	Bak Dong	33150	2025-12-18 04:35:42.791	3308
330803	330803	พราน	Phran	33150	2025-12-18 04:35:42.792	3308
330804	330804	โพธิ์วงศ์	Pho Wong	33150	2025-12-18 04:35:42.793	3308
330805	330805	ไพร	Phrai	33150	2025-12-18 04:35:42.794	3308
330806	330806	กระหวัน	Krawan	33150	2025-12-18 04:35:42.795	3308
330807	330807	ขุนหาญ	Khun Han	33150	2025-12-18 04:35:42.796	3308
330808	330808	โนนสูง	Non Sung	33150	2025-12-18 04:35:42.797	3308
330809	330809	กันทรอม	Kanthrom	33150	2025-12-18 04:35:42.798	3308
330810	330810	ภูฝ้าย	Phu Fai	33150	2025-12-18 04:35:42.799	3308
330811	330811	โพธิ์กระสังข์	Pho Krasang	33150	2025-12-18 04:35:42.8	3308
330812	330812	ห้วยจันทร์	Huai Chan	33150	2025-12-18 04:35:42.801	3308
330901	330901	เมืองคง	Mueang Khong	33160	2025-12-18 04:35:42.802	3309
330902	330902	เมืองแคน	Muang Khaen	33160	2025-12-18 04:35:42.803	3309
330903	330903	หนองแค	Nong Khae	33160	2025-12-18 04:35:42.804	3309
330906	330906	จิกสังข์ทอง	Chik Sang Thong	33160	2025-12-18 04:35:42.805	3309
330908	330908	ดู่	Du	33160	2025-12-18 04:35:42.807	3309
330909	330909	หนองอึ่ง	Nong Ueng	33160	2025-12-18 04:35:42.808	3309
330910	330910	บัวหุ่ง	Bua Hung	33160	2025-12-18 04:35:42.809	3309
330911	330911	ไผ่	Phai	33160	2025-12-18 04:35:42.81	3309
330912	330912	ส้มป่อย	Som Poi	33160	2025-12-18 04:35:42.811	3309
330913	330913	หนองหมี	Nong Mi	33160	2025-12-18 04:35:42.812	3309
330914	330914	หว้านคำ	Wan Kham	33160	2025-12-18 04:35:42.813	3309
330915	330915	สร้างปี่	Sang Pi	33160	2025-12-18 04:35:42.814	3309
331001	331001	กำแพง	Kamphaeng	33120	2025-12-18 04:35:42.815	3310
331002	331002	อี่หล่ำ	I Lam	33120	2025-12-18 04:35:42.815	3310
331003	331003	ก้านเหลือง	Kan Lueang	33120	2025-12-18 04:35:42.816	3310
331004	331004	ทุ่งไชย	Thung Chai	33120	2025-12-18 04:35:42.817	3310
331005	331005	สำโรง	Samrong	33120	2025-12-18 04:35:42.818	3310
331006	331006	แขม	Khaem	33120	2025-12-18 04:35:42.819	3310
331007	331007	หนองไฮ	Nong Hai	33120	2025-12-18 04:35:42.82	3310
331008	331008	ขะยูง	Khayung	33120	2025-12-18 04:35:42.821	3310
331010	331010	ตาเกษ	Ta Ket	33120	2025-12-18 04:35:42.822	3310
331011	331011	หัวช้าง	Hua Chang	33120	2025-12-18 04:35:42.823	3310
331012	331012	รังแร้ง	Rang Raeng	33120	2025-12-18 04:35:42.824	3310
331014	331014	แต้	Tae	33120	2025-12-18 04:35:42.825	3310
331015	331015	แข้	Khae	33120	2025-12-18 04:35:42.826	3310
331016	331016	โพธิ์ชัย	Pho Chai	33120	2025-12-18 04:35:42.827	3310
331017	331017	ปะอาว	Pa Ao	33120	2025-12-18 04:35:42.828	3310
331018	331018	หนองห้าง	Nong Hang	33120	2025-12-18 04:35:42.828	3310
331022	331022	สระกำแพงใหญ่	Sa Kamphaeng Yai	33120	2025-12-18 04:35:42.829	3310
331024	331024	โคกหล่าม	Khok Lam	33120	2025-12-18 04:35:42.83	3310
331025	331025	โคกจาน	Khok Chan	33120	2025-12-18 04:35:42.831	3310
331101	331101	เป๊าะ	Po	33220	2025-12-18 04:35:42.832	3311
331102	331102	บึงบูรพ์	Bueng Bun	33220	2025-12-18 04:35:42.833	3311
331201	331201	ห้วยทับทัน	Huai Thap Than	33210	2025-12-18 04:35:42.834	3312
331202	331202	เมืองหลวง	Mueang Luang	33210	2025-12-18 04:35:42.835	3312
331203	331203	กล้วยกว้าง	Kluai Kwang	33210	2025-12-18 04:35:42.836	3312
331204	331204	ผักไหม	Phak Mai	33210	2025-12-18 04:35:42.837	3312
331205	331205	จานแสนไชย	Chan Saen Chai	33210	2025-12-18 04:35:42.838	3312
331206	331206	ปราสาท	Prasat	33210	2025-12-18 04:35:42.839	3312
331301	331301	โนนค้อ	Non Kho	33250	2025-12-18 04:35:42.84	3313
331303	331303	โพธิ์	Pho	33250	2025-12-18 04:35:42.842	3313
331304	331304	หนองกุง	Nong Kung	33250	2025-12-18 04:35:42.843	3313
331305	331305	เหล่ากวาง	Lao Kwang	33250	2025-12-18 04:35:42.843	3313
331401	331401	ศรีแก้ว	Si Kaeo	33240	2025-12-18 04:35:42.844	3314
331402	331402	พิงพวย	Phing Phuai	33240	2025-12-18 04:35:42.845	3314
331403	331403	สระเยาว์	Sa Yao	33240	2025-12-18 04:35:42.846	3314
331404	331404	ตูม	Tum	33240	2025-12-18 04:35:42.847	3314
331405	331405	เสื่องข้าว	Sueang Khao	33240	2025-12-18 04:35:42.848	3314
331406	331406	ศรีโนนงาม	Si Non Ngam	33240	2025-12-18 04:35:42.849	3314
331407	331407	สะพุง	Saphung	33240	2025-12-18 04:35:42.85	3314
331501	331501	น้ำเกลี้ยง	Nam Kliang	33130	2025-12-18 04:35:42.851	3315
331502	331502	ละเอาะ	La-o	33130	2025-12-18 04:35:42.852	3315
331503	331503	ตองปิด	Tong Pit	33130	2025-12-18 04:35:42.853	3315
331504	331504	เขิน	Khoen	33130	2025-12-18 04:35:42.854	3315
331505	331505	รุ่งระวี	Rung Rawi	33130	2025-12-18 04:35:42.855	3315
331506	331506	คูบ	Khup	33130	2025-12-18 04:35:42.855	3315
331601	331601	บุสูง	Bu Sung	33270	2025-12-18 04:35:42.856	3316
331602	331602	ธาตุ	That	33270	2025-12-18 04:35:42.857	3316
331603	331603	ดวนใหญ่	Duan Yai	33270	2025-12-18 04:35:42.858	3316
331604	331604	บ่อแก้ว	Bo Kaeo	33270	2025-12-18 04:35:42.859	3316
331605	331605	ศรีสำราญ	Si Samran	33270	2025-12-18 04:35:42.86	3316
331606	331606	ทุ่งสว่าง	Thung Sawang	33270	2025-12-18 04:35:42.861	3316
331607	331607	วังหิน	Wang Hin	33270	2025-12-18 04:35:42.862	3316
331608	331608	โพนยาง	Phon Yang	33270	2025-12-18 04:35:42.863	3316
331701	331701	โคกตาล	Khok Tan	33140	2025-12-18 04:35:42.864	3317
331702	331702	ห้วยตามอญ	Huai Ta Mon	33140	2025-12-18 04:35:42.865	3317
331703	331703	ห้วยตึ๊กชู	Huai Tuekchu	33140	2025-12-18 04:35:42.866	3317
331704	331704	ละลม	Lalom	33140	2025-12-18 04:35:42.867	3317
331705	331705	ตะเคียนราม	Takhian Ram	33140	2025-12-18 04:35:42.868	3317
331706	331706	ดงรัก	Dong Rak	33140	2025-12-18 04:35:42.869	3317
331707	331707	ไพรพัฒนา	Phrai Phatthana	33140	2025-12-18 04:35:42.869	3317
331801	331801	เมืองจันทร์	Mueang Chan	33120	2025-12-18 04:35:42.87	3318
331802	331802	ตาโกน	Takon	33120	2025-12-18 04:35:42.871	3318
331803	331803	หนองใหญ่	Nong Yai	33120	2025-12-18 04:35:42.872	3318
331901	331901	เสียว	Siao	33110	2025-12-18 04:35:42.873	3319
331902	331902	หนองหว้า	Nong Wa	33110	2025-12-18 04:35:42.874	3319
331903	331903	หนองงูเหลือม	Nong Ngu Lueam	33110	2025-12-18 04:35:42.875	3319
331904	331904	หนองฮาง	Nong Hang	33110	2025-12-18 04:35:42.876	3319
331905	331905	ท่าคล้อ	Tha Khlo	33110	2025-12-18 04:35:42.877	3319
332001	332001	พยุห์	Phayu	33230	2025-12-18 04:35:42.878	3320
332002	332002	พรหมสวัสดิ์	Phrom Sawat	33230	2025-12-18 04:35:42.879	3320
332003	332003	ตำแย	Tamyae	33230	2025-12-18 04:35:42.88	3320
332004	332004	โนนเพ็ก	Non Phek	33230	2025-12-18 04:35:42.881	3320
332005	332005	หนองค้า	Nong Kha	33230	2025-12-18 04:35:42.882	3320
332101	332101	โดด	Dot	33120	2025-12-18 04:35:42.883	3321
332102	332102	เสียว	Siao	33120	2025-12-18 04:35:42.884	3321
332103	332103	หนองม้า	Nong Ma	33120	2025-12-18 04:35:42.885	3321
332104	332104	ผือใหญ่	Phue Yai	33120	2025-12-18 04:35:42.886	3321
332105	332105	อีเซ	I Se	33120	2025-12-18 04:35:42.887	3321
332201	332201	กุง	Kung	33160	2025-12-18 04:35:42.888	3322
332202	332202	คลีกลิ้ง	Kleek Ling	33160	2025-12-18 04:35:42.889	3322
332203	332203	หนองบัวดง	Nong Bua Dong	33160	2025-12-18 04:35:42.89	3322
332204	332204	โจดม่วง	Jod Maung	33160	2025-12-18 04:35:42.891	3322
340101	340101	ในเมือง	Nai Mueang	34000	2025-12-18 04:35:42.892	3401
340104	340104	หัวเรือ	Hua Ruea	34000	2025-12-18 04:35:42.892	3401
340105	340105	หนองขอน	Nong Khon	34000	2025-12-18 04:35:42.893	3401
340107	340107	ปทุม	Pathum	34000	2025-12-18 04:35:42.894	3401
340108	340108	ขามใหญ่	Kham Yai	34000	2025-12-18 04:35:42.895	3401
340109	340109	แจระแม	Chaeramae	34000	2025-12-18 04:35:42.896	3401
340111	340111	หนองบ่อ	Nong Bo	34000	2025-12-18 04:35:42.897	3401
340112	340112	ไร่น้อย	Rai Noi	34000	2025-12-18 04:35:42.898	3401
340113	340113	กระโสบ	Krasop	34000	2025-12-18 04:35:42.899	3401
340116	340116	กุดลาด	Kut Lat	34000	2025-12-18 04:35:42.9	3401
340119	340119	ขี้เหล็ก	Khilek	34000	2025-12-18 04:35:42.901	3401
340120	340120	ปะอาว	Pa-ao	34000	2025-12-18 04:35:42.902	3401
340201	340201	นาคำ	Na Kham	34250	2025-12-18 04:35:42.903	3402
340202	340202	แก้งกอก	Kaeng Kok	34250	2025-12-18 04:35:42.904	3402
340203	340203	เอือดใหญ่	Ueat Yai	34250	2025-12-18 04:35:42.905	3402
340204	340204	วาริน	Warin	34250	2025-12-18 04:35:42.906	3402
340205	340205	ลาดควาย	Lat Khwai	34250	2025-12-18 04:35:42.907	3402
340206	340206	สงยาง	Song Yang	34250	2025-12-18 04:35:42.907	3402
340207	340207	ตะบ่าย	Ta Bai	34250	2025-12-18 04:35:42.908	3402
340208	340208	คำไหล	Kham Lai	34250	2025-12-18 04:35:42.909	3402
340209	340209	หนามแท่ง	Nam Thaeng	34250	2025-12-18 04:35:42.91	3402
340210	340210	นาเลิน	Na Loen	34250	2025-12-18 04:35:42.911	3402
340211	340211	ดอนใหญ่	Don Yai	34250	2025-12-18 04:35:42.912	3402
340301	340301	โขงเจียม	Khong Chiam	34220	2025-12-18 04:35:42.913	3403
340302	340302	ห้วยยาง	Huai Yang	34220	2025-12-18 04:35:42.914	3403
340303	340303	นาโพธิ์กลาง	Na Pho Klang	34220	2025-12-18 04:35:42.915	3403
340304	340304	หนองแสงใหญ่	Nong Saeng Yai	34220	2025-12-18 04:35:42.916	3403
340305	340305	ห้วยไผ่	Huai Phai	34220	2025-12-18 04:35:42.917	3403
340306	340306	คำเขื่อนแก้ว	Kham Khuen Kaew	34220	2025-12-18 04:35:42.918	3403
340401	340401	เขื่องใน	Khueang Nai	34150	2025-12-18 04:35:42.919	3404
340402	340402	สร้างถ่อ	Sang Tho	34150	2025-12-18 04:35:42.92	3404
340403	340403	ค้อทอง	Kho Thong	34150	2025-12-18 04:35:42.921	3404
340404	340404	ก่อเอ้	Ko E	34150	2025-12-18 04:35:42.922	3404
340405	340405	หัวดอน	Hua Don	34150	2025-12-18 04:35:42.923	3404
340406	340406	ชีทวน	Chi Thuan	34150	2025-12-18 04:35:42.924	3404
340407	340407	ท่าไห	Tha Hai	34150	2025-12-18 04:35:42.925	3404
340408	340408	นาคำใหญ่	Na Kham Yai	34150	2025-12-18 04:35:42.925	3404
340409	340409	แดงหม้อ	Daeng Mo	34150	2025-12-18 04:35:42.926	3404
340410	340410	ธาตุน้อย	That Noi	34150	2025-12-18 04:35:42.927	3404
340411	340411	บ้านไทย	Ban Thai	34320	2025-12-18 04:35:42.929	3404
340412	340412	บ้านกอก	Ban Kok	34320	2025-12-18 04:35:42.929	3404
340413	340413	กลางใหญ่	Klang Yai	34320	2025-12-18 04:35:42.93	3404
340414	340414	โนนรัง	Non Rang	34320	2025-12-18 04:35:42.931	3404
340415	340415	ยางขี้นก	Yang Khi Nok	34150	2025-12-18 04:35:42.932	3404
340416	340416	ศรีสุข	Si Suk	34150	2025-12-18 04:35:42.933	3404
340417	340417	สหธาตุ	Sahathat	34150	2025-12-18 04:35:42.934	3404
340418	340418	หนองเหล่า	Nong Lao	34150	2025-12-18 04:35:42.935	3404
340501	340501	เขมราฐ	Khemarat	34170	2025-12-18 04:35:42.936	3405
340503	340503	ขามป้อม	Kham Pom	34170	2025-12-18 04:35:42.937	3405
340507	340507	หนองผือ	Nong Phue	34170	2025-12-18 04:35:42.939	3405
340508	340508	นาแวง	Na Waeng	34170	2025-12-18 04:35:42.94	3405
340510	340510	แก้งเหนือ	Kaeng Nuea	34170	2025-12-18 04:35:42.94	3405
340511	340511	หนองนกทา	Nong Nok Tha	34170	2025-12-18 04:35:42.941	3405
340512	340512	หนองสิม	Nong Sim	34170	2025-12-18 04:35:42.942	3405
340513	340513	หัวนา	Hua Na	34170	2025-12-18 04:35:42.943	3405
340701	340701	เมืองเดช	Mueang Det	34160	2025-12-18 04:35:42.944	3407
340702	340702	นาส่วง	Na Suang	34160	2025-12-18 04:35:42.945	3407
340704	340704	นาเจริญ	Na Charoen	34160	2025-12-18 04:35:42.946	3407
340706	340706	ทุ่งเทิง	Thung Thoeng	34160	2025-12-18 04:35:42.947	3407
340708	340708	สมสะอาด	Som Sa-at	34160	2025-12-18 04:35:42.948	3407
340709	340709	กุดประทาย	Kut Prathai	34160	2025-12-18 04:35:42.949	3407
340710	340710	ตบหู	Top Hu	34160	2025-12-18 04:35:42.95	3407
340711	340711	กลาง	Klang	34160	2025-12-18 04:35:42.951	3407
340712	340712	แก้ง	Kaeng	34160	2025-12-18 04:35:42.951	3407
340713	340713	ท่าโพธิ์ศรี	Tha Pho Si	34160	2025-12-18 04:35:42.952	3407
340715	340715	บัวงาม	Bua Ngam	34160	2025-12-18 04:35:42.953	3407
340716	340716	คำครั่ง	Kham Khrang	34160	2025-12-18 04:35:42.954	3407
340717	340717	นากระแซง	Na Krasaeng	34160	2025-12-18 04:35:42.955	3407
340720	340720	โพนงาม	Phon Ngam	34160	2025-12-18 04:35:42.956	3407
340721	340721	ป่าโมง	Pa Mong	34160	2025-12-18 04:35:42.957	3407
340723	340723	โนนสมบูรณ์	Non Sombun	34160	2025-12-18 04:35:42.958	3407
340801	340801	นาจะหลวย	Na Chaluai	34280	2025-12-18 04:35:42.959	3408
340802	340802	โนนสมบูรณ์	Non Sombun	34280	2025-12-18 04:35:42.96	3408
340803	340803	พรสวรรค์	Phon Sawan	34280	2025-12-18 04:35:42.961	3408
340804	340804	บ้านตูม	Ban Tum	34280	2025-12-18 04:35:42.961	3408
340805	340805	โสกแสง	Sok Saeng	34280	2025-12-18 04:35:42.962	3408
340806	340806	โนนสวรรค์	Non Sawan	34280	2025-12-18 04:35:42.963	3408
340901	340901	โซง	Song	34260	2025-12-18 04:35:42.964	3409
340903	340903	ยาง	Yang	34260	2025-12-18 04:35:42.965	3409
340904	340904	โดมประดิษฐ์	Dom Pradit	34260	2025-12-18 04:35:42.966	3409
340906	340906	บุเปือย	Bu Pueai	34260	2025-12-18 04:35:42.967	3409
340907	340907	สีวิเชียร	Si Wichian	34260	2025-12-18 04:35:42.968	3409
340909	340909	ยางใหญ่	Yang Yai	34260	2025-12-18 04:35:42.969	3409
340911	340911	เก่าขาม	Kao Kham	34260	2025-12-18 04:35:42.97	3409
341001	341001	โพนงาม	Phon Ngam	34230	2025-12-18 04:35:42.971	3410
341002	341002	ห้วยข่า	Huai Kha	34230	2025-12-18 04:35:42.972	3410
341003	341003	คอแลน	Kho Laen	34230	2025-12-18 04:35:42.972	3410
101704	101704	สามเสนนอก	Samsen Nok	10310	2025-12-18 04:35:38.63	1017
341004	341004	นาโพธิ์	Na Pho	34230	2025-12-18 04:35:42.973	3410
341005	341005	หนองสะโน	Nong Sano	34230	2025-12-18 04:35:42.974	3410
341006	341006	โนนค้อ	Non Kho	34230	2025-12-18 04:35:42.975	3410
341007	341007	บัวงาม	Bua Ngam	34230	2025-12-18 04:35:42.976	3410
341008	341008	บ้านแมด	Ban Maet	34230	2025-12-18 04:35:42.977	3410
341101	341101	ขุหลุ	Khulu	34130	2025-12-18 04:35:42.978	3411
341102	341102	กระเดียน	Kradian	34130	2025-12-18 04:35:42.979	3411
341103	341103	เกษม	Kasem	34130	2025-12-18 04:35:42.98	3411
341104	341104	กุศกร	Kutsakon	34130	2025-12-18 04:35:42.981	3411
341105	341105	ขามเปี้ย	Kham Pia	34130	2025-12-18 04:35:42.982	3411
341106	341106	คอนสาย	Khon Sai	34130	2025-12-18 04:35:42.982	3411
341107	341107	โคกจาน	Khok Chan	34130	2025-12-18 04:35:42.983	3411
341108	341108	นาพิน	Na Phin	34130	2025-12-18 04:35:42.984	3411
341109	341109	นาสะไม	Na Samai	34130	2025-12-18 04:35:42.985	3411
341110	341110	โนนกุง	Non Kung	34130	2025-12-18 04:35:42.986	3411
341112	341112	ตากแดด	Tak Daet	34130	2025-12-18 04:35:42.988	3411
341113	341113	ไหล่ทุ่ง	Lai Thung	34130	2025-12-18 04:35:42.989	3411
341114	341114	เป้า	Pao	34130	2025-12-18 04:35:42.99	3411
341115	341115	เซเป็ด	Se Pet	34130	2025-12-18 04:35:42.991	3411
341116	341116	สะพือ	Saphue	34130	2025-12-18 04:35:42.992	3411
341117	341117	หนองเต่า	Nong Tao	34130	2025-12-18 04:35:42.993	3411
341118	341118	ถ้ำแข้	Tham Khae	34130	2025-12-18 04:35:42.994	3411
341119	341119	ท่าหลวง	Tha Luang	34130	2025-12-18 04:35:42.995	3411
341120	341120	ห้วยฝ้ายพัฒนา	Huai Fai Phatthana	34130	2025-12-18 04:35:42.996	3411
341121	341121	กุดยาลวน	Kut Ya Luan	34130	2025-12-18 04:35:42.997	3411
341122	341122	บ้านแดง	Ban Daeng	34130	2025-12-18 04:35:42.997	3411
341123	341123	คำเจริญ	Kham Charoen	34130	2025-12-18 04:35:42.998	3411
341201	341201	ข้าวปุ้น	Khaopun	34270	2025-12-18 04:35:42.999	3412
341202	341202	โนนสวาง	Non Sawang	34270	2025-12-18 04:35:43	3412
341203	341203	แก่งเค็ง	Kaeng Kheng	34270	2025-12-18 04:35:43.001	3412
341204	341204	กาบิน	Ka Bin	34270	2025-12-18 04:35:43.002	3412
341205	341205	หนองทันน้ำ	Nong Than Nam	34270	2025-12-18 04:35:43.003	3412
341401	341401	ม่วงสามสิบ	Muang Sam Sip	34140	2025-12-18 04:35:43.004	3414
341402	341402	เหล่าบก	Lao Bok	34140	2025-12-18 04:35:43.005	3414
341403	341403	ดุมใหญ่	Dum Yai	34140	2025-12-18 04:35:43.006	3414
341404	341404	หนองช้างใหญ่	Non Chang Yai	34140	2025-12-18 04:35:43.007	3414
341405	341405	หนองเมือง	Nong Mueang	34140	2025-12-18 04:35:43.008	3414
341406	341406	เตย	Toei	34140	2025-12-18 04:35:43.009	3414
341407	341407	ยางสักกระโพหลุ่ม	Yang Sak Krapho Lum	34140	2025-12-18 04:35:43.01	3414
341408	341408	หนองไข่นก	Nong Khai Nok	34140	2025-12-18 04:35:43.011	3414
341409	341409	หนองเหล่า	Nong Lao	34140	2025-12-18 04:35:43.012	3414
341410	341410	หนองฮาง	Nong Hang	34140	2025-12-18 04:35:43.013	3414
341411	341411	ยางโยภาพ	Yang Yo Phap	34140	2025-12-18 04:35:43.014	3414
341412	341412	ไผ่ใหญ่	Phai Yai	34140	2025-12-18 04:35:43.014	3414
341413	341413	นาเลิง	Na Loeng	34140	2025-12-18 04:35:43.015	3414
341414	341414	โพนแพง	Phon Phaeng	34140	2025-12-18 04:35:43.016	3414
341501	341501	วารินชำราบ	Warin Chamrap	34190	2025-12-18 04:35:43.017	3415
341502	341502	ธาตุ	That	34190	2025-12-18 04:35:43.018	3415
341504	341504	ท่าลาด	Tha Lat	34310	2025-12-18 04:35:43.019	3415
341505	341505	โนนโหนน	Non Non	34190	2025-12-18 04:35:43.02	3415
341507	341507	คูเมือง	Khu Mueang	34190	2025-12-18 04:35:43.021	3415
341508	341508	สระสมิง	Sa Saming	34190	2025-12-18 04:35:43.022	3415
341510	341510	คำน้ำแซบ	Kham Nam Saep	34190	2025-12-18 04:35:43.022	3415
341511	341511	บุ่งหวาย	Bung Wai	34310	2025-12-18 04:35:43.023	3415
341515	341515	คำขวาง	Kham Khwang	34190	2025-12-18 04:35:43.024	3415
341516	341516	โพธิ์ใหญ่	Pho Yai	34190	2025-12-18 04:35:43.025	3415
341518	341518	แสนสุข	Saen Suk	34190	2025-12-18 04:35:43.026	3415
341520	341520	หนองกินเพล	Nong Kin Phen	34190	2025-12-18 04:35:43.027	3415
341521	341521	โนนผึ้ง	Non Phueng	34190	2025-12-18 04:35:43.028	3415
341522	341522	เมืองศรีไค	Mueang Si Khai	34190	2025-12-18 04:35:43.029	3415
341524	341524	ห้วยขะยูง	Huai Khayung	34310	2025-12-18 04:35:43.03	3415
341526	341526	บุ่งไหม	Bung Mai	34190	2025-12-18 04:35:43.031	3415
341902	341902	กุดชมภู	Kut Chom Phu	34110	2025-12-18 04:35:43.033	3419
341904	341904	ดอนจิก	Don Chik	34110	2025-12-18 04:35:43.033	3419
341905	341905	ทรายมูล	Sai Mun	34110	2025-12-18 04:35:43.034	3419
341906	341906	นาโพธิ์	Na Pho	34110	2025-12-18 04:35:43.035	3419
341907	341907	โนนกลาง	Non Klang	34110	2025-12-18 04:35:43.036	3419
341909	341909	โพธิ์ไทร	Pho Sai	34110	2025-12-18 04:35:43.037	3419
341910	341910	โพธิ์ศรี	Pho Si	34110	2025-12-18 04:35:43.038	3419
341911	341911	ระเว	Rawe	34110	2025-12-18 04:35:43.039	3419
341912	341912	ไร่ใต้	Rai Tai	34110	2025-12-18 04:35:43.04	3419
341913	341913	หนองบัวฮี	Nong Bua Hi	34110	2025-12-18 04:35:43.04	3419
341914	341914	อ่างศิลา	Ang Sila	34110	2025-12-18 04:35:43.041	3419
341918	341918	โนนกาหลง	Non Kalong	34110	2025-12-18 04:35:43.042	3419
341919	341919	บ้านแขม	Ban Khaem	34110	2025-12-18 04:35:43.043	3419
342001	342001	ตาลสุม	Tan Sum	34330	2025-12-18 04:35:43.044	3420
342002	342002	สำโรง	Samrong	34330	2025-12-18 04:35:43.045	3420
342003	342003	จิกเทิง	Chik Thoeng	34330	2025-12-18 04:35:43.046	3420
342004	342004	หนองกุง	Nong Kung	34330	2025-12-18 04:35:43.047	3420
342005	342005	นาคาย	Na Khai	34330	2025-12-18 04:35:43.048	3420
342006	342006	คำหว้า	Kham Wa	34330	2025-12-18 04:35:43.049	3420
342101	342101	โพธิ์ไทร	Pho Sai	34340	2025-12-18 04:35:43.049	3421
342102	342102	ม่วงใหญ่	Muang Yai	34340	2025-12-18 04:35:43.05	3421
342103	342103	สำโรง	Sam Rong	34340	2025-12-18 04:35:43.051	3421
342104	342104	สองคอน	Song Khon	34340	2025-12-18 04:35:43.052	3421
342105	342105	สารภี	Saraphi	34340	2025-12-18 04:35:43.053	3421
342106	342106	เหล่างาม	Lao Ngam	34340	2025-12-18 04:35:43.054	3421
342201	342201	สำโรง	Samrong	34360	2025-12-18 04:35:43.055	3422
342202	342202	โคกก่อง	Khok Kong	34360	2025-12-18 04:35:43.056	3422
342203	342203	หนองไฮ	Nong Hai	34360	2025-12-18 04:35:43.057	3422
342204	342204	ค้อน้อย	Kho Noi	34360	2025-12-18 04:35:43.058	3422
342205	342205	โนนกาเล็น	Non Ka Len	34360	2025-12-18 04:35:43.058	3422
342206	342206	โคกสว่าง	Khok Sawang	34360	2025-12-18 04:35:43.059	3422
342207	342207	โนนกลาง	Non Klang	34360	2025-12-18 04:35:43.06	3422
342208	342208	บอน	Bon	34360	2025-12-18 04:35:43.061	3422
342209	342209	ขามป้อม	Kham Pom	34360	2025-12-18 04:35:43.062	3422
342401	342401	ดอนมดแดง	Don Mot Daeng	34000	2025-12-18 04:35:43.063	3424
342402	342402	เหล่าแดง	Lao Daeng	34000	2025-12-18 04:35:43.064	3424
342403	342403	ท่าเมือง	Tha Mueang	34000	2025-12-18 04:35:43.065	3424
342404	342404	คำไฮใหญ่	Kham Hai Yai	34000	2025-12-18 04:35:43.066	3424
342501	342501	คันไร่	Khan Rai	34350	2025-12-18 04:35:43.067	3425
342502	342502	ช่องเม็ก	Chong Mek	34350	2025-12-18 04:35:43.067	3425
342503	342503	โนนก่อ	Non Ko	34350	2025-12-18 04:35:43.068	3425
342504	342504	นิคมสร้างตนเองลำโดมน้อย	Nikhom Sang Ton Eng Lam Dom Noi	34350	2025-12-18 04:35:43.069	3425
342505	342505	ฝางคำ	Fang Kham	34350	2025-12-18 04:35:43.07	3425
342506	342506	คำเขื่อนแก้ว	Kham Khuean Kaeo	34350	2025-12-18 04:35:43.071	3425
342602	342602	หนองอ้ม	Nong Om	34160	2025-12-18 04:35:43.072	3426
342603	342603	นาเกษม	Na Kasem	34160	2025-12-18 04:35:43.073	3426
342604	342604	กุดเรือ	Kut Ruea	34160	2025-12-18 04:35:43.074	3426
342605	342605	โคกชำแระ	Khok Chamrae	34160	2025-12-18 04:35:43.075	3426
342606	342606	นาห่อม	Na Hom	34160	2025-12-18 04:35:43.076	3426
342901	342901	นาเยีย	Na Yia	34160	2025-12-18 04:35:43.077	3429
342902	342902	นาดี	Na Di	34160	2025-12-18 04:35:43.077	3429
342903	342903	นาเรือง	Na Rueang	34160	2025-12-18 04:35:43.078	3429
343001	343001	นาตาล	Na Tan	34170	2025-12-18 04:35:43.079	3430
343002	343002	พะลาน	Phalan	34170	2025-12-18 04:35:43.08	3430
343003	343003	กองโพน	Kong Phon	34170	2025-12-18 04:35:43.081	3430
343004	343004	พังเคน	Phang Khen	34170	2025-12-18 04:35:43.082	3430
343101	343101	เหล่าเสือโก้ก	Lao Suea Kok	34000	2025-12-18 04:35:43.083	3431
343102	343102	โพนเมือง	Phon Mueang	34000	2025-12-18 04:35:43.084	3431
343103	343103	แพงใหญ่	Phaeng Yai	34000	2025-12-18 04:35:43.085	3431
343104	343104	หนองบก	Nong Bok	34000	2025-12-18 04:35:43.086	3431
343201	343201	แก่งโดม	Kaeng Dom	34190	2025-12-18 04:35:43.087	3432
343202	343202	ท่าช้าง	Tha Chang	34190	2025-12-18 04:35:43.087	3432
343203	343203	บุ่งมะแลง	Bung Malaeng	34190	2025-12-18 04:35:43.088	3432
343204	343204	สว่าง	Sawang	34190	2025-12-18 04:35:43.089	3432
343301	343301	ตาเกา	Ta Kao	34260	2025-12-18 04:35:43.09	3433
343302	343302	ไพบูลย์	Phaibun	34260	2025-12-18 04:35:43.091	3433
343303	343303	ขี้เหล็ก	Khilek	34260	2025-12-18 04:35:43.092	3433
343304	343304	โคกสะอาด	Khok Sa-at	34260	2025-12-18 04:35:43.093	3433
350101	350101	ในเมือง	Nai Mueang	35000	2025-12-18 04:35:43.094	3501
350102	350102	น้ำคำใหญ่	Nam Kham Yai	35000	2025-12-18 04:35:43.095	3501
350103	350103	ตาดทอง	Tat Thong	35000	2025-12-18 04:35:43.096	3501
350104	350104	สำราญ	Samran	35000	2025-12-18 04:35:43.096	3501
350105	350105	ค้อเหนือ	Kho Nuea	35000	2025-12-18 04:35:43.097	3501
350106	350106	ดู่ทุ่ง	Du Thung	35000	2025-12-18 04:35:43.098	3501
350107	350107	เดิด	Doet	35000	2025-12-18 04:35:43.099	3501
350108	350108	ขั้นไดใหญ่	Khandai Yai	35000	2025-12-18 04:35:43.1	3501
350109	350109	ทุ่งแต้	Thung Tae	35000	2025-12-18 04:35:43.101	3501
350110	350110	สิงห์	Sing	35000	2025-12-18 04:35:43.102	3501
350111	350111	นาสะไมย์	Na Samai	35000	2025-12-18 04:35:43.103	3501
350112	350112	เขื่องคำ	Khueang Kham	35000	2025-12-18 04:35:43.104	3501
350113	350113	หนองหิน	Nong Hin	35000	2025-12-18 04:35:43.105	3501
350114	350114	หนองคู	Nong Khu	35000	2025-12-18 04:35:43.106	3501
350115	350115	ขุมเงิน	Khum Ngoen	35000	2025-12-18 04:35:43.107	3501
350116	350116	ทุ่งนางโอก	Thung Nang Ok	35000	2025-12-18 04:35:43.108	3501
350117	350117	หนองเรือ	Nong Ruea	35000	2025-12-18 04:35:43.108	3501
350118	350118	หนองเป็ด	Nong Pet	35000	2025-12-18 04:35:43.109	3501
350201	350201	ทรายมูล	Sai Mun	35170	2025-12-18 04:35:43.11	3502
350202	350202	ดู่ลาด	Du Lat	35170	2025-12-18 04:35:43.111	3502
350203	350203	ดงมะไฟ	Dong Mafai	35170	2025-12-18 04:35:43.112	3502
350204	350204	นาเวียง	Na Wiang	35170	2025-12-18 04:35:43.113	3502
350205	350205	ไผ่	Phai	35170	2025-12-18 04:35:43.114	3502
350301	350301	กุดชุม	Kut Chum	35140	2025-12-18 04:35:43.115	3503
350302	350302	โนนเปือย	Non Pueai	35140	2025-12-18 04:35:43.115	3503
350303	350303	กำแมด	Kammaet	35140	2025-12-18 04:35:43.116	3503
350304	350304	นาโส่	Na So	35140	2025-12-18 04:35:43.117	3503
350305	350305	ห้วยแก้ง	Huai Kaeng	35140	2025-12-18 04:35:43.118	3503
350306	350306	หนองหมี	Nong Mi	35140	2025-12-18 04:35:43.119	3503
350307	350307	โพนงาม	Phon Ngam	35140	2025-12-18 04:35:43.12	3503
350308	350308	คำน้ำสร้าง	Kham Nam Sang	35140	2025-12-18 04:35:43.121	3503
350309	350309	หนองแหน	Nong Nae	35140	2025-12-18 04:35:43.122	3503
350401	350401	ลุมพุก	Lumphuk	35110	2025-12-18 04:35:43.123	3504
350402	350402	ย่อ	Yo	35110	2025-12-18 04:35:43.124	3504
350403	350403	สงเปือย	Song Pueai	35110	2025-12-18 04:35:43.125	3504
350404	350404	โพนทัน	Phon Than	35110	2025-12-18 04:35:43.125	3504
350405	350405	ทุ่งมน	Thung Mon	35110	2025-12-18 04:35:43.126	3504
350406	350406	นาคำ	Na Kham	35180	2025-12-18 04:35:43.127	3504
350407	350407	ดงแคนใหญ่	Dong Khaen Yai	35180	2025-12-18 04:35:43.128	3504
350408	350408	กู่จาน	Ku Chan	35110	2025-12-18 04:35:43.129	3504
350409	350409	นาแก	Na Kae	35180	2025-12-18 04:35:43.13	3504
350410	350410	กุดกุง	Kut Kung	35110	2025-12-18 04:35:43.131	3504
350411	350411	เหล่าไฮ	Lao Hai	35110	2025-12-18 04:35:43.132	3504
350412	350412	แคนน้อย	Khaen Noi	35180	2025-12-18 04:35:43.133	3504
350413	350413	ดงเจริญ	Dong Charoen	35110	2025-12-18 04:35:43.133	3504
350501	350501	โพธิ์ไทร	Pho Sai	35150	2025-12-18 04:35:43.134	3505
350502	350502	กระจาย	Krachai	35150	2025-12-18 04:35:43.135	3505
350503	350503	โคกนาโก	Khok Na Ko	35150	2025-12-18 04:35:43.136	3505
350504	350504	เชียงเพ็ง	Chiang Pheng	35150	2025-12-18 04:35:43.137	3505
350505	350505	ศรีฐาน	Si Than	35150	2025-12-18 04:35:43.138	3505
350601	350601	ฟ้าหยาด	Fa Yat	35130	2025-12-18 04:35:43.139	3506
350602	350602	หัวเมือง	Hua Mueang	35130	2025-12-18 04:35:43.14	3506
350603	350603	คูเมือง	Khu Mueang	35130	2025-12-18 04:35:43.141	3506
350604	350604	ผือฮี	Phue Hi	35130	2025-12-18 04:35:43.142	3506
350605	350605	บากเรือ	Bak Ruea	35130	2025-12-18 04:35:43.143	3506
350606	350606	ม่วง	Muang	35130	2025-12-18 04:35:43.144	3506
350607	350607	โนนทราย	Non Sai	35130	2025-12-18 04:35:43.145	3506
350608	350608	บึงแก	Bueng Kae	35130	2025-12-18 04:35:43.145	3506
350609	350609	พระเสาร์	Phra Sao	35130	2025-12-18 04:35:43.146	3506
350610	350610	สงยาง	Song Yang	35130	2025-12-18 04:35:43.147	3506
350701	350701	ฟ้าห่วน	Fa Huan	35160	2025-12-18 04:35:43.148	3507
350702	350702	กุดน้ำใส	Kut Nam Sai	35160	2025-12-18 04:35:43.149	3507
350703	350703	น้ำอ้อม	Nam Om	35160	2025-12-18 04:35:43.15	3507
350704	350704	ค้อวัง	Kho Wang	35160	2025-12-18 04:35:43.151	3507
350802	350802	บุ่งค้า	Bung Kha	35120	2025-12-18 04:35:43.152	3508
350803	350803	สวาท	Sawat	35120	2025-12-18 04:35:43.152	3508
350805	350805	ห้องแซง	Hong Saeng	35120	2025-12-18 04:35:43.153	3508
350806	350806	สามัคคี	Samakkhi	35120	2025-12-18 04:35:43.154	3508
350807	350807	กุดเชียงหมี	Kut Chiang Mi	35120	2025-12-18 04:35:43.155	3508
350810	350810	สามแยก	Sam Yaek	35120	2025-12-18 04:35:43.156	3508
350811	350811	กุดแห่	Kut Hae	35120	2025-12-18 04:35:43.157	3508
350812	350812	โคกสำราญ	Khok Samran	35120	2025-12-18 04:35:43.158	3508
350813	350813	สร้างมิ่ง	Sang Ming	35120	2025-12-18 04:35:43.159	3508
350814	350814	ศรีแก้ว	Si Kaeo	35120	2025-12-18 04:35:43.16	3508
350901	350901	ไทยเจริญ	Thai Charoen	35120	2025-12-18 04:35:43.161	3509
350902	350902	น้ำคำ	Nam Kham	35120	2025-12-18 04:35:43.162	3509
350903	350903	ส้มผ่อ	Som Pho	35120	2025-12-18 04:35:43.163	3509
350904	350904	คำเตย	Kham Toei	35120	2025-12-18 04:35:43.163	3509
350905	350905	คำไผ่	Kham Phai	35120	2025-12-18 04:35:43.164	3509
360101	360101	ในเมือง	Nai Mueang	36000	2025-12-18 04:35:43.165	3601
360102	360102	รอบเมือง	Rop Mueang	36000	2025-12-18 04:35:43.166	3601
360103	360103	โพนทอง	Phon Thong	36000	2025-12-18 04:35:43.167	3601
360104	360104	นาฝาย	Na Fai	36000	2025-12-18 04:35:43.168	3601
360105	360105	บ้านค่าย	Ban Khai	36240	2025-12-18 04:35:43.169	3601
360106	360106	กุดตุ้ม	Kut Tum	36000	2025-12-18 04:35:43.171	3601
360107	360107	ชีลอง	Chi Long	36000	2025-12-18 04:35:43.172	3601
360108	360108	บ้านเล่า	Ban Lao	36000	2025-12-18 04:35:43.173	3601
360109	360109	นาเสียว	Na Siao	36000	2025-12-18 04:35:43.175	3601
360110	360110	หนองนาแซง	Nong Na Saeng	36000	2025-12-18 04:35:43.176	3601
360111	360111	ลาดใหญ่	Lat Yai	36000	2025-12-18 04:35:43.177	3601
360112	360112	หนองไผ่	Nong Phai	36240	2025-12-18 04:35:43.178	3601
360113	360113	ท่าหินโงม	Tha Hin Ngom	36000	2025-12-18 04:35:43.18	3601
360114	360114	ห้วยต้อน	Huai Ton	36000	2025-12-18 04:35:43.181	3601
360115	360115	ห้วยบง	Huai Bong	36000	2025-12-18 04:35:43.182	3601
360116	360116	โนนสำราญ	Non Samran	36240	2025-12-18 04:35:43.184	3601
360117	360117	โคกสูง	Khok Sung	36000	2025-12-18 04:35:43.185	3601
360118	360118	บุ่งคล้า	Bung Khla	36000	2025-12-18 04:35:43.186	3601
360119	360119	ซับสีทอง	Sap Si Thong	36000	2025-12-18 04:35:43.187	3601
360201	360201	บ้านเขว้า	Ban Khwao	36170	2025-12-18 04:35:43.189	3602
360202	360202	ตลาดแร้ง	Talat Raeng	36170	2025-12-18 04:35:43.19	3602
360203	360203	ลุ่มลำชี	Lum Lam Chi	36170	2025-12-18 04:35:43.191	3602
360204	360204	ชีบน	Chi Bon	36170	2025-12-18 04:35:43.193	3602
360205	360205	ภูแลนคา	Phu Laen Kha	36170	2025-12-18 04:35:43.194	3602
360206	360206	โนนแดง	Non Dang	36170	2025-12-18 04:35:43.195	3602
360301	360301	คอนสวรรค์	Khon Sawan	36140	2025-12-18 04:35:43.197	3603
360302	360302	ยางหวาย	Yang Wai	36140	2025-12-18 04:35:43.198	3603
360303	360303	ช่องสามหมอ	Chong Sam Mo	36140	2025-12-18 04:35:43.199	3603
360304	360304	โนนสะอาด	Non Sa-at	36140	2025-12-18 04:35:43.201	3603
360305	360305	ห้วยไร่	Huai Rai	36140	2025-12-18 04:35:43.202	3603
360306	360306	บ้านโสก	Ban Sok	36140	2025-12-18 04:35:43.203	3603
360307	360307	โคกมั่งงอย	Khok Mang Ngoi	36140	2025-12-18 04:35:43.204	3603
360308	360308	หนองขาม	Nong Kham	36140	2025-12-18 04:35:43.206	3603
360309	360309	ศรีสำราญ	Si Samran	36140	2025-12-18 04:35:43.207	3603
360401	360401	บ้านยาง	Ban Yang	36120	2025-12-18 04:35:43.209	3604
360402	360402	บ้านหัน	Ban Han	36120	2025-12-18 04:35:43.21	3604
360403	360403	บ้านเดื่อ	Ban Duea	36120	2025-12-18 04:35:43.211	3604
360404	360404	บ้านเป้า	Ban Pao	36120	2025-12-18 04:35:43.213	3604
360405	360405	กุดเลาะ	Kut Lo	36120	2025-12-18 04:35:43.214	3604
360406	360406	โนนกอก	Non Kok	36120	2025-12-18 04:35:43.215	3604
360407	360407	สระโพนทอง	Sa Phon Thong	36120	2025-12-18 04:35:43.217	3604
360408	360408	หนองข่า	Nong Kha	36120	2025-12-18 04:35:43.218	3604
360409	360409	หนองโพนงาม	Nong Phon Ngam	36120	2025-12-18 04:35:43.219	3604
360410	360410	บ้านบัว	Ban Bua	36120	2025-12-18 04:35:43.221	3604
360412	360412	โนนทอง	Non Thong	36120	2025-12-18 04:35:43.222	3604
360501	360501	หนองบัวแดง	Nong Bua Daeng	36210	2025-12-18 04:35:43.223	3605
360502	360502	กุดชุมแสง	Kut Chum Saeng	36210	2025-12-18 04:35:43.225	3605
360503	360503	ถ้ำวัวแดง	Tham Wua Daeng	36210	2025-12-18 04:35:43.226	3605
360507	360507	หนองแวง	Nong Waeng	36210	2025-12-18 04:35:43.229	3605
360508	360508	คูเมือง	Khu Mueang	36210	2025-12-18 04:35:43.23	3605
360509	360509	ท่าใหญ่	Tha Yai	36210	2025-12-18 04:35:43.231	3605
360511	360511	วังชมภู	Wang Chomphu	36210	2025-12-18 04:35:43.233	3605
360601	360601	บ้านกอก	Ban Kok	36130	2025-12-18 04:35:43.234	3606
360602	360602	หนองบัวบาน	Nong Bua Ban	36130	2025-12-18 04:35:43.235	3606
360603	360603	บ้านขาม	Ban Kham	36130	2025-12-18 04:35:43.236	3606
360605	360605	กุดน้ำใส	Kut Nam Sai	36130	2025-12-18 04:35:43.238	3606
360606	360606	หนองโดน	Nong Don	36130	2025-12-18 04:35:43.239	3606
360607	360607	ละหาน	Lahan	36130	2025-12-18 04:35:43.241	3606
360610	360610	หนองบัวใหญ่	Nong Bua Yai	36130	2025-12-18 04:35:43.242	3606
360611	360611	หนองบัวโคก	Nong Bua Khok	36220	2025-12-18 04:35:43.243	3606
360701	360701	บ้านชวน	Ban Chuan	36160	2025-12-18 04:35:43.246	3607
360702	360702	บ้านเพชร	Ban Phet	36160	2025-12-18 04:35:43.248	3607
360703	360703	บ้านตาล	Ban Tan	36220	2025-12-18 04:35:43.249	3607
360704	360704	หัวทะเล	Hua Thale	36220	2025-12-18 04:35:43.25	3607
360705	360705	โคกเริงรมย์	Khok Roeng Rom	36160	2025-12-18 04:35:43.252	3607
360706	360706	เกาะมะนาว	Ko Manao	36160	2025-12-18 04:35:43.253	3607
360707	360707	โคกเพชรพัฒนา	Khok Phet Phatthana	36160	2025-12-18 04:35:43.255	3607
360801	360801	หนองบัวระเหว	Nong Bua Rawe	36250	2025-12-18 04:35:43.257	3608
360802	360802	วังตะเฆ่	Wang Takhe	36250	2025-12-18 04:35:43.258	3608
360803	360803	ห้วยแย้	Huai Yae	36250	2025-12-18 04:35:43.26	3608
360804	360804	โคกสะอาด	Khok Sa-at	36250	2025-12-18 04:35:43.261	3608
360805	360805	โสกปลาดุก	Sok Pla Duk	36250	2025-12-18 04:35:43.262	3608
360901	360901	วะตะแบก	Wa Tabaek	36230	2025-12-18 04:35:43.264	3609
360902	360902	ห้วยยายจิ๋ว	Huai Yai Chio	36230	2025-12-18 04:35:43.266	3609
360903	360903	นายางกลัก	Na Yang Klak	36230	2025-12-18 04:35:43.267	3609
360904	360904	บ้านไร่	Ban Rai	36230	2025-12-18 04:35:43.268	3609
360905	360905	โป่งนก	Pong Nok	36230	2025-12-18 04:35:43.27	3609
361001	361001	ผักปัง	Phak Pang	36110	2025-12-18 04:35:43.271	3610
361002	361002	กวางโจน	Kwang Chon	36110	2025-12-18 04:35:43.273	3610
361003	361003	หนองคอนไทย	Nong Khon Thai	36110	2025-12-18 04:35:43.275	3610
361004	361004	บ้านแก้ง	Ban Kaeng	36110	2025-12-18 04:35:43.276	3610
361005	361005	กุดยม	Kut Yom	36110	2025-12-18 04:35:43.277	3610
361006	361006	บ้านเพชร	Ban Phet	36110	2025-12-18 04:35:43.279	3610
361007	361007	โคกสะอาด	Khok Sa-at	36110	2025-12-18 04:35:43.281	3610
361008	361008	หนองตูม	Nong Tum	36110	2025-12-18 04:35:43.282	3610
361009	361009	โอโล	Olo	36110	2025-12-18 04:35:43.284	3610
361010	361010	ธาตุทอง	That Thong	36110	2025-12-18 04:35:43.285	3610
361011	361011	บ้านดอน	Ban Don	36110	2025-12-18 04:35:43.286	3610
361101	361101	บ้านแท่น	Ban Thaen	36190	2025-12-18 04:35:43.288	3611
361102	361102	สามสวน	Sam Suan	36190	2025-12-18 04:35:43.289	3611
361103	361103	สระพัง	Sa Phang	36190	2025-12-18 04:35:43.291	3611
361104	361104	บ้านเต่า	Ban Tao	36190	2025-12-18 04:35:43.292	3611
361105	361105	หนองคู	Nong Khu	36190	2025-12-18 04:35:43.294	3611
361201	361201	ช่องสามหมอ	Chong Sam Mo	36150	2025-12-18 04:35:43.295	3612
361202	361202	หนองขาม	Nong Kham	36150	2025-12-18 04:35:43.297	3612
361203	361203	นาหนองทุ่ม	Na Nong Thum	36150	2025-12-18 04:35:43.298	3612
361204	361204	บ้านแก้ง	Ban Kaeng	36150	2025-12-18 04:35:43.3	3612
361205	361205	หนองสังข์	Nong Sang	36150	2025-12-18 04:35:43.302	3612
361206	361206	หลุบคา	Lup Kha	36150	2025-12-18 04:35:43.303	3612
361207	361207	โคกกุง	Khok Kung	36150	2025-12-18 04:35:43.305	3612
361208	361208	เก่าย่าดี	Kao Ya Di	36150	2025-12-18 04:35:43.306	3612
361209	361209	ท่ามะไฟหวาน	Tha Mafai Wan	36150	2025-12-18 04:35:43.308	3612
361210	361210	หนองไผ่	Nong Phai	36150	2025-12-18 04:35:43.31	3612
361301	361301	คอนสาร	Khon San	36180	2025-12-18 04:35:43.311	3613
361302	361302	ทุ่งพระ	Thung Phra	36180	2025-12-18 04:35:43.313	3613
361303	361303	โนนคูณ	Non Khun	36180	2025-12-18 04:35:43.315	3613
361304	361304	ห้วยยาง	Huai Yang	36180	2025-12-18 04:35:43.317	3613
361305	361305	ทุ่งลุยลาย	Thung Luilai	36180	2025-12-18 04:35:43.32	3613
361306	361306	ดงบัง	Dong Bang	36180	2025-12-18 04:35:43.321	3613
361307	361307	ทุ่งนาเลา	Thung Na Lao	36180	2025-12-18 04:35:43.323	3613
361308	361308	ดงกลาง	Dong Klang	36180	2025-12-18 04:35:43.325	3613
361401	361401	บ้านเจียง	Chao Thong	36260	2025-12-18 04:35:43.326	3614
361402	361402	เจาทอง	Ban Chiang	36260	2025-12-18 04:35:43.328	3614
361403	361403	วังทอง	Wang Thong	36260	2025-12-18 04:35:43.331	3614
361404	361404	แหลมทอง	Laem Thong	36260	2025-12-18 04:35:43.333	3614
361501	361501	หนองฉิม	Nong Chim	36130	2025-12-18 04:35:43.335	3615
361502	361502	ตาเนิน	Ta Noen	36130	2025-12-18 04:35:43.337	3615
361504	361504	รังงาม	Rang Ngam	36130	2025-12-18 04:35:43.341	3615
361601	361601	ซับใหญ่	Sap Yai	36130	2025-12-18 04:35:43.344	3616
361602	361602	ท่ากูบ	Tha Kup	36130	2025-12-18 04:35:43.346	3616
361603	361603	ตะโกทอง	Tako Thong	36130	2025-12-18 04:35:43.348	3616
370101	370101	บุ่ง	Bung	37000	2025-12-18 04:35:43.35	3701
370103	370103	นาจิก	Na Chik	37000	2025-12-18 04:35:43.354	3701
370104	370104	ปลาค้าว	Pla Khao	37000	2025-12-18 04:35:43.356	3701
370105	370105	เหล่าพรวน	Lao Pruan	37000	2025-12-18 04:35:43.359	3701
370106	370106	สร้างนกทา	Sang Nok Tha	37000	2025-12-18 04:35:43.361	3701
370107	370107	คึมใหญ่	Khuem Yai	37000	2025-12-18 04:35:43.363	3701
370108	370108	นาผือ	Na Phue	37000	2025-12-18 04:35:43.364	3701
370109	370109	น้ำปลีก	Nam Plik	37000	2025-12-18 04:35:43.366	3701
370110	370110	นาวัง	Na Wang	37000	2025-12-18 04:35:43.368	3701
370111	370111	นาหมอม้า	Na Mo Ma	37000	2025-12-18 04:35:43.37	3701
370112	370112	โนนโพธิ์	Non Pho	37000	2025-12-18 04:35:43.371	3701
370113	370113	โนนหนามแท่ง	Non Nam Thaeng	37000	2025-12-18 04:35:43.374	3701
370114	370114	ห้วยไร่	Huai Rai	37000	2025-12-18 04:35:43.376	3701
370115	370115	หนองมะแซว	Nong Masaeo	37000	2025-12-18 04:35:43.378	3701
370116	370116	กุดปลาดุก	Kut Pla Duk	37000	2025-12-18 04:35:43.38	3701
370117	370117	ดอนเมย	Don Moei	37000	2025-12-18 04:35:43.382	3701
370118	370118	นายม	Na Yom	37000	2025-12-18 04:35:43.385	3701
370119	370119	นาแต้	Na Tae	37000	2025-12-18 04:35:43.387	3701
370201	370201	ชานุมาน	Chanuman	37210	2025-12-18 04:35:43.389	3702
370202	370202	โคกสาร	Khok San	37210	2025-12-18 04:35:43.391	3702
370203	370203	คำเขื่อนแก้ว	Kham Khuean Kaeo	37210	2025-12-18 04:35:43.393	3702
370204	370204	โคกก่ง	Khok Kong	37210	2025-12-18 04:35:43.395	3702
370205	370205	ป่าก่อ	Pa Ko	37210	2025-12-18 04:35:43.397	3702
370302	370302	คำโพน	Kham Phon	37110	2025-12-18 04:35:43.401	3703
370303	370303	นาหว้า	Na Wa	37110	2025-12-18 04:35:43.404	3703
370304	370304	ลือ	Lue	37110	2025-12-18 04:35:43.406	3703
370305	370305	ห้วย	Huai	37110	2025-12-18 04:35:43.408	3703
370306	370306	โนนงาม	Non Ngam	37110	2025-12-18 04:35:43.41	3703
370307	370307	นาป่าแซง	Na Pa Saeng	37110	2025-12-18 04:35:43.412	3703
370401	370401	พนา	Phana	37180	2025-12-18 04:35:43.414	3704
370402	370402	จานลาน	Chan Lan	37180	2025-12-18 04:35:43.416	3704
370403	370403	ไม้กลอน	Mai Klon	37180	2025-12-18 04:35:43.418	3704
370404	370404	พระเหลา	Phra Lao	37180	2025-12-18 04:35:43.421	3704
370501	370501	เสนางคนิคม	Senangkhanikhom	37290	2025-12-18 04:35:43.423	3705
370502	370502	โพนทอง	Phon Thong	37290	2025-12-18 04:35:43.425	3705
370503	370503	ไร่สีสุก	Rai Si Suk	37290	2025-12-18 04:35:43.427	3705
370504	370504	นาเวียง	Na Wiang	37290	2025-12-18 04:35:43.429	3705
370505	370505	หนองไฮ	Nong Hai	37290	2025-12-18 04:35:43.431	3705
370506	370506	หนองสามสี	Nong Sam Si	37290	2025-12-18 04:35:43.434	3705
370601	370601	หัวตะพาน	Hua Taphan	37240	2025-12-18 04:35:43.436	3706
370602	370602	คำพระ	Kham Phra	37240	2025-12-18 04:35:43.438	3706
370603	370603	เค็งใหญ่	Kheng Yai	37240	2025-12-18 04:35:43.44	3706
370604	370604	หนองแก้ว	Nong Kaeo	37240	2025-12-18 04:35:43.443	3706
370605	370605	โพนเมืองน้อย	Phon Mueang Noi	37240	2025-12-18 04:35:43.445	3706
370606	370606	สร้างถ่อน้อย	Sang Tho Noi	37240	2025-12-18 04:35:43.447	3706
370607	370607	จิกดู่	Chik Du	37240	2025-12-18 04:35:43.45	3706
370608	370608	รัตนวารี	Rattanawari	37240	2025-12-18 04:35:43.452	3706
370701	370701	อำนาจ	Amnat	37000	2025-12-18 04:35:43.454	3707
370702	370702	ดงมะยาง	Dong Mayang	37000	2025-12-18 04:35:43.456	3707
370703	370703	เปือย	Pueai	37000	2025-12-18 04:35:43.458	3707
370704	370704	ดงบัง	Dong Bang	37000	2025-12-18 04:35:43.46	3707
370705	370705	ไร่ขี	Rai Khi	37000	2025-12-18 04:35:43.462	3707
370706	370706	แมด	Maet	37000	2025-12-18 04:35:43.465	3707
370707	370707	โคกกลาง	Khok Klang	37000	2025-12-18 04:35:43.467	3707
380101	380101	คำนาดี	Kham Na Di	38000	2025-12-18 04:35:43.469	3801
380102	380102	บึงโขงหลง	Bueng Khong Long	38000	2025-12-18 04:35:43.471	3801
380103	380103	ไคสี	Khai Si	38000	2025-12-18 04:35:43.474	3801
380104	380104	ชัยพร	Chaiyaphon	38000	2025-12-18 04:35:43.476	3801
380105	380105	นาสวรรค์	Na Sawan	38000	2025-12-18 04:35:43.479	3801
380106	380106	โนนสมบูรณ์	Non Sombun	38000	2025-12-18 04:35:43.481	3801
380107	380107	บึงกาฬ	Bueng Kan	38000	2025-12-18 04:35:43.483	3801
380108	380108	โป่งเปื่อย	Pong Pueai	38000	2025-12-18 04:35:43.486	3801
380109	380109	วิศิษฐ์	Wisit	38000	2025-12-18 04:35:43.489	3801
380110	380110	หนองเข็ง	Nong Keng	38000	2025-12-18 04:35:43.491	3801
380111	380111	หนองเลิง	Nong Loeng	38000	2025-12-18 04:35:43.494	3801
380112	380112	หอคำ	Ho Kham	38000	2025-12-18 04:35:43.496	3801
380201	380201	ซาง	Sang	38150	2025-12-18 04:35:43.498	3802
380202	380202	เซกา	Seka	38150	2025-12-18 04:35:43.5	3802
380203	380203	ท่ากกแดง	Tha Kok Daeng	38150	2025-12-18 04:35:43.502	3802
380204	380204	ท่าสะอาด	Tha Sa-at	38150	2025-12-18 04:35:43.505	3802
380205	380205	น้ำจั้น	Nam Chan	38150	2025-12-18 04:35:43.507	3802
380206	380206	บ้านต้อง	Ban Tong	38150	2025-12-18 04:35:43.509	3802
380207	380207	ป่งไฮ	Pong Hai	38150	2025-12-18 04:35:43.512	3802
380208	380208	โสกก่าม	Sok Kam	38150	2025-12-18 04:35:43.514	3802
380209	380209	หนองทุ่ม	Nong Thum	38150	2025-12-18 04:35:43.517	3802
380301	380301	คำแก้ว	Kham Kaeo	38170	2025-12-18 04:35:43.519	3803
380302	380302	โซ่	So	38170	2025-12-18 04:35:43.521	3803
380303	380303	ถ้ำเจริญ	Tham Charoen	38170	2025-12-18 04:35:43.525	3803
380304	380304	บัวตูม	Bua Tum	38170	2025-12-18 04:35:43.527	3803
380305	380305	ศรีชมภู	Si Chomphu	38170	2025-12-18 04:35:43.53	3803
380306	380306	หนองพันทา	Nong Phan Tha	38170	2025-12-18 04:35:43.532	3803
380307	380307	เหล่าทอง	Lao Thong	38170	2025-12-18 04:35:43.534	3803
380401	380401	ดอนหญ้านาง	Don Ya Nang	38180	2025-12-18 04:35:43.536	3804
380402	380402	ป่าแฝก	Pa Faek	38180	2025-12-18 04:35:43.539	3804
380403	380403	พรเจริญ	Phon Charoen	38180	2025-12-18 04:35:43.541	3804
380404	380404	วังชมภู	Wang Chomphu	38180	2025-12-18 04:35:43.543	3804
380405	380405	ศรีชมภู	Si Chomphu	38180	2025-12-18 04:35:43.546	3804
380406	380406	ศรีสำราญ	Si Samran	38180	2025-12-18 04:35:43.548	3804
380407	380407	หนองหัวช้าง	Nong Hua Chang	38180	2025-12-18 04:35:43.551	3804
380501	380501	ชุมภูพร	Chumphu Phon	38210	2025-12-18 04:35:43.553	3805
380502	380502	นาสะแบง	Na Sabaeng	38210	2025-12-18 04:35:43.556	3805
380503	380503	นาสิงห์	Na Sing	38210	2025-12-18 04:35:43.558	3805
380504	380504	นาแสง	Na Saeng	38210	2025-12-18 04:35:43.562	3805
380505	380505	ศรีวิไล	Si Wilai	38210	2025-12-18 04:35:43.564	3805
380601	380601	ดงบัง	Dong Bang	38220	2025-12-18 04:35:43.567	3806
380602	380602	ท่าดอกคำ	Tha Dok Kham	38220	2025-12-18 04:35:43.569	3806
380603	380603	บึงโขงหลง	Bueng Khong Long	38220	2025-12-18 04:35:43.571	3806
380604	380604	โพธิ์หมากแข้ง	Pho Mak Khaeng	38220	2025-12-18 04:35:43.574	3806
380701	380701	นากั้ง	Na Kang	38190	2025-12-18 04:35:43.576	3807
380702	380702	นาดง	Na Dong	38190	2025-12-18 04:35:43.579	3807
380703	380703	โนนศิลา	Non Sila	38190	2025-12-18 04:35:43.581	3807
380704	380704	ปากคาด	Pak Khat	38190	2025-12-18 04:35:43.584	3807
380705	380705	ศรีวิไล	Sri Wi Lai	38190	2025-12-18 04:35:43.586	3807
380706	380706	หนองยอง	Nong Yong	38190	2025-12-18 04:35:43.588	3807
380801	380801	โคกกว้าง	Khok Kwang	38000	2025-12-18 04:35:43.591	3808
380802	380802	บุ่งคล้า	Bung Khla	38000	2025-12-18 04:35:43.593	3808
380803	380803	หนองเดิน	Nong Doen	38000	2025-12-18 04:35:43.596	3808
390101	390101	หนองบัว	Nong Bua	39000	2025-12-18 04:35:43.598	3901
390102	390102	หนองภัยศูนย์	Nong Phai Sun	39000	2025-12-18 04:35:43.601	3901
390103	390103	โพธิ์ชัย	Pho Chai	39000	2025-12-18 04:35:43.603	3901
390104	390104	หนองสวรรค์	Nong Sawan	39000	2025-12-18 04:35:43.605	3901
390105	390105	หัวนา	Hua Na	39000	2025-12-18 04:35:43.608	3901
390106	390106	บ้านขาม	Ban Kham	39000	2025-12-18 04:35:43.61	3901
390107	390107	นามะเฟือง	Na Mafueang	39000	2025-12-18 04:35:43.613	3901
390108	390108	บ้านพร้าว	Ban Phrao	39000	2025-12-18 04:35:43.615	3901
390109	390109	โนนขมิ้น	Non Khamin	39000	2025-12-18 04:35:43.618	3901
390110	390110	ลำภู	Lam Phu	39000	2025-12-18 04:35:43.62	3901
390111	390111	กุดจิก	Kut Chik	39000	2025-12-18 04:35:43.622	3901
390112	390112	โนนทัน	Non Than	39000	2025-12-18 04:35:43.625	3901
390113	390113	นาคำไฮ	Na Kham Hai	39000	2025-12-18 04:35:43.627	3901
390114	390114	ป่าไม้งาม	Pa Mai Ngam	39000	2025-12-18 04:35:43.631	3901
390115	390115	หนองหว้า	Nong Wa	39000	2025-12-18 04:35:43.633	3901
390201	390201	นากลาง	Na Klang	39170	2025-12-18 04:35:43.635	3902
390202	390202	ด่านช้าง	Dan Chang	39170	2025-12-18 04:35:43.637	3902
390205	390205	กุดดินจี่	Kut Din Chi	39350	2025-12-18 04:35:43.639	3902
390206	390206	ฝั่งแดง	Fang Daeng	39170	2025-12-18 04:35:43.641	3902
390207	390207	เก่ากลอย	Kao Kloi	39350	2025-12-18 04:35:43.643	3902
390209	390209	โนนเมือง	Non Mueang	39170	2025-12-18 04:35:43.645	3902
390210	390210	อุทัยสวรรค์	Uthai Sawan	39170	2025-12-18 04:35:43.646	3902
390211	390211	ดงสวรรค์	Dong Sawan	39350	2025-12-18 04:35:43.648	3902
390213	390213	กุดแห่	Kut Hae	39170	2025-12-18 04:35:43.651	3902
390301	390301	โนนสัง	Non Sang	39140	2025-12-18 04:35:43.653	3903
390302	390302	บ้านถิ่น	Ban Thin	39140	2025-12-18 04:35:43.655	3903
390303	390303	หนองเรือ	Nong Ruea	39140	2025-12-18 04:35:43.657	3903
390304	390304	กุดดู่	Kut Du	39140	2025-12-18 04:35:43.659	3903
390305	390305	บ้านค้อ	Ban Kho	39140	2025-12-18 04:35:43.661	3903
390306	390306	โนนเมือง	Non Mueang	39140	2025-12-18 04:35:43.664	3903
390307	390307	โคกใหญ่	Khok Yai	39140	2025-12-18 04:35:43.666	3903
390308	390308	โคกม่วง	Khok Muang	39140	2025-12-18 04:35:43.669	3903
390309	390309	นิคมพัฒนา	Nikhom Phatthana	39140	2025-12-18 04:35:43.671	3903
390310	390310	ปางกู่	Pang Ku	39140	2025-12-18 04:35:43.673	3903
390401	390401	เมืองใหม่	Mueang Mai	39180	2025-12-18 04:35:43.675	3904
390402	390402	ศรีบุญเรือง	Si Bun Rueang	39180	2025-12-18 04:35:43.678	3904
390403	390403	หนองบัวใต้	Nong Bua Tai	39180	2025-12-18 04:35:43.68	3904
390404	390404	กุดสะเทียน	Kut Sathian	39180	2025-12-18 04:35:43.683	3904
390405	390405	นากอก	Na Kok	39180	2025-12-18 04:35:43.685	3904
390406	390406	โนนสะอาด	Non Sa-at	39180	2025-12-18 04:35:43.687	3904
390407	390407	ยางหล่อ	Yang Lo	39180	2025-12-18 04:35:43.689	3904
390408	390408	โนนม่วง	Non Muang	39180	2025-12-18 04:35:43.691	3904
390409	390409	หนองกุงแก้ว	Nong Kung Kaeo	39180	2025-12-18 04:35:43.693	3904
390410	390410	หนองแก	Nong Kae	39180	2025-12-18 04:35:43.695	3904
390411	390411	ทรายทอง	Sai Thong	39180	2025-12-18 04:35:43.698	3904
390412	390412	หันนางาม	Han Na Ngam	39180	2025-12-18 04:35:43.7	3904
390501	390501	นาสี	Nasi	39270	2025-12-18 04:35:43.702	3905
390502	390502	บ้านโคก	Ban Khok	39270	2025-12-18 04:35:43.706	3905
390503	390503	นาดี	Na Di	39270	2025-12-18 04:35:43.709	3905
390504	390504	นาด่าน	Na Dan	39270	2025-12-18 04:35:43.711	3905
390505	390505	ดงมะไฟ	Dong Mafai	39270	2025-12-18 04:35:43.714	3905
390506	390506	สุวรรณคูหา	Suwannakhuha	39270	2025-12-18 04:35:43.716	3905
390507	390507	บุญทัน	Bun Than	39270	2025-12-18 04:35:43.718	3905
390508	390508	กุดผึ้ง	Kut Phueng	39270	2025-12-18 04:35:43.721	3905
390601	390601	นาเหล่า	Na Lao	39170	2025-12-18 04:35:43.723	3906
390602	390602	นาแก	Na Kae	39170	2025-12-18 04:35:43.725	3906
390603	390603	วังทอง	Wang Thong	39170	2025-12-18 04:35:43.727	3906
390604	390604	วังปลาป้อม	Wang Pla Pom	39170	2025-12-18 04:35:43.73	3906
390605	390605	เทพคีรี	Thep Khiri	39170	2025-12-18 04:35:43.732	3906
400101	400101	ในเมือง	Nai Mueang	40000	2025-12-18 04:35:43.735	4001
400102	400102	สำราญ	Samran	40000	2025-12-18 04:35:43.737	4001
400103	400103	โคกสี	Khok Si	40000	2025-12-18 04:35:43.74	4001
400104	400104	ท่าพระ	Tha Phra	40260	2025-12-18 04:35:43.743	4001
400105	400105	บ้านทุ่ม	Ban Thum	40000	2025-12-18 04:35:43.745	4001
103401	103401	สวนหลวง	Suan Luang	10250	2025-12-18 04:35:38.724	1034
400106	400106	เมืองเก่า	Mueang Kao	40000	2025-12-18 04:35:43.747	4001
400107	400107	พระลับ	Phra Lap	40000	2025-12-18 04:35:43.749	4001
400108	400108	สาวะถี	Sawathi	40000	2025-12-18 04:35:43.751	4001
400109	400109	บ้านหว้า	Ban Wa	40000	2025-12-18 04:35:43.754	4001
400110	400110	บ้านค้อ	Ban Kho	40000	2025-12-18 04:35:43.756	4001
400111	400111	แดงใหญ่	Daeng Yai	40000	2025-12-18 04:35:43.758	4001
400112	400112	ดอนช้าง	Don Chang	40000	2025-12-18 04:35:43.76	4001
400113	400113	ดอนหัน	Don Han	40260	2025-12-18 04:35:43.761	4001
400115	400115	บ้านเป็ด	Ban Pet	40000	2025-12-18 04:35:43.766	4001
400116	400116	หนองตูม	Nong Tum	40000	2025-12-18 04:35:43.767	4001
400117	400117	บึงเนียม	Bueng Niam	40000	2025-12-18 04:35:43.769	4001
400118	400118	โนนท่อน	Non Thon	40000	2025-12-18 04:35:43.771	4001
400201	400201	หนองบัว	Nong Bua	40270	2025-12-18 04:35:43.774	4002
400202	400202	ป่าหวายนั่ง	Pa Wai Nang	40270	2025-12-18 04:35:43.776	4002
400203	400203	โนนฆ้อง	Non Khong	40270	2025-12-18 04:35:43.778	4002
400204	400204	บ้านเหล่า	Ban Lao	40270	2025-12-18 04:35:43.78	4002
400205	400205	ป่ามะนาว	Pa Manao	40270	2025-12-18 04:35:43.782	4002
400206	400206	บ้านฝาง	Ban Fang	40270	2025-12-18 04:35:43.784	4002
400207	400207	โคกงาม	Khok Ngam	40270	2025-12-18 04:35:43.786	4002
400301	400301	พระยืน	Phra Yuen	40320	2025-12-18 04:35:43.788	4003
400302	400302	พระบุ	Phra Bu	40320	2025-12-18 04:35:43.79	4003
400303	400303	บ้านโต้น	Ban Ton	40320	2025-12-18 04:35:43.792	4003
400304	400304	หนองแวง	Nong Waeng	40320	2025-12-18 04:35:43.794	4003
400305	400305	ขามป้อม	Kham Pom	40320	2025-12-18 04:35:43.796	4003
400401	400401	หนองเรือ	Nong Ruea	40210	2025-12-18 04:35:43.798	4004
400402	400402	บ้านเม็ง	Ban Meng	40210	2025-12-18 04:35:43.801	4004
400403	400403	บ้านกง	Ban Kong	40240	2025-12-18 04:35:43.803	4004
400404	400404	ยางคำ	Yang Kham	40240	2025-12-18 04:35:43.805	4004
400405	400405	จระเข้	Chorakhe	40240	2025-12-18 04:35:43.807	4004
400406	400406	โนนทอง	Non Thong	40210	2025-12-18 04:35:43.81	4004
400407	400407	กุดกว้าง	Kut Kwang	40210	2025-12-18 04:35:43.813	4004
400408	400408	โนนทัน	Non Than	40210	2025-12-18 04:35:43.815	4004
400409	400409	โนนสะอาด	Non Sa-at	40210	2025-12-18 04:35:43.817	4004
400410	400410	บ้านผือ	Ban Phue	40240	2025-12-18 04:35:43.819	4004
400501	400501	ชุมแพ	Chum Phae	40130	2025-12-18 04:35:43.82	4005
400502	400502	โนนหัน	Non Han	40290	2025-12-18 04:35:43.822	4005
400503	400503	นาหนองทุ่ม	Na Nong Thum	40290	2025-12-18 04:35:43.824	4005
400504	400504	โนนอุดม	Non Udom	40130	2025-12-18 04:35:43.826	4005
400505	400505	ขัวเรียง	Khua Riang	40130	2025-12-18 04:35:43.828	4005
400506	400506	หนองไผ่	Nong Phai	40130	2025-12-18 04:35:43.83	4005
400507	400507	ไชยสอ	Chai So	40130	2025-12-18 04:35:43.832	4005
400508	400508	วังหินลาด	Wang Hin Lat	40130	2025-12-18 04:35:43.835	4005
400509	400509	นาเพียง	Na Phiang	40130	2025-12-18 04:35:43.837	4005
400510	400510	หนองเขียด	Nong Khiat	40290	2025-12-18 04:35:43.839	4005
400511	400511	หนองเสาเล้า	Nong Sao Lao	40130	2025-12-18 04:35:43.841	4005
400512	400512	โนนสะอาด	Non Sa-at	40290	2025-12-18 04:35:43.843	4005
400601	400601	สีชมพู	Si Chomphu	40220	2025-12-18 04:35:43.846	4006
400602	400602	ศรีสุข	Si Suk	40220	2025-12-18 04:35:43.848	4006
400603	400603	นาจาน	Na Chan	40220	2025-12-18 04:35:43.85	4006
400604	400604	วังเพิ่ม	Wang Phoem	40220	2025-12-18 04:35:43.852	4006
400605	400605	ซำยาง	Sam Yang	40220	2025-12-18 04:35:43.854	4006
400606	400606	หนองแดง	Nong Daeng	40220	2025-12-18 04:35:43.856	4006
400607	400607	ดงลาน	Dong Lan	40220	2025-12-18 04:35:43.858	4006
400608	400608	บริบูรณ์	Boribun	40220	2025-12-18 04:35:43.861	4006
400609	400609	บ้านใหม่	Ban Mai	40220	2025-12-18 04:35:43.863	4006
400610	400610	ภูห่าน	Phu Han	40220	2025-12-18 04:35:43.865	4006
400701	400701	น้ำพอง	Nam Phong	40140	2025-12-18 04:35:43.867	4007
400702	400702	วังชัย	Wang Chai	40140	2025-12-18 04:35:43.869	4007
400703	400703	หนองกุง	Nong Kung	40140	2025-12-18 04:35:43.871	4007
400704	400704	บัวใหญ่	Bua Yai	40140	2025-12-18 04:35:43.874	4007
400705	400705	สะอาด	Sa-at	40310	2025-12-18 04:35:43.876	4007
400706	400706	ม่วงหวาน	Muang Wan	40310	2025-12-18 04:35:43.878	4007
400707	400707	บ้านขาม	Ban Kham	40140	2025-12-18 04:35:43.88	4007
400708	400708	บัวเงิน	Bua Ngoen	40140	2025-12-18 04:35:43.883	4007
400709	400709	ทรายมูล	Sai Mun	40140	2025-12-18 04:35:43.885	4007
400710	400710	ท่ากระเสริม	Tha Krasoem	40140	2025-12-18 04:35:43.887	4007
400711	400711	พังทุย	Phang Thui	40140	2025-12-18 04:35:43.89	4007
400712	400712	กุดน้ำใส	Kut Nam Sai	40140	2025-12-18 04:35:43.892	4007
400801	400801	โคกสูง	Khok Sung	40250	2025-12-18 04:35:43.895	4008
400802	400802	บ้านดง	Ban Dong	40250	2025-12-18 04:35:43.897	4008
400803	400803	เขื่อนอุบลรัตน์	Khuean Ubolratana	40250	2025-12-18 04:35:43.899	4008
400804	400804	นาคำ	Na Kham	40250	2025-12-18 04:35:43.902	4008
400805	400805	ศรีสุขสำราญ	Si Suk Samran	40250	2025-12-18 04:35:43.904	4008
400806	400806	ทุ่งโป่ง	Thung Pong	40250	2025-12-18 04:35:43.906	4008
400901	400901	หนองโก	Nong Ko	40170	2025-12-18 04:35:43.909	4009
400902	400902	หนองกุงใหญ่	Nong Kung Yai	40170	2025-12-18 04:35:43.911	4009
400905	400905	ห้วยโจด	Huai Chot	40170	2025-12-18 04:35:43.914	4009
400906	400906	ห้วยยาง	Huai Yang	40170	2025-12-18 04:35:43.918	4009
400907	400907	บ้านฝาง	Ban Fang	40170	2025-12-18 04:35:43.921	4009
400909	400909	ดูนสาด	Dun Sat	40170	2025-12-18 04:35:43.923	4009
400910	400910	หนองโน	Nong No	40170	2025-12-18 04:35:43.926	4009
400911	400911	น้ำอ้อม	Nam Om	40170	2025-12-18 04:35:43.929	4009
400912	400912	หัวนาคำ	Hua Na Kham	40170	2025-12-18 04:35:43.931	4009
401001	401001	บ้านไผ่	Ban Phai	40110	2025-12-18 04:35:43.933	4010
401002	401002	ในเมือง	Nai Mueang	40110	2025-12-18 04:35:43.936	4010
401005	401005	เมืองเพีย	Mueang Phia	40110	2025-12-18 04:35:43.939	4010
401009	401009	บ้านลาน	Ban Lan	40110	2025-12-18 04:35:43.942	4010
401010	401010	แคนเหนือ	Khaen Nuea	40110	2025-12-18 04:35:43.944	4010
401011	401011	ภูเหล็ก	Phu Lek	40110	2025-12-18 04:35:43.947	4010
401013	401013	ป่าปอ	Pa Po	40110	2025-12-18 04:35:43.95	4010
401014	401014	หินตั้ง	Hin Tang	40110	2025-12-18 04:35:43.953	4010
401016	401016	หนองน้ำใส	Nong Nam Sai	40110	2025-12-18 04:35:43.956	4010
401017	401017	หัวหนอง	Hua Nong	40110	2025-12-18 04:35:43.958	4010
401101	401101	เปือยน้อย	Pueai Noi	40340	2025-12-18 04:35:43.961	4011
401102	401102	วังม่วง	Wang Muang	40340	2025-12-18 04:35:43.964	4011
401103	401103	ขามป้อม	Kham Pom	40340	2025-12-18 04:35:43.967	4011
401104	401104	สระแก้ว	Sa Kaeo	40340	2025-12-18 04:35:43.969	4011
401201	401201	เมืองพล	Mueang Phon	40120	2025-12-18 04:35:43.971	4012
401203	401203	โจดหนองแก	Chot Nong Kae	40120	2025-12-18 04:35:43.974	4012
401204	401204	เก่างิ้ว	Kao Ngio	40120	2025-12-18 04:35:43.977	4012
401205	401205	หนองมะเขือ	Nong Makhuea	40120	2025-12-18 04:35:43.98	4012
401206	401206	หนองแวงโสกพระ	Nong Waeng Sok Phra	40120	2025-12-18 04:35:43.983	4012
401207	401207	เพ็กใหญ่	Phek Yai	40120	2025-12-18 04:35:43.986	4012
401208	401208	โคกสง่า	Khok Sa-nga	40120	2025-12-18 04:35:43.987	4012
401209	401209	หนองแวงนางเบ้า	Nong Waeng Nang Bao	40120	2025-12-18 04:35:43.989	4012
401210	401210	ลอมคอม	Lom Khom	40120	2025-12-18 04:35:43.992	4012
401211	401211	โนนข่า	Non Kha	40120	2025-12-18 04:35:43.993	4012
401212	401212	โสกนกเต็น	Sok Nok Ten	40120	2025-12-18 04:35:43.995	4012
401213	401213	หัวทุ่ง	Hua Thung	40120	2025-12-18 04:35:43.997	4012
401301	401301	คอนฉิม	Khon Chim	40330	2025-12-18 04:35:43.999	4013
401302	401302	ใหม่นาเพียง	Mai Na Phiang	40330	2025-12-18 04:35:44	4013
401303	401303	โนนทอง	Non Thong	40330	2025-12-18 04:35:44.002	4013
401304	401304	แวงใหญ่	Waeng Yai	40330	2025-12-18 04:35:44.004	4013
401305	401305	โนนสะอาด	Non Sa-at	40330	2025-12-18 04:35:44.006	4013
401401	401401	แวงน้อย	Waeng Noi	40230	2025-12-18 04:35:44.008	4014
401402	401402	ก้านเหลือง	Kan Lueang	40230	2025-12-18 04:35:44.009	4014
401403	401403	ท่านางแนว	Tha Nang Naeo	40230	2025-12-18 04:35:44.011	4014
401404	401404	ละหานนา	Lahan Na	40230	2025-12-18 04:35:44.013	4014
401405	401405	ท่าวัด	Tha Wat	40230	2025-12-18 04:35:44.015	4014
401406	401406	ทางขวาง	Thang Khwang	40230	2025-12-18 04:35:44.016	4014
401501	401501	หนองสองห้อง	Nong Song Hong	40190	2025-12-18 04:35:44.018	4015
401502	401502	คึมชาด	Khuemchat	40190	2025-12-18 04:35:44.021	4015
401503	401503	โนนธาตุ	Non That	40190	2025-12-18 04:35:44.022	4015
401504	401504	ตะกั่วป่า	Takua Pa	40190	2025-12-18 04:35:44.024	4015
401505	401505	สำโรง	Samrong	40190	2025-12-18 04:35:44.025	4015
401506	401506	หนองเม็ก	Nong Mek	40190	2025-12-18 04:35:44.027	4015
401507	401507	ดอนดู่	Don Du	40190	2025-12-18 04:35:44.029	4015
401508	401508	ดงเค็ง	Dong Kheng	40190	2025-12-18 04:35:44.03	4015
401509	401509	หันโจด	Han Chot	40190	2025-12-18 04:35:44.032	4015
401510	401510	ดอนดั่ง	Don Dang	40190	2025-12-18 04:35:44.033	4015
401511	401511	วังหิน	Wang Hin	40190	2025-12-18 04:35:44.035	4015
401512	401512	หนองไผ่ล้อม	Nong Phai Lom	40190	2025-12-18 04:35:44.036	4015
401601	401601	บ้านเรือ	Ban Ruea	40150	2025-12-18 04:35:44.037	4016
401604	401604	หว้าทอง	Wa Thong	40150	2025-12-18 04:35:44.038	4016
401605	401605	กุดขอนแก่น	Kut Khon Kaen	40150	2025-12-18 04:35:44.04	4016
401606	401606	นาชุมแสง	Na Chum Saeng	40150	2025-12-18 04:35:44.041	4016
401607	401607	นาหว้า	Na Wa	40150	2025-12-18 04:35:44.043	4016
401610	401610	หนองกุงธนสาร	Nong Kung Thanasan	40150	2025-12-18 04:35:44.045	4016
401612	401612	หนองกุงเซิน	Nong Kung Soen	40150	2025-12-18 04:35:44.046	4016
401613	401613	สงเปือย	Song Pueai	40150	2025-12-18 04:35:44.048	4016
401614	401614	ทุ่งชมพู	Thung Chomphu	40150	2025-12-18 04:35:44.05	4016
401616	401616	ดินดำ	Din Dam	40150	2025-12-18 04:35:44.051	4016
401617	401617	ภูเวียง	Phu Wiang	40150	2025-12-18 04:35:44.053	4016
401701	401701	กุดเค้า	Kut Khao	40160	2025-12-18 04:35:44.054	4017
401702	401702	สวนหม่อน	Suan Mon	40160	2025-12-18 04:35:44.055	4017
401703	401703	หนองแปน	Nong Paen	40160	2025-12-18 04:35:44.056	4017
401704	401704	โพนเพ็ก	Phon Phek	40160	2025-12-18 04:35:44.059	4017
401705	401705	คำแคน	Kham Khaen	40160	2025-12-18 04:35:44.061	4017
401707	401707	นางาม	Na Ngam	40160	2025-12-18 04:35:44.065	4017
401710	401710	ท่าศาลา	Tha Sala	40160	2025-12-18 04:35:44.066	4017
401801	401801	ชนบท	Chonnabot	40180	2025-12-18 04:35:44.068	4018
401802	401802	กุดเพียขอม	Kut Phia Khom	40180	2025-12-18 04:35:44.07	4018
401803	401803	วังแสง	Wang Saeng	40180	2025-12-18 04:35:44.071	4018
401804	401804	ห้วยแก	Huai Kae	40180	2025-12-18 04:35:44.073	4018
401805	401805	บ้านแท่น	Ban Thaen	40180	2025-12-18 04:35:44.075	4018
401806	401806	ศรีบุญเรือง	Si Bun Rueang	40180	2025-12-18 04:35:44.077	4018
401807	401807	โนนพะยอม	Non Phayom	40180	2025-12-18 04:35:44.078	4018
401808	401808	ปอแดง	Po Daeng	40180	2025-12-18 04:35:44.08	4018
401901	401901	เขาสวนกวาง	Khao Suan Kwang	40280	2025-12-18 04:35:44.081	4019
401902	401902	ดงเมืองแอม	Dong Mueang Aem	40280	2025-12-18 04:35:44.083	4019
401903	401903	นางิ้ว	Na Ngio	40280	2025-12-18 04:35:44.084	4019
401904	401904	โนนสมบูรณ์	Non Sombun	40280	2025-12-18 04:35:44.085	4019
401905	401905	คำม่วง	Kham Muang	40280	2025-12-18 04:35:44.086	4019
402001	402001	โนนคอม	Non Khom	40350	2025-12-18 04:35:44.088	4020
402002	402002	นาฝาย	Na Fai	40350	2025-12-18 04:35:44.089	4020
402003	402003	ภูผาม่าน	Phu Pha Man	40350	2025-12-18 04:35:44.09	4020
402004	402004	วังสวาบ	Wang Sawap	40350	2025-12-18 04:35:44.092	4020
402005	402005	ห้วยม่วง	Huai Muang	40350	2025-12-18 04:35:44.093	4020
402101	402101	กระนวน	Kranuan	40170	2025-12-18 04:35:44.094	4021
402102	402102	คำแมด	Kham Maet	40170	2025-12-18 04:35:44.096	4021
402103	402103	บ้านโนน	Ban Non	40170	2025-12-18 04:35:44.097	4021
402104	402104	คูคำ	Khu Kham	40170	2025-12-18 04:35:44.098	4021
402105	402105	ห้วยเตย	Huai Toei	40170	2025-12-18 04:35:44.1	4021
402201	402201	บ้านโคก	Ban Khok	40160	2025-12-18 04:35:44.101	4022
402202	402202	โพธิ์ไชย	Pho Chai	40160	2025-12-18 04:35:44.103	4022
402203	402203	ซับสมบูรณ์	Sap Sombun	40160	2025-12-18 04:35:44.104	4022
402204	402204	นาแพง	Na Phaeng	40160	2025-12-18 04:35:44.106	4022
402301	402301	กุดธาตุ	Kut That	40150	2025-12-18 04:35:44.107	4023
402302	402302	บ้านโคก	Ban Khok	40150	2025-12-18 04:35:44.109	4023
402303	402303	ขนวน	Khanuan	40150	2025-12-18 04:35:44.11	4023
402401	402401	บ้านแฮด	Ban Haet	40110	2025-12-18 04:35:44.112	4024
402402	402402	โคกสำราญ	Khok Samran	40110	2025-12-18 04:35:44.113	4024
402403	402403	โนนสมบูรณ์	Non Sombun	40110	2025-12-18 04:35:44.115	4024
402404	402404	หนองแซง	Nong Saeng	40110	2025-12-18 04:35:44.116	4024
402501	402501	โนนศิลา	Non Sila	40110	2025-12-18 04:35:44.118	4025
402502	402502	หนองปลาหมอ	Nong Pla Mo	40110	2025-12-18 04:35:44.12	4025
402503	402503	บ้านหัน	Ban Han	40110	2025-12-18 04:35:44.122	4025
402504	402504	เปือยใหญ่	Pueai Yai	40110	2025-12-18 04:35:44.123	4025
402505	402505	โนนแดง	Non Daeng	40110	2025-12-18 04:35:44.124	4025
402901	402901	ในเมือง	Nai Mueang	40150	2025-12-18 04:35:44.126	4029
402902	402902	เมืองเก่าพัฒนา	Mueang Kao Phatthana	40150	2025-12-18 04:35:44.128	4029
402903	402903	เขาน้อย	Khao Noi	40150	2025-12-18 04:35:44.13	4029
410101	410101	หมากแข้ง	Mak Khaeng	41000	2025-12-18 04:35:44.131	4101
410102	410102	นิคมสงเคราะห์	Nikhom Songkhro	41000	2025-12-18 04:35:44.133	4101
410103	410103	บ้านขาว	Ban Khao	41000	2025-12-18 04:35:44.135	4101
410104	410104	หนองบัว	Nong Bua	41000	2025-12-18 04:35:44.137	4101
410105	410105	บ้านตาด	Ban Tat	41000	2025-12-18 04:35:44.138	4101
410106	410106	โนนสูง	Non Sung	41330	2025-12-18 04:35:44.139	4101
410107	410107	หมูม่น	Mu Mon	41000	2025-12-18 04:35:44.141	4101
410108	410108	เชียงยืน	Chiang Yuen	41000	2025-12-18 04:35:44.144	4101
410109	410109	หนองนาคำ	Nong Na Kham	41000	2025-12-18 04:35:44.148	4101
410110	410110	กุดสระ	Kut Sa	41000	2025-12-18 04:35:44.15	4101
410111	410111	นาดี	Na Di	41000	2025-12-18 04:35:44.152	4101
410112	410112	บ้านเลื่อม	Ban Lueam	41000	2025-12-18 04:35:44.154	4101
410113	410113	เชียงพิณ	Chiang Phin	41000	2025-12-18 04:35:44.156	4101
410114	410114	สามพร้าว	Sam Phrao	41000	2025-12-18 04:35:44.158	4101
410115	410115	หนองไฮ	Nong Hai	41000	2025-12-18 04:35:44.16	4101
410116	410116	นาข่า	Na Kha	41000	2025-12-18 04:35:44.162	4101
410117	410117	บ้านจั่น	Ban Chan	41000	2025-12-18 04:35:44.164	4101
410118	410118	หนองขอนกว้าง	Nong Khon Kwang	41000	2025-12-18 04:35:44.166	4101
410119	410119	โคกสะอาด	Khok Sa-at	41000	2025-12-18 04:35:44.168	4101
410120	410120	นากว้าง	Na Kwang	41000	2025-12-18 04:35:44.17	4101
410121	410121	หนองไผ่	Nong Phai	41330	2025-12-18 04:35:44.172	4101
410201	410201	กุดจับ	Kut Chap	41250	2025-12-18 04:35:44.173	4102
410202	410202	ปะโค	Pakho	41250	2025-12-18 04:35:44.175	4102
410203	410203	ขอนยูง	Khon Yung	41250	2025-12-18 04:35:44.178	4102
410204	410204	เชียงเพ็ง	Chiang Pheng	41250	2025-12-18 04:35:44.18	4102
410205	410205	สร้างก่อ	Sang Ko	41250	2025-12-18 04:35:44.182	4102
410206	410206	เมืองเพีย	Mueang Phia	41250	2025-12-18 04:35:44.184	4102
410207	410207	ตาลเลียน	Tan Lian	41250	2025-12-18 04:35:44.186	4102
410301	410301	หมากหญ้า	Mak Ya	41360	2025-12-18 04:35:44.187	4103
410302	410302	หนองอ้อ	Nong O	41220	2025-12-18 04:35:44.189	4103
410303	410303	อูบมุง	Up Mung	41220	2025-12-18 04:35:44.191	4103
410304	410304	กุดหมากไฟ	Kut Mak Fai	41220	2025-12-18 04:35:44.192	4103
410305	410305	น้ำพ่น	Nam Phon	41360	2025-12-18 04:35:44.194	4103
410306	410306	หนองบัวบาน	Nong Bua Ban	41360	2025-12-18 04:35:44.196	4103
410307	410307	โนนหวาย	Non Wai	41220	2025-12-18 04:35:44.197	4103
410308	410308	หนองวัวซอ	Nong Wua So	41360	2025-12-18 04:35:44.199	4103
410401	410401	ตูมใต้	Tum Tai	41110	2025-12-18 04:35:44.201	4104
410402	410402	พันดอน	Phan Don	41370	2025-12-18 04:35:44.204	4104
410403	410403	เวียงคำ	Wiang Kham	41110	2025-12-18 04:35:44.206	4104
410404	410404	แชแล	Chaelae	41110	2025-12-18 04:35:44.207	4104
410406	410406	เชียงแหว	Chiang Wae	41110	2025-12-18 04:35:44.21	4104
410407	410407	ห้วยเกิ้ง	Huai Koeng	41110	2025-12-18 04:35:44.211	4104
410409	410409	เสอเพลอ	Soephloe	41370	2025-12-18 04:35:44.213	4104
410410	410410	สีออ	Si O	41110	2025-12-18 04:35:44.215	4104
410411	410411	ปะโค	Pa Kho	41370	2025-12-18 04:35:44.217	4104
410413	410413	ผาสุก	Phasuk	41370	2025-12-18 04:35:44.219	4104
410414	410414	ท่าลี่	Tha Li	41110	2025-12-18 04:35:44.221	4104
410415	410415	กุมภวาปี	Kumphawapi	41110	2025-12-18 04:35:44.223	4104
410416	410416	หนองหว้า	Nong Wa	41110	2025-12-18 04:35:44.225	4104
410501	410501	โนนสะอาด	Non Sa-at	41240	2025-12-18 04:35:44.227	4105
410502	410502	บุ่งแก้ว	Bung Kaeo	41240	2025-12-18 04:35:44.229	4105
410503	410503	โพธิ์ศรีสำราญ	Pho Si Samran	41240	2025-12-18 04:35:44.231	4105
410504	410504	ทมนางาม	Thom Na Ngam	41240	2025-12-18 04:35:44.233	4105
410505	410505	หนองกุงศรี	Nong Kung Si	41240	2025-12-18 04:35:44.235	4105
410506	410506	โคกกลาง	Khok Klang	41240	2025-12-18 04:35:44.237	4105
410601	410601	หนองหาน	Nong Han	41130	2025-12-18 04:35:44.24	4106
410602	410602	หนองเม็ก	Nong Mek	41130	2025-12-18 04:35:44.242	4106
410605	410605	พังงู	Phang Ngu	41130	2025-12-18 04:35:44.244	4106
410606	410606	สะแบง	Sabaeng	41130	2025-12-18 04:35:44.246	4106
410607	410607	สร้อยพร้าว	Soi Phrao	41130	2025-12-18 04:35:44.248	4106
410609	410609	บ้านเชียง	Ban Chiang	41320	2025-12-18 04:35:44.25	4106
410610	410610	บ้านยา	Ban Ya	41320	2025-12-18 04:35:44.252	4106
410611	410611	โพนงาม	Phon Ngam	41130	2025-12-18 04:35:44.254	4106
410612	410612	ผักตบ	Phak Top	41130	2025-12-18 04:35:44.256	4106
410614	410614	หนองไผ่	Nong Phai	41130	2025-12-18 04:35:44.258	4106
410617	410617	ดอนหายโศก	Don Hai Sok	41130	2025-12-18 04:35:44.26	4106
410618	410618	หนองสระปลา	Nong Sa Pla	41320	2025-12-18 04:35:44.262	4106
410701	410701	ทุ่งฝน	Thung Fon	41310	2025-12-18 04:35:44.264	4107
410702	410702	ทุ่งใหญ่	Thung Yai	41310	2025-12-18 04:35:44.266	4107
410703	410703	นาชุมแสง	Na Chum Saeng	41310	2025-12-18 04:35:44.268	4107
410704	410704	นาทม	Na Thom	41310	2025-12-18 04:35:44.27	4107
410801	410801	ไชยวาน	Chai Wan	41290	2025-12-18 04:35:44.272	4108
410802	410802	หนองหลัก	Nong Lak	41290	2025-12-18 04:35:44.274	4108
410803	410803	คำเลาะ	Kham Lo	41290	2025-12-18 04:35:44.276	4108
410804	410804	โพนสูง	Phon Sung	41290	2025-12-18 04:35:44.278	4108
410901	410901	ศรีธาตุ	Si That	41230	2025-12-18 04:35:44.28	4109
410902	410902	จำปี	Champi	41230	2025-12-18 04:35:44.282	4109
410903	410903	บ้านโปร่ง	Ban Prong	41230	2025-12-18 04:35:44.284	4109
410904	410904	หัวนาคำ	Hua Na Kham	41230	2025-12-18 04:35:44.286	4109
410905	410905	หนองนกเขียน	Nong Nok Khian	41230	2025-12-18 04:35:44.288	4109
410906	410906	นายูง	Na Yung	41230	2025-12-18 04:35:44.29	4109
410907	410907	ตาดทอง	Tat Thong	41230	2025-12-18 04:35:44.292	4109
411001	411001	หนองกุงทับม้า	Nong Kung Thap Ma	41280	2025-12-18 04:35:44.294	4110
411003	411003	บะยาว	Ba Yao	41280	2025-12-18 04:35:44.299	4110
411004	411004	ผาสุก	Phasuk	41280	2025-12-18 04:35:44.301	4110
411005	411005	คำโคกสูง	Kham Khok Sung	41280	2025-12-18 04:35:44.303	4110
411006	411006	วังสามหมอ	Wang Sam Mo	41280	2025-12-18 04:35:44.305	4110
411101	411101	ศรีสุทโธ	Si Suttho	41190	2025-12-18 04:35:44.307	4111
411102	411102	บ้านดุง	Ban Dung	41190	2025-12-18 04:35:44.309	4111
411103	411103	ดงเย็น	Dong Yen	41190	2025-12-18 04:35:44.311	4111
411104	411104	โพนสูง	Phon Sung	41190	2025-12-18 04:35:44.313	4111
411105	411105	อ้อมกอ	Om Ko	41190	2025-12-18 04:35:44.315	4111
411106	411106	บ้านจันทน์	Ban Chan	41190	2025-12-18 04:35:44.317	4111
411107	411107	บ้านชัย	Ban Chai	41190	2025-12-18 04:35:44.319	4111
411108	411108	นาไหม	Na Mai	41190	2025-12-18 04:35:44.321	4111
411109	411109	ถ่อนนาลับ	Thon Na Lap	41190	2025-12-18 04:35:44.324	4111
411110	411110	วังทอง	Wang Thong	41190	2025-12-18 04:35:44.325	4111
411111	411111	บ้านม่วง	Ban Muang	41190	2025-12-18 04:35:44.328	4111
411112	411112	บ้านตาด	Ban Tat	41190	2025-12-18 04:35:44.33	4111
411113	411113	นาคำ	Na Kham	41190	2025-12-18 04:35:44.332	4111
411701	411701	บ้านผือ	Ban Phue	41160	2025-12-18 04:35:44.334	4117
411702	411702	หายโศก	Hai Sok	41160	2025-12-18 04:35:44.336	4117
411703	411703	เขือน้ำ	Khuea Nam	41160	2025-12-18 04:35:44.338	4117
411704	411704	คำบง	Kham Bong	41160	2025-12-18 04:35:44.34	4117
411705	411705	โนนทอง	Non Thong	41160	2025-12-18 04:35:44.342	4117
411706	411706	ข้าวสาร	Khao San	41160	2025-12-18 04:35:44.344	4117
411707	411707	จำปาโมง	Champa Mong	41160	2025-12-18 04:35:44.346	4117
411708	411708	กลางใหญ่	Klang Yai	41160	2025-12-18 04:35:44.348	4117
411709	411709	เมืองพาน	Mueang Phan	41160	2025-12-18 04:35:44.351	4117
411710	411710	คำด้วง	Kham Duang	41160	2025-12-18 04:35:44.353	4117
411711	411711	หนองหัวคู	Nong Hua Khu	41160	2025-12-18 04:35:44.355	4117
411712	411712	บ้านค้อ	Ban Kho	41160	2025-12-18 04:35:44.357	4117
411713	411713	หนองแวง	Nong Waeng	41160	2025-12-18 04:35:44.359	4117
411801	411801	นางัว	Na Ngua	41210	2025-12-18 04:35:44.361	4118
411802	411802	น้ำโสม	Nam Som	41210	2025-12-18 04:35:44.363	4118
411805	411805	หนองแวง	Nong Waeng	41210	2025-12-18 04:35:44.366	4118
411806	411806	บ้านหยวก	Ban Yuak	41210	2025-12-18 04:35:44.368	4118
411807	411807	โสมเยี่ยม	Som Yiam	41210	2025-12-18 04:35:44.37	4118
411810	411810	ศรีสำราญ	Si Samran	41210	2025-12-18 04:35:44.372	4118
411812	411812	สามัคคี	Samakkhi	41210	2025-12-18 04:35:44.374	4118
411901	411901	เพ็ญ	Phen	41150	2025-12-18 04:35:44.376	4119
411902	411902	บ้านธาตุ	Ban That	41150	2025-12-18 04:35:44.378	4119
411903	411903	นาพู่	Na Phu	41150	2025-12-18 04:35:44.38	4119
411904	411904	เชียงหวาง	Chiang Wang	41150	2025-12-18 04:35:44.382	4119
411905	411905	สุมเส้า	Sum Sao	41150	2025-12-18 04:35:44.384	4119
411906	411906	นาบัว	Na Bua	41150	2025-12-18 04:35:44.386	4119
411907	411907	บ้านเหล่า	Ban Lao	41150	2025-12-18 04:35:44.387	4119
411908	411908	จอมศรี	Chom Si	41150	2025-12-18 04:35:44.389	4119
411909	411909	เตาไห	Tao Hai	41150	2025-12-18 04:35:44.391	4119
411910	411910	โคกกลาง	Khok Klang	41150	2025-12-18 04:35:44.393	4119
411911	411911	สร้างแป้น	Sang Paen	41150	2025-12-18 04:35:44.395	4119
412001	412001	สร้างคอม	Sang Khom	41260	2025-12-18 04:35:44.398	4120
412002	412002	เชียงดา	Chiang Da	41260	2025-12-18 04:35:44.4	4120
412003	412003	บ้านยวด	Ban Yuat	41260	2025-12-18 04:35:44.402	4120
412004	412004	บ้านโคก	Ban Khok	41260	2025-12-18 04:35:44.404	4120
412005	412005	นาสะอาด	Na Sa-at	41260	2025-12-18 04:35:44.407	4120
412006	412006	บ้านหินโงม	Ban Hin Ngom	41260	2025-12-18 04:35:44.409	4120
412101	412101	หนองแสง	Nong Saeng	41340	2025-12-18 04:35:44.411	4121
412102	412102	แสงสว่าง	Saeng Sawang	41340	2025-12-18 04:35:44.413	4121
412103	412103	นาดี	Na Di	41340	2025-12-18 04:35:44.415	4121
412104	412104	ทับกุง	Thap Kung	41340	2025-12-18 04:35:44.418	4121
412201	412201	นายูง	Na Yung	41380	2025-12-18 04:35:44.42	4122
412202	412202	บ้านก้อง	Ban Kong	41380	2025-12-18 04:35:44.422	4122
412203	412203	นาแค	Na Khae	41380	2025-12-18 04:35:44.424	4122
412204	412204	โนนทอง	Non Thong	41380	2025-12-18 04:35:44.426	4122
412301	412301	บ้านแดง	Ban Daeng	41130	2025-12-18 04:35:44.429	4123
412302	412302	นาทราย	Na Sai	41130	2025-12-18 04:35:44.431	4123
412303	412303	ดอนกลอย	Don Kloi	41130	2025-12-18 04:35:44.433	4123
412401	412401	บ้านจีต	Ban Chit	41130	2025-12-18 04:35:44.435	4124
412402	412402	โนนทองอินทร์	Non Thong In	41130	2025-12-18 04:35:44.438	4124
412403	412403	ค้อใหญ่	Kho Yai	41130	2025-12-18 04:35:44.44	4124
412404	412404	คอนสาย	Khon Sai	41130	2025-12-18 04:35:44.442	4124
412501	412501	นาม่วง	Na Muang	41110	2025-12-18 04:35:44.444	4125
412502	412502	ห้วยสามพาด	Huai Sam Phat	41110	2025-12-18 04:35:44.446	4125
412503	412503	อุ่มจาน	Um Chan	41110	2025-12-18 04:35:44.448	4125
420101	420101	กุดป่อง	Kut Pong	42000	2025-12-18 04:35:44.45	4201
420102	420102	เมือง	Mueang	42000	2025-12-18 04:35:44.452	4201
420103	420103	นาอ้อ	Na O	42100	2025-12-18 04:35:44.455	4201
420104	420104	กกดู่	Kok Du	42000	2025-12-18 04:35:44.457	4201
420105	420105	น้ำหมาน	Nam Man	42000	2025-12-18 04:35:44.46	4201
420106	420106	เสี้ยว	Siao	42000	2025-12-18 04:35:44.462	4201
420107	420107	นาอาน	Na An	42000	2025-12-18 04:35:44.464	4201
420108	420108	นาโป่ง	Na Pong	42000	2025-12-18 04:35:44.467	4201
420109	420109	นาดินดำ	Na Din Dam	42000	2025-12-18 04:35:44.469	4201
420110	420110	น้ำสวย	Nam Suai	42000	2025-12-18 04:35:44.472	4201
420111	420111	ชัยพฤกษ์	Chaiyaphruek	42000	2025-12-18 04:35:44.474	4201
420112	420112	นาแขม	Na Khaem	42000	2025-12-18 04:35:44.477	4201
420113	420113	ศรีสองรัก	Si Song Rak	42100	2025-12-18 04:35:44.479	4201
420114	420114	กกทอง	Kok Thong	42000	2025-12-18 04:35:44.481	4201
420201	420201	นาด้วง	Na Duang	42210	2025-12-18 04:35:44.484	4202
420202	420202	นาดอกคำ	Na Dok Kham	42210	2025-12-18 04:35:44.486	4202
420203	420203	ท่าสะอาด	Tha Sa-at	42210	2025-12-18 04:35:44.489	4202
420204	420204	ท่าสวรรค์	Tha Sawan	42210	2025-12-18 04:35:44.492	4202
420301	420301	เชียงคาน	Chiang Khan	42110	2025-12-18 04:35:44.494	4203
420302	420302	ธาตุ	That	42110	2025-12-18 04:35:44.497	4203
420303	420303	นาซ่าว	Na Sao	42110	2025-12-18 04:35:44.499	4203
420304	420304	เขาแก้ว	Khao Kaeo	42110	2025-12-18 04:35:44.502	4203
420305	420305	ปากตม	Pak Tom	42110	2025-12-18 04:35:44.505	4203
420306	420306	บุฮม	Bu Hom	42110	2025-12-18 04:35:44.507	4203
420307	420307	จอมศรี	Chom Si	42110	2025-12-18 04:35:44.509	4203
420308	420308	หาดทรายขาว	Hat Sai Khao	42110	2025-12-18 04:35:44.511	4203
420401	420401	ปากชม	Pak Chom	42150	2025-12-18 04:35:44.514	4204
420402	420402	เชียงกลม	Chiang Klom	42150	2025-12-18 04:35:44.516	4204
420403	420403	หาดคัมภีร์	Hat Khamphi	42150	2025-12-18 04:35:44.518	4204
420404	420404	ห้วยบ่อซืน	Huai Bo Suen	42150	2025-12-18 04:35:44.52	4204
420405	420405	ห้วยพิชัย	Huai Phichai	42150	2025-12-18 04:35:44.524	4204
420406	420406	ชมเจริญ	Chom Charoen	42150	2025-12-18 04:35:44.526	4204
420501	420501	ด่านซ้าย	Dan Sai	42120	2025-12-18 04:35:44.528	4205
420502	420502	ปากหมัน	Pak Man	42120	2025-12-18 04:35:44.531	4205
420503	420503	นาดี	Na Di	42120	2025-12-18 04:35:44.533	4205
420504	420504	โคกงาม	Khok Ngam	42120	2025-12-18 04:35:44.536	4205
420505	420505	โพนสูง	Phon Sung	42120	2025-12-18 04:35:44.538	4205
420506	420506	อิปุ่ม	Ipum	42120	2025-12-18 04:35:44.54	4205
420507	420507	กกสะทอน	Kok Sathon	42120	2025-12-18 04:35:44.543	4205
420508	420508	โป่ง	Pong	42120	2025-12-18 04:35:44.545	4205
420509	420509	วังยาว	Wang Yao	42120	2025-12-18 04:35:44.547	4205
420510	420510	นาหอ	Na Ho	42120	2025-12-18 04:35:44.55	4205
420601	420601	นาแห้ว	Na Haeo	42170	2025-12-18 04:35:44.552	4206
420602	420602	แสงภา	Saeng Pha	42170	2025-12-18 04:35:44.555	4206
420603	420603	นาพึง	Na Phueng	42170	2025-12-18 04:35:44.558	4206
420604	420604	นามาลา	Na Ma La	42170	2025-12-18 04:35:44.561	4206
420605	420605	เหล่ากอหก	Lao Ko Hok	42170	2025-12-18 04:35:44.563	4206
420701	420701	หนองบัว	Nong Bua	42160	2025-12-18 04:35:44.565	4207
420702	420702	ท่าศาลา	Tha Sala	42160	2025-12-18 04:35:44.568	4207
420703	420703	ร่องจิก	Rong Chik	42160	2025-12-18 04:35:44.571	4207
420704	420704	ปลาบ่า	Pla Ba	42160	2025-12-18 04:35:44.573	4207
420705	420705	ลาดค่าง	Lat Khang	42160	2025-12-18 04:35:44.576	4207
420706	420706	สานตม	San Tom	42160	2025-12-18 04:35:44.579	4207
420801	420801	ท่าลี่	Tha Li	42140	2025-12-18 04:35:44.581	4208
420802	420802	หนองผือ	Nong Phue	42140	2025-12-18 04:35:44.584	4208
420804	420804	น้ำแคม	Nam Khaem	42140	2025-12-18 04:35:44.589	4208
420805	420805	โคกใหญ่	Khok Yai	42140	2025-12-18 04:35:44.591	4208
420806	420806	น้ำทูน	Nam Thun	42140	2025-12-18 04:35:44.594	4208
420901	420901	วังสะพุง	Wang Saphung	42130	2025-12-18 04:35:44.597	4209
420902	420902	ทรายขาว	Sai Khao	42130	2025-12-18 04:35:44.599	4209
420903	420903	หนองหญ้าปล้อง	Nong Ya Plong	42130	2025-12-18 04:35:44.602	4209
420904	420904	หนองงิ้ว	Nong Ngio	42130	2025-12-18 04:35:44.605	4209
420905	420905	ปากปวน	Pak Puan	42130	2025-12-18 04:35:44.607	4209
420906	420906	ผาน้อย	Pha Noi	42130	2025-12-18 04:35:44.61	4209
420910	420910	ผาบิ้ง	Pha Bing	42130	2025-12-18 04:35:44.613	4209
420911	420911	เขาหลวง	Khao Luang	42130	2025-12-18 04:35:44.615	4209
420912	420912	โคกขมิ้น	Khok Khamin	42130	2025-12-18 04:35:44.619	4209
420913	420913	ศรีสงคราม	Si Songkhram	42130	2025-12-18 04:35:44.621	4209
421001	421001	ศรีฐาน	Si Than	42180	2025-12-18 04:35:44.623	4210
421005	421005	ผานกเค้า	Pha Nok Khao	42180	2025-12-18 04:35:44.626	4210
421007	421007	ภูกระดึง	Phu Kradueng	42180	2025-12-18 04:35:44.628	4210
421010	421010	ห้วยส้ม	Huai Som	42180	2025-12-18 04:35:44.632	4210
421101	421101	ภูหอ	Phu Ho	42230	2025-12-18 04:35:44.635	4211
421102	421102	หนองคัน	Nong Khan	42230	2025-12-18 04:35:44.638	4211
421104	421104	ห้วยสีเสียด	Huai Sisiat	42230	2025-12-18 04:35:44.64	4211
421105	421105	เลยวังไสย์	Loei Wang Sai	42230	2025-12-18 04:35:44.643	4211
421106	421106	แก่งศรีภูมิ	Kaeng Si Phum	42230	2025-12-18 04:35:44.646	4211
421201	421201	ผาขาว	Pha Khao	42240	2025-12-18 04:35:44.648	4212
421202	421202	ท่าช้างคล้อง	Tha Chang Khlong	42240	2025-12-18 04:35:44.651	4212
421203	421203	โนนปอแดง	Non Po Daeng	42240	2025-12-18 04:35:44.654	4212
421204	421204	โนนป่าซาง	Non Pa Sang	42240	2025-12-18 04:35:44.657	4212
421205	421205	บ้านเพิ่ม	Ban Phoem	42240	2025-12-18 04:35:44.659	4212
421301	421301	เอราวัณ	Erawan	42220	2025-12-18 04:35:44.661	4213
440202	440202	วังแสง	Wang Saeng	44190	2025-12-18 04:35:44.899	4402
421302	421302	ผาอินทร์แปลง	Pha In Plaeng	42220	2025-12-18 04:35:44.664	4213
421303	421303	ผาสามยอด	Pha Sam Yot	42220	2025-12-18 04:35:44.667	4213
421304	421304	ทรัพย์ไพวัลย์	Sap Phaiwan	42220	2025-12-18 04:35:44.669	4213
421401	421401	หนองหิน	Nong Hin	42190	2025-12-18 04:35:44.672	4214
421402	421402	ตาดข่า	Tat Kha	42190	2025-12-18 04:35:44.675	4214
421403	421403	ปวนพุ	Puan Phu	42190	2025-12-18 04:35:44.678	4214
430101	430101	ในเมือง	Nai Mueang	43000	2025-12-18 04:35:44.68	4301
430102	430102	มีชัย	Mi Chai	43000	2025-12-18 04:35:44.683	4301
430103	430103	โพธิ์ชัย	Pho Chai	43000	2025-12-18 04:35:44.686	4301
430104	430104	กวนวัน	Kuan Wan	43000	2025-12-18 04:35:44.689	4301
430105	430105	เวียงคุก	Wiang Khuk	43000	2025-12-18 04:35:44.692	4301
430106	430106	วัดธาตุ	Wat That	43000	2025-12-18 04:35:44.694	4301
430107	430107	หาดคำ	Hat Kham	43000	2025-12-18 04:35:44.697	4301
430108	430108	หินโงม	Hin Ngom	43000	2025-12-18 04:35:44.7	4301
430109	430109	บ้านเดื่อ	Ban Duea	43000	2025-12-18 04:35:44.703	4301
430110	430110	ค่ายบกหวาน	Khai Bok Wan	43100	2025-12-18 04:35:44.706	4301
430111	430111	สองห้อง	Song Hong	43100	2025-12-18 04:35:44.709	4301
430113	430113	พระธาตุบังพวน	Phra That Bang Phuan	43100	2025-12-18 04:35:44.713	4301
430116	430116	หนองกอมเกาะ	Nong Kom Ko	43000	2025-12-18 04:35:44.715	4301
430117	430117	ปะโค	Pa Kho	43000	2025-12-18 04:35:44.718	4301
430118	430118	เมืองหมี	Mueang Mi	43000	2025-12-18 04:35:44.721	4301
430119	430119	สีกาย	Si Kai	43000	2025-12-18 04:35:44.724	4301
430201	430201	ท่าบ่อ	Tha Bo	43110	2025-12-18 04:35:44.727	4302
430202	430202	น้ำโมง	Nam Mong	43110	2025-12-18 04:35:44.73	4302
430203	430203	กองนาง	Kong Nang	43110	2025-12-18 04:35:44.733	4302
430204	430204	โคกคอน	Khok Khon	43110	2025-12-18 04:35:44.735	4302
430205	430205	บ้านเดื่อ	Ban Duea	43110	2025-12-18 04:35:44.739	4302
430206	430206	บ้านถ่อน	Ban Thon	43110	2025-12-18 04:35:44.741	4302
430207	430207	บ้านว่าน	Ban Wan	43110	2025-12-18 04:35:44.744	4302
430208	430208	นาข่า	Na Kha	43110	2025-12-18 04:35:44.747	4302
430209	430209	โพนสา	Phon Sa	43110	2025-12-18 04:35:44.75	4302
430210	430210	หนองนาง	Nong Nang	43110	2025-12-18 04:35:44.753	4302
430501	430501	จุมพล	Chumphon	43120	2025-12-18 04:35:44.755	4305
430502	430502	วัดหลวง	Wat Luang	43120	2025-12-18 04:35:44.758	4305
430503	430503	กุดบง	Kut Bong	43120	2025-12-18 04:35:44.761	4305
430504	430504	ชุมช้าง	Chum Chang	43120	2025-12-18 04:35:44.764	4305
430506	430506	ทุ่งหลวง	Thung Luang	43120	2025-12-18 04:35:44.767	4305
430507	430507	เหล่าต่างคำ	Lao Tang Kham	43120	2025-12-18 04:35:44.769	4305
430508	430508	นาหนัง	Na Nang	43120	2025-12-18 04:35:44.772	4305
430509	430509	เซิม	Soem	43120	2025-12-18 04:35:44.775	4305
430513	430513	บ้านโพธิ์	Ban Pho	43120	2025-12-18 04:35:44.778	4305
430521	430521	บ้านผือ	Ban Phue	43120	2025-12-18 04:35:44.781	4305
430522	430522	สร้างนางขาว	Sang Nang Khao	43120	2025-12-18 04:35:44.784	4305
430701	430701	พานพร้าว	Phan Phrao	43130	2025-12-18 04:35:44.787	4307
430703	430703	บ้านหม้อ	Ban Mo	43130	2025-12-18 04:35:44.789	4307
430704	430704	พระพุทธบาท	Phra Phutthabat	43130	2025-12-18 04:35:44.792	4307
430705	430705	หนองปลาปาก	Nong Pla Pak	43130	2025-12-18 04:35:44.795	4307
430801	430801	แก้งไก่	Kaeng Kai	43160	2025-12-18 04:35:44.797	4308
430802	430802	ผาตั้ง	Pha Tang	43160	2025-12-18 04:35:44.8	4308
430803	430803	บ้านม่วง	Ban Muang	43160	2025-12-18 04:35:44.803	4308
430804	430804	นางิ้ว	Na Ngio	43160	2025-12-18 04:35:44.807	4308
430805	430805	สังคม	Sangkhom	43160	2025-12-18 04:35:44.81	4308
431401	431401	สระใคร	Sakhrai	43100	2025-12-18 04:35:44.812	4314
431402	431402	คอกช้าง	Khok Chang	43100	2025-12-18 04:35:44.815	4314
431403	431403	บ้านฝาง	Ban Fang	43100	2025-12-18 04:35:44.818	4314
431501	431501	เฝ้าไร่	Fao Rai	43120	2025-12-18 04:35:44.821	4315
431502	431502	นาดี	Na Di	43120	2025-12-18 04:35:44.824	4315
431503	431503	หนองหลวง	Nong Luang	43120	2025-12-18 04:35:44.826	4315
431504	431504	วังหลวง	Wang Luang	43120	2025-12-18 04:35:44.829	4315
431505	431505	อุดมพร	Udom Phon	43120	2025-12-18 04:35:44.832	4315
431601	431601	รัตนวาปี	Rattanawapi	43120	2025-12-18 04:35:44.835	4316
431602	431602	นาทับไฮ	Na Thap Hai	43120	2025-12-18 04:35:44.838	4316
431603	431603	บ้านต้อน	Ban Ton	43120	2025-12-18 04:35:44.84	4316
431604	431604	พระบาทนาสิงห์	Phra Bat Na Sing	43120	2025-12-18 04:35:44.843	4316
431605	431605	โพนแพง	Phon Phaeng	43120	2025-12-18 04:35:44.846	4316
431701	431701	โพธิ์ตาก	Pho Tak	43130	2025-12-18 04:35:44.849	4317
431702	431702	โพนทอง	Phon Thong	43130	2025-12-18 04:35:44.852	4317
431703	431703	ด่านศรีสุข	Dan Si Suk	43130	2025-12-18 04:35:44.854	4317
440101	440101	ตลาด	Talat	44000	2025-12-18 04:35:44.857	4401
440102	440102	เขวา	Khwao	44000	2025-12-18 04:35:44.86	4401
440103	440103	ท่าตูม	Tha Tum	44000	2025-12-18 04:35:44.863	4401
320904	320904	ยาง	Yang	32110	2025-12-18 04:35:42.602	3209
440104	440104	แวงน่าง	Waeng Nang	44000	2025-12-18 04:35:44.866	4401
440105	440105	โคกก่อ	Khok Ko	44000	2025-12-18 04:35:44.869	4401
440106	440106	ดอนหว่าน	Don Wan	44000	2025-12-18 04:35:44.871	4401
440107	440107	เกิ้ง	Koeng	44000	2025-12-18 04:35:44.874	4401
440108	440108	แก่งเลิงจาน	Kaeng Loeng Chan	44000	2025-12-18 04:35:44.876	4401
440109	440109	ท่าสองคอน	Tha Song Khon	44000	2025-12-18 04:35:44.879	4401
440110	440110	ลาดพัฒนา	Lat Phatthana	44000	2025-12-18 04:35:44.882	4401
440111	440111	หนองปลิง	Nong Pling	44000	2025-12-18 04:35:44.884	4401
440112	440112	ห้วยแอ่ง	Huai Aeng	44000	2025-12-18 04:35:44.887	4401
440113	440113	หนองโน	Nong No	44000	2025-12-18 04:35:44.89	4401
440114	440114	บัวค้อ	Bua Kho	44000	2025-12-18 04:35:44.893	4401
440201	440201	แกดำ	Kae Dam	44190	2025-12-18 04:35:44.896	4402
440203	440203	มิตรภาพ	Mittraphap	44190	2025-12-18 04:35:44.901	4402
440204	440204	หนองกุง	Nong Kung	44190	2025-12-18 04:35:44.904	4402
440205	440205	โนนภิบาล	Non Phiban	44190	2025-12-18 04:35:44.907	4402
440301	440301	หัวขวาง	Hua Khwang	44140	2025-12-18 04:35:44.909	4403
440302	440302	ยางน้อย	Yang Noi	44140	2025-12-18 04:35:44.912	4403
440303	440303	วังยาว	Wang Yao	44140	2025-12-18 04:35:44.915	4403
440304	440304	เขวาไร่	Khwao Rai	44140	2025-12-18 04:35:44.918	4403
440305	440305	แพง	Phaeng	44140	2025-12-18 04:35:44.921	4403
440306	440306	แก้งแก	Kaeng Kae	44140	2025-12-18 04:35:44.923	4403
440307	440307	หนองเหล็ก	Nong Lek	44140	2025-12-18 04:35:44.926	4403
440308	440308	หนองบัว	Nong Bua	44140	2025-12-18 04:35:44.929	4403
440309	440309	เหล่า	Lao	44140	2025-12-18 04:35:44.932	4403
440310	440310	เขื่อน	Khuean	44140	2025-12-18 04:35:44.935	4403
440311	440311	หนองบอน	Nong Bua	44140	2025-12-18 04:35:44.938	4403
440312	440312	โพนงาม	Phon Ngam	44140	2025-12-18 04:35:44.941	4403
440313	440313	ยางท่าแจ้ง	Yang Tha Chaeng	44140	2025-12-18 04:35:44.943	4403
440314	440314	แห่ใต้	Hae Tai	44140	2025-12-18 04:35:44.946	4403
440315	440315	หนองกุงสวรรค์	Nong Kung Sawan	44140	2025-12-18 04:35:44.949	4403
440316	440316	เลิงใต้	Loeng Tai	44140	2025-12-18 04:35:44.952	4403
440317	440317	ดอนกลาง	Don Klang	44140	2025-12-18 04:35:44.955	4403
440401	440401	โคกพระ	Khok Phra	44150	2025-12-18 04:35:44.957	4404
440402	440402	คันธารราษฎร์	Khanthararat	44150	2025-12-18 04:35:44.96	4404
440403	440403	มะค่า	Makha	44150	2025-12-18 04:35:44.963	4404
440404	440404	ท่าขอนยาง	Tha Khon Yang	44150	2025-12-18 04:35:44.966	4404
440405	440405	นาสีนวน	Na Si Nuan	44150	2025-12-18 04:35:44.969	4404
440406	440406	ขามเรียง	Kham Riang	44150	2025-12-18 04:35:44.971	4404
440407	440407	เขวาใหญ่	Khwao Yai	44150	2025-12-18 04:35:44.974	4404
440408	440408	ศรีสุข	Si Suk	44150	2025-12-18 04:35:44.977	4404
440409	440409	กุดใส้จ่อ	Kut Sai Cho	44150	2025-12-18 04:35:44.98	4404
440410	440410	ขามเฒ่าพัฒนา	Kham Thao Phatthana	44150	2025-12-18 04:35:44.982	4404
440501	440501	เชียงยืน	Chiang Yuen	44160	2025-12-18 04:35:44.985	4405
440503	440503	หนองซอน	Nong Son	44160	2025-12-18 04:35:44.988	4405
440505	440505	ดอนเงิน	Don Ngoen	44160	2025-12-18 04:35:44.991	4405
440506	440506	กู่ทอง	Ku Thong	44160	2025-12-18 04:35:44.994	4405
440507	440507	นาทอง	Na Thong	44160	2025-12-18 04:35:44.997	4405
440508	440508	เสือเฒ่า	Suea Thao	44160	2025-12-18 04:35:45	4405
440511	440511	โพนทอง	Phon Thong	44160	2025-12-18 04:35:45.003	4405
440512	440512	เหล่าบัวบาน	Lao Bua Ban	44160	2025-12-18 04:35:45.006	4405
440601	440601	บรบือ	Borabue	44130	2025-12-18 04:35:45.008	4406
440602	440602	บ่อใหญ่	Bo Yai	44130	2025-12-18 04:35:45.011	4406
440604	440604	วังไชย	Wang Chai	44130	2025-12-18 04:35:45.013	4406
440605	440605	หนองม่วง	Nong Muang	44130	2025-12-18 04:35:45.016	4406
440606	440606	กำพี้	Kamphi	44130	2025-12-18 04:35:45.018	4406
440607	440607	โนนราษี	Non Rasi	44130	2025-12-18 04:35:45.021	4406
440608	440608	โนนแดง	Non Daeng	44130	2025-12-18 04:35:45.024	4406
440610	440610	หนองจิก	Nong Chik	44130	2025-12-18 04:35:45.027	4406
440611	440611	บัวมาศ	Bua Mat	44130	2025-12-18 04:35:45.031	4406
440613	440613	หนองคูขาด	Nong Khu Khat	44130	2025-12-18 04:35:45.034	4406
440615	440615	วังใหม่	Wang Mai	44130	2025-12-18 04:35:45.037	4406
440616	440616	ยาง	Yang	44130	2025-12-18 04:35:45.04	4406
440618	440618	หนองสิม	Nong Sim	44130	2025-12-18 04:35:45.043	4406
440619	440619	หนองโก	Nong Ko	44130	2025-12-18 04:35:45.046	4406
440620	440620	ดอนงัว	Don Ngua	44130	2025-12-18 04:35:45.049	4406
440701	440701	นาเชือก	Na Chueak	44170	2025-12-18 04:35:45.052	4407
440702	440702	สำโรง	Samrong	44170	2025-12-18 04:35:45.055	4407
440703	440703	หนองแดง	Nong Daeng	44170	2025-12-18 04:35:45.058	4407
440704	440704	เขวาไร่	Khwao Rai	44170	2025-12-18 04:35:45.061	4407
440705	440705	หนองโพธิ์	Nong Pho	44170	2025-12-18 04:35:45.064	4407
440706	440706	ปอพาน	Po Phan	44170	2025-12-18 04:35:45.067	4407
440707	440707	หนองเม็ก	Nong Mek	44170	2025-12-18 04:35:45.072	4407
440708	440708	หนองเรือ	Nong Ruea	44170	2025-12-18 04:35:45.076	4407
440709	440709	หนองกุง	Nong Kung	44170	2025-12-18 04:35:45.08	4407
440710	440710	สันป่าตอง	San Pa Ton	44170	2025-12-18 04:35:45.083	4407
440801	440801	ปะหลาน	Palan	44110	2025-12-18 04:35:45.086	4408
440802	440802	ก้ามปู	Kam Pu	44110	2025-12-18 04:35:45.089	4408
440803	440803	เวียงสะอาด	Wiang Sa-at	44110	2025-12-18 04:35:45.093	4408
440804	440804	เม็กดำ	Mek Dam	44110	2025-12-18 04:35:45.096	4408
440805	440805	นาสีนวล	Na Si Nuan	44110	2025-12-18 04:35:45.099	4408
440809	440809	ราษฎร์เจริญ	Rat Charoen	44110	2025-12-18 04:35:45.101	4408
440810	440810	หนองบัวแก้ว	Nong Bua Kaeo	44110	2025-12-18 04:35:45.104	4408
440812	440812	เมืองเตา	Mueang Tao	44110	2025-12-18 04:35:45.106	4408
440815	440815	ลานสะแก	Lan Sakae	44110	2025-12-18 04:35:45.109	4408
440816	440816	เวียงชัย	Wiang Chai	44110	2025-12-18 04:35:45.112	4408
440817	440817	หนองบัว	Nong Bua	44110	2025-12-18 04:35:45.115	4408
440818	440818	ราษฎร์พัฒนา	Rat Phatthana	44110	2025-12-18 04:35:45.118	4408
440819	440819	เมืองเสือ	Mueang Suea	44110	2025-12-18 04:35:45.121	4408
440820	440820	ภารแอ่น	Phan Aen	44110	2025-12-18 04:35:45.124	4408
440901	440901	หนองแสง	Nong Saeng	44120	2025-12-18 04:35:45.127	4409
440903	440903	เสือโก้ก	Suea Kok	44120	2025-12-18 04:35:45.133	4409
440904	440904	ดงใหญ่	Dong Yai	44120	2025-12-18 04:35:45.136	4409
440905	440905	โพธิ์ชัย	Pho Chai	44120	2025-12-18 04:35:45.139	4409
440906	440906	หัวเรือ	Hua Ruea	44120	2025-12-18 04:35:45.141	4409
440907	440907	แคน	Khaen	44120	2025-12-18 04:35:45.145	4409
440908	440908	งัวบา	Ngua Ba	44120	2025-12-18 04:35:45.148	4409
440909	440909	นาข่า	Na Kha	44120	2025-12-18 04:35:45.151	4409
440910	440910	บ้านหวาย	Ban Wai	44120	2025-12-18 04:35:45.153	4409
440911	440911	หนองไฮ	Nong Hai	44120	2025-12-18 04:35:45.156	4409
440912	440912	ประชาพัฒนา	Pracha Phatthana	44120	2025-12-18 04:35:45.159	4409
440913	440913	หนองทุ่ม	Nong Thum	44120	2025-12-18 04:35:45.162	4409
440914	440914	หนองแสน	Nong Saen	44120	2025-12-18 04:35:45.165	4409
440915	440915	โคกสีทองหลาง	Khok Si Thonglang	44120	2025-12-18 04:35:45.168	4409
441001	441001	นาดูน	Na Dun	44180	2025-12-18 04:35:45.171	4410
441002	441002	หนองไผ่	Nong Phai	44180	2025-12-18 04:35:45.174	4410
441003	441003	หนองคู	Nong Khu	44180	2025-12-18 04:35:45.176	4410
441004	441004	ดงบัง	Dong Bang	44180	2025-12-18 04:35:45.179	4410
441005	441005	ดงดวน	Dong Duan	44180	2025-12-18 04:35:45.182	4410
441006	441006	หัวดง	Hua Dong	44180	2025-12-18 04:35:45.186	4410
441007	441007	ดงยาง	Dong Yang	44180	2025-12-18 04:35:45.189	4410
441008	441008	กู่สันตรัตน์	Ku Santarat	44180	2025-12-18 04:35:45.193	4410
441009	441009	พระธาตุ	Phra That	44180	2025-12-18 04:35:45.196	4410
441101	441101	ยางสีสุราช	Yang Sisurat	44210	2025-12-18 04:35:45.199	4411
441102	441102	นาภู	Na Phu	44210	2025-12-18 04:35:45.201	4411
441103	441103	แวงดง	Waeng Dong	44210	2025-12-18 04:35:45.204	4411
441104	441104	บ้านกู่	Ban Ku	44210	2025-12-18 04:35:45.206	4411
441105	441105	ดงเมือง	Dong Mueang	44210	2025-12-18 04:35:45.209	4411
441106	441106	ขามเรียน	Sang Saeng	44210	2025-12-18 04:35:45.212	4411
441107	441107	หนองบัวสันตุ	Nong Bua Santu	44210	2025-12-18 04:35:45.215	4411
441201	441201	กุดรัง	Kud Rang	44130	2025-12-18 04:35:45.218	4412
441202	441202	นาโพธิ์	Na Pho	44130	2025-12-18 04:35:45.221	4412
441203	441203	เลิงแฝก	Loeng Faek	44130	2025-12-18 04:35:45.223	4412
441204	441204	หนองแวง	Nong Waeng	44130	2025-12-18 04:35:45.226	4412
441205	441205	ห้วยเตย	Huai Toei	44130	2025-12-18 04:35:45.229	4412
441301	441301	ชื่นชม	Chuen Chom	44160	2025-12-18 04:35:45.232	4413
441302	441302	กุดปลาดุก	Kut Pla Duk	44160	2025-12-18 04:35:45.234	4413
441303	441303	เหล่าดอกไม้	Lao Dok Mai	44160	2025-12-18 04:35:45.237	4413
441304	441304	หนองกุง	Nong Kung	44160	2025-12-18 04:35:45.24	4413
450101	450101	ในเมือง	Nai Mueang	45000	2025-12-18 04:35:45.243	4501
450102	450102	รอบเมือง	Rop Mueang	45000	2025-12-18 04:35:45.246	4501
450103	450103	เหนือเมือง	Nuea Mueang	45000	2025-12-18 04:35:45.249	4501
450104	450104	ขอนแก่น	Khon Kaen	45000	2025-12-18 04:35:45.252	4501
450105	450105	นาโพธิ์	Na Pho	45000	2025-12-18 04:35:45.255	4501
450106	450106	สะอาดสมบูรณ์	Sa-at Sombun	45000	2025-12-18 04:35:45.257	4501
450108	450108	สีแก้ว	Si Kaeo	45000	2025-12-18 04:35:45.26	4501
450109	450109	ปอภาร  (ปอพาน)	Po Phan	45000	2025-12-18 04:35:45.263	4501
450110	450110	โนนรัง	Non Rang	45000	2025-12-18 04:35:45.266	4501
450117	450117	หนองแก้ว	Nong Kaeo	45000	2025-12-18 04:35:45.269	4501
450118	450118	หนองแวง	Nong Waeng	45000	2025-12-18 04:35:45.273	4501
450120	450120	ดงลาน	Dong Lan	45000	2025-12-18 04:35:45.276	4501
450123	450123	แคนใหญ่	Khaen Yai	45000	2025-12-18 04:35:45.279	4501
450124	450124	โนนตาล	Non Tan	45000	2025-12-18 04:35:45.282	4501
450125	450125	เมืองทอง	Mueang Thong	45000	2025-12-18 04:35:45.285	4501
450201	450201	เกษตรวิสัย	Kaset Wisai	45150	2025-12-18 04:35:45.287	4502
450202	450202	เมืองบัว	Mueang Bua	45150	2025-12-18 04:35:45.29	4502
450203	450203	เหล่าหลวง	Lao Luang	45150	2025-12-18 04:35:45.294	4502
450204	450204	สิงห์โคก	Sing Khok	45150	2025-12-18 04:35:45.296	4502
450205	450205	ดงครั่งใหญ่	Dong Khrang Yai	45150	2025-12-18 04:35:45.299	4502
450206	450206	บ้านฝาง	Ban Fang	45150	2025-12-18 04:35:45.302	4502
450207	450207	หนองแวง	Nong Waeng	45150	2025-12-18 04:35:45.305	4502
450208	450208	กำแพง	Kamphaeng	45150	2025-12-18 04:35:45.308	4502
450209	450209	กู่กาสิงห์	Ku Ka Sing	45150	2025-12-18 04:35:45.311	4502
450210	450210	น้ำอ้อม	Nam Om	45150	2025-12-18 04:35:45.314	4502
450211	450211	โนนสว่าง	Non Sawang	45150	2025-12-18 04:35:45.317	4502
450212	450212	ทุ่งทอง	Thung Thong	45150	2025-12-18 04:35:45.32	4502
450213	450213	ดงครั่งน้อย	Dong Khrang Noi	45150	2025-12-18 04:35:45.322	4502
450301	450301	บัวแดง	Bua Daeng	45190	2025-12-18 04:35:45.325	4503
450302	450302	ดอกล้ำ	Dok Lam	45190	2025-12-18 04:35:45.328	4503
450303	450303	หนองแคน	Nong Khaen	45190	2025-12-18 04:35:45.331	4503
450304	450304	โพนสูง	Phon Sung	45190	2025-12-18 04:35:45.334	4503
450305	450305	โนนสวรรค์	Non Sawan	45190	2025-12-18 04:35:45.337	4503
450306	450306	สระบัว	Sa Bua	45190	2025-12-18 04:35:45.34	4503
450307	450307	โนนสง่า	Non Sa-nga	45190	2025-12-18 04:35:45.343	4503
330403	330403	เมือง	Mueang	33110	2025-12-18 04:35:42.727	3304
450308	450308	ขี้เหล็ก	Khilek	45190	2025-12-18 04:35:45.346	4503
450401	450401	หัวช้าง	Hua Chang	45180	2025-12-18 04:35:45.349	4504
450402	450402	หนองผือ	Nong Phue	45180	2025-12-18 04:35:45.352	4504
450403	450403	เมืองหงส์	Mueang Hong	45180	2025-12-18 04:35:45.355	4504
450404	450404	โคกล่าม	Khok Lam	45180	2025-12-18 04:35:45.358	4504
450406	450406	ดงแดง	Dong Daeng	45180	2025-12-18 04:35:45.363	4504
450407	450407	ดงกลาง	Dong Klang	45180	2025-12-18 04:35:45.366	4504
450408	450408	ป่าสังข์	Pa Sang	45180	2025-12-18 04:35:45.369	4504
450409	450409	อีง่อง	I Ngong	45180	2025-12-18 04:35:45.372	4504
450410	450410	ลิ้นฟ้า	Lin Fa	45180	2025-12-18 04:35:45.374	4504
450411	450411	ดู่น้อย	Du Noi	45180	2025-12-18 04:35:45.377	4504
450412	450412	ศรีโคตร	Si Khot	45180	2025-12-18 04:35:45.38	4504
450501	450501	นิเวศน์	Niwet	45170	2025-12-18 04:35:45.383	4505
450502	450502	ธงธานี	Thong Thani	45170	2025-12-18 04:35:45.385	4505
450503	450503	หนองไผ่	Nong Phai	45170	2025-12-18 04:35:45.388	4505
450504	450504	ธวัชบุรี	Thawat Buri	45170	2025-12-18 04:35:45.391	4505
450506	450506	อุ่มเม้า	Um Mao	45170	2025-12-18 04:35:45.394	4505
450507	450507	มะอึ	Ma-ue	45170	2025-12-18 04:35:45.397	4505
450510	450510	เขวาทุ่ง	Khwao Thung	45170	2025-12-18 04:35:45.4	4505
450515	450515	ไพศาล	Phaisan	45170	2025-12-18 04:35:45.403	4505
450517	450517	เมืองน้อย	Mueang Noi	45170	2025-12-18 04:35:45.406	4505
450520	450520	บึงนคร	Bueng Nakhon	45170	2025-12-18 04:35:45.409	4505
450522	450522	ราชธานี	Ratchathani	45170	2025-12-18 04:35:45.412	4505
450524	450524	หนองพอก	Nong Phok	45170	2025-12-18 04:35:45.415	4505
450601	450601	พนมไพร	Phanom Phrai	45140	2025-12-18 04:35:45.418	4506
450602	450602	แสนสุข	Saen Suk	45140	2025-12-18 04:35:45.421	4506
450603	450603	กุดน้ำใส	Kut Nam Sai	45140	2025-12-18 04:35:45.424	4506
450604	450604	หนองทัพไทย	Nong Thap Thai	45140	2025-12-18 04:35:45.427	4506
450605	450605	โพธิ์ใหญ่	Pho Yai	45140	2025-12-18 04:35:45.43	4506
450606	450606	วารีสวัสดิ์	Wari Sawat	45140	2025-12-18 04:35:45.435	4506
450607	450607	โคกสว่าง	Khok Sawang	45140	2025-12-18 04:35:45.437	4506
450611	450611	โพธิ์ชัย	Pho Chai	45140	2025-12-18 04:35:45.441	4506
450612	450612	นานวล	Na Nuan	45140	2025-12-18 04:35:45.444	4506
450613	450613	คำไฮ	Kham Hai	45140	2025-12-18 04:35:45.447	4506
450614	450614	สระแก้ว	Sa Kaeo	45140	2025-12-18 04:35:45.45	4506
450615	450615	ค้อใหญ่	Kho Yai	45140	2025-12-18 04:35:45.453	4506
450617	450617	ชานุวรรณ	Chanuwan	45140	2025-12-18 04:35:45.457	4506
450701	450701	แวง	Waeng	45110	2025-12-18 04:35:45.459	4507
450702	450702	โคกกกม่วง	Khok Kok Muang	45110	2025-12-18 04:35:45.462	4507
450703	450703	นาอุดม	Na Udom	45110	2025-12-18 04:35:45.465	4507
450704	450704	สว่าง	Sawang	45110	2025-12-18 04:35:45.468	4507
450705	450705	หนองใหญ่	Nong Yai	45110	2025-12-18 04:35:45.471	4507
450706	450706	โพธิ์ทอง	Pho Thong	45110	2025-12-18 04:35:45.474	4507
450707	450707	โนนชัยศรี	Non Chai Si	45110	2025-12-18 04:35:45.477	4507
450708	450708	โพธิ์ศรีสว่าง	Pho Si Sawang	45110	2025-12-18 04:35:45.48	4507
450709	450709	อุ่มเม่า	Um Mao	45110	2025-12-18 04:35:45.483	4507
450710	450710	คำนาดี	Kham Na Di	45110	2025-12-18 04:35:45.486	4507
450711	450711	พรมสวรรค์	Phrom Sawan	45110	2025-12-18 04:35:45.489	4507
450712	450712	สระนกแก้ว	Sa Nok Kaeo	45110	2025-12-18 04:35:45.493	4507
450713	450713	วังสามัคคี	Wang Samakkhi	45110	2025-12-18 04:35:45.496	4507
450714	450714	โคกสูง	Khok Sung	45110	2025-12-18 04:35:45.499	4507
450801	450801	ขามเปี้ย	Kham Pia	45230	2025-12-18 04:35:45.502	4508
450802	450802	เชียงใหม่	Chiang Mai	45230	2025-12-18 04:35:45.505	4508
450803	450803	บัวคำ	Bua Kham	45230	2025-12-18 04:35:45.508	4508
450804	450804	อัคคะคำ	Akkha Kham	45230	2025-12-18 04:35:45.511	4508
450805	450805	สะอาด	Sa-at	45230	2025-12-18 04:35:45.514	4508
450806	450806	คำพอุง	Kham Pha-ung	45230	2025-12-18 04:35:45.517	4508
450807	450807	หนองตาไก้	Nong Ta Kai	45230	2025-12-18 04:35:45.519	4508
450808	450808	ดอนโอง	Don Ong	45230	2025-12-18 04:35:45.522	4508
450809	450809	โพธิ์ศรี	Pho Si	45230	2025-12-18 04:35:45.526	4508
450901	450901	หนองพอก	Nong Phok	45210	2025-12-18 04:35:45.528	4509
450902	450902	บึงงาม	Bueng Ngam	45210	2025-12-18 04:35:45.531	4509
450903	450903	ภูเขาทอง	Phukhao Thong	45210	2025-12-18 04:35:45.533	4509
450904	450904	กกโพธิ์	Kok Pho	45210	2025-12-18 04:35:45.536	4509
450905	450905	โคกสว่าง	Khok Sawang	45210	2025-12-18 04:35:45.539	4509
450906	450906	หนองขุ่นใหญ่	Nong Khun Yai	45210	2025-12-18 04:35:45.542	4509
450907	450907	รอบเมือง	Rop Mueang	45210	2025-12-18 04:35:45.544	4509
450908	450908	ผาน้ำย้อย	Pha Nam Yoi	45210	2025-12-18 04:35:45.547	4509
450909	450909	ท่าสีดา	Ta See Da	45210	2025-12-18 04:35:45.549	4509
451001	451001	กลาง	Klang	45120	2025-12-18 04:35:45.551	4510
451002	451002	นางาม	Na Ngam	45120	2025-12-18 04:35:45.554	4510
451003	451003	เมืองไพร	Mueang Phrai	45120	2025-12-18 04:35:45.557	4510
451004	451004	นาแซง	Na Saeng	45120	2025-12-18 04:35:45.56	4510
451005	451005	นาเมือง	Na Mueang	45120	2025-12-18 04:35:45.563	4510
451006	451006	วังหลวง	Wang Luang	45120	2025-12-18 04:35:45.566	4510
451007	451007	ท่าม่วง	Tha Muang	45120	2025-12-18 04:35:45.568	4510
451008	451008	ขวาว	Khwao	45120	2025-12-18 04:35:45.571	4510
451009	451009	โพธิ์ทอง	Pho Thong	45120	2025-12-18 04:35:45.574	4510
451010	451010	ภูเงิน	Phu Ngoen	45120	2025-12-18 04:35:45.576	4510
451011	451011	เกาะแก้ว	Ko Kaeo	45120	2025-12-18 04:35:45.579	4510
451012	451012	นาเลิง	Na Loeng	45120	2025-12-18 04:35:45.582	4510
451013	451013	เหล่าน้อย	Lao Noi	45120	2025-12-18 04:35:45.585	4510
451014	451014	ศรีวิลัย	Si Wilai	45120	2025-12-18 04:35:45.588	4510
451015	451015	หนองหลวง	Nong Luang	45120	2025-12-18 04:35:45.591	4510
451016	451016	พรสวรรค์	Phon Sawan	45120	2025-12-18 04:35:45.594	4510
451017	451017	ขวัญเมือง	Khwan Mueang	45120	2025-12-18 04:35:45.597	4510
451018	451018	บึงเกลือ	Bueng Kluea	45120	2025-12-18 04:35:45.601	4510
451101	451101	สระคู	Sa Khu	45130	2025-12-18 04:35:45.603	4511
451102	451102	ดอกไม้	Dok Mai	45130	2025-12-18 04:35:45.606	4511
451103	451103	นาใหญ่	Na Yai	45130	2025-12-18 04:35:45.609	4511
451104	451104	หินกอง	Hin Kong	45130	2025-12-18 04:35:45.613	4511
451105	451105	เมืองทุ่ง	Mueang Thung	45130	2025-12-18 04:35:45.616	4511
451106	451106	หัวโทน	Hua Thon	45130	2025-12-18 04:35:45.619	4511
451107	451107	บ่อพันขัน	Bo Phan Khan	45130	2025-12-18 04:35:45.622	4511
451108	451108	ทุ่งหลวง	Thung Luang	45130	2025-12-18 04:35:45.626	4511
451109	451109	หัวช้าง	Hua Chang	45130	2025-12-18 04:35:45.629	4511
451110	451110	น้ำคำ	Nam Kham	45130	2025-12-18 04:35:45.633	4511
451111	451111	ห้วยหินลาด	Huai Hin Lat	45130	2025-12-18 04:35:45.635	4511
451112	451112	ช้างเผือก	Chang Phueak	45130	2025-12-18 04:35:45.638	4511
451113	451113	ทุ่งกุลา	Thung Kula	45130	2025-12-18 04:35:45.641	4511
451114	451114	ทุ่งศรีเมือง	Thung Si Mueang	45130	2025-12-18 04:35:45.644	4511
451115	451115	จำปาขัน	Champa Khan	45130	2025-12-18 04:35:45.647	4511
451201	451201	หนองผือ	Nong Phue	45220	2025-12-18 04:35:45.65	4512
451202	451202	หนองหิน	Nong Hin	45220	2025-12-18 04:35:45.654	4512
451203	451203	คูเมือง	Khu Mueang	45220	2025-12-18 04:35:45.657	4512
451204	451204	กกกุง	Kok Kung	45220	2025-12-18 04:35:45.66	4512
451205	451205	เมืองสรวง	Mueang Suang	45220	2025-12-18 04:35:45.663	4512
451301	451301	โพนทราย	Phon Sai	45240	2025-12-18 04:35:45.666	4513
451302	451302	สามขา	Sam Kha	45240	2025-12-18 04:35:45.668	4513
451303	451303	ศรีสว่าง	Si Sawang	45240	2025-12-18 04:35:45.671	4513
451304	451304	ยางคำ	Yang Kham	45240	2025-12-18 04:35:45.675	4513
451305	451305	ท่าหาดยาว	Tha Hat Yao	45240	2025-12-18 04:35:45.678	4513
451401	451401	อาจสามารถ	At Samat	45160	2025-12-18 04:35:45.681	4514
451402	451402	โพนเมือง	Phon Mueang	45160	2025-12-18 04:35:45.684	4514
451403	451403	บ้านแจ้ง	Ban Chaeng	45160	2025-12-18 04:35:45.687	4514
451404	451404	หน่อม	Nom	45160	2025-12-18 04:35:45.69	4514
451405	451405	หนองหมื่นถ่าน	Nong Muen Than	45160	2025-12-18 04:35:45.693	4514
451406	451406	หนองขาม	Nong Kham	45160	2025-12-18 04:35:45.695	4514
451407	451407	โหรา	Hora	45160	2025-12-18 04:35:45.699	4514
451408	451408	หนองบัว	Nong Bua	45160	2025-12-18 04:35:45.702	4514
451409	451409	ขี้เหล็ก	Khilek	45160	2025-12-18 04:35:45.705	4514
451410	451410	บ้านดู่	Ban Du	45160	2025-12-18 04:35:45.708	4514
451501	451501	เมยวดี	Moei Wadi	45250	2025-12-18 04:35:45.711	4515
451502	451502	ชุมพร	Chumphon	45250	2025-12-18 04:35:45.714	4515
451503	451503	บุ่งเลิศ	Bung Loet	45250	2025-12-18 04:35:45.717	4515
451504	451504	ชมสะอาด	Chom Sa-at	45250	2025-12-18 04:35:45.72	4515
451601	451601	โพธิ์ทอง	Pho Thong	45000	2025-12-18 04:35:45.723	4516
451602	451602	ศรีสมเด็จ	Si Somdet	45000	2025-12-18 04:35:45.726	4516
451603	451603	เมืองเปลือย	Mueang Plueai	45000	2025-12-18 04:35:45.729	4516
451604	451604	หนองใหญ่	Nong Yai	45000	2025-12-18 04:35:45.733	4516
451605	451605	สวนจิก	Suan Chik	45280	2025-12-18 04:35:45.736	4516
451606	451606	โพธิ์สัย	Pho Sai	45280	2025-12-18 04:35:45.739	4516
451607	451607	หนองแวงควง	Nong Waeng Khuang	45000	2025-12-18 04:35:45.742	4516
451608	451608	บ้านบาก	Ban Bak	45000	2025-12-18 04:35:45.745	4516
451701	451701	ดินดำ	Din Dam	45000	2025-12-18 04:35:45.748	4517
451702	451702	ปาฝา	Pa Fa	45000	2025-12-18 04:35:45.751	4517
451703	451703	ม่วงลาด	Muang Lat	45000	2025-12-18 04:35:45.754	4517
451704	451704	จังหาร	Changhan	45000	2025-12-18 04:35:45.758	4517
451705	451705	ดงสิงห์	Dong Sing	45000	2025-12-18 04:35:45.761	4517
451706	451706	ยางใหญ่	Yang Yai	45000	2025-12-18 04:35:45.764	4517
451707	451707	ผักแว่น	Phak Waen	45000	2025-12-18 04:35:45.767	4517
451708	451708	แสนชาติ	Saen Chat	45000	2025-12-18 04:35:45.77	4517
451801	451801	เชียงขวัญ	Chiang Khwan	45000	2025-12-18 04:35:45.773	4518
451802	451802	พลับพลา	Phlapphla	45170	2025-12-18 04:35:45.776	4518
451803	451803	พระธาตุ	Phra That	45000	2025-12-18 04:35:45.779	4518
451804	451804	พระเจ้า	Phra Chao	45000	2025-12-18 04:35:45.781	4518
451805	451805	หมูม้น	Mu Mon	45170	2025-12-18 04:35:45.784	4518
451806	451806	บ้านเขือง	Ban Khueang	45000	2025-12-18 04:35:45.787	4518
451901	451901	หนองฮี	Nong Hi	45140	2025-12-18 04:35:45.79	4519
451902	451902	สาวแห	Sao Hae	45140	2025-12-18 04:35:45.793	4519
451903	451903	ดูกอึ่ง	Duk Ueng	45140	2025-12-18 04:35:45.796	4519
451904	451904	เด่นราษฎร์	Den Rat	45140	2025-12-18 04:35:45.799	4519
452001	452001	ทุ่งเขาหลวง	Thung Khao Luang	45170	2025-12-18 04:35:45.801	4520
452002	452002	เทอดไทย	Thoet Thai	45170	2025-12-18 04:35:45.804	4520
452003	452003	บึงงาม	Bueng Ngam	45170	2025-12-18 04:35:45.807	4520
452004	452004	มะบ้า	Maba	45170	2025-12-18 04:35:45.81	4520
452005	452005	เหล่า	Lao	45170	2025-12-18 04:35:45.813	4520
460101	460101	กาฬสินธุ์	Kalasin	46000	2025-12-18 04:35:45.815	4601
460102	460102	เหนือ	Nuea	46000	2025-12-18 04:35:45.818	4601
460103	460103	หลุบ	Lup	46000	2025-12-18 04:35:45.822	4601
460104	460104	ไผ่	Phai	46000	2025-12-18 04:35:45.825	4601
460105	460105	ลำปาว	Lam Pao	46000	2025-12-18 04:35:45.828	4601
460106	460106	ลำพาน	Lam Phan	46000	2025-12-18 04:35:45.831	4601
460107	460107	เชียงเครือ	Chiang Khruea	46000	2025-12-18 04:35:45.834	4601
331302	331302	บก	Bok	33250	2025-12-18 04:35:42.841	3313
460108	460108	บึงวิชัย	Bueng Wichai	46000	2025-12-18 04:35:45.837	4601
460109	460109	ห้วยโพธิ์	Huai Pho	46000	2025-12-18 04:35:45.839	4601
460111	460111	ภูปอ	Phu Po	46000	2025-12-18 04:35:45.842	4601
460113	460113	ภูดิน	Phu Din	46000	2025-12-18 04:35:45.846	4601
460115	460115	หนองกุง	Nong Kung	46000	2025-12-18 04:35:45.849	4601
460116	460116	กลางหมื่น	Klang Muen	46000	2025-12-18 04:35:45.852	4601
460117	460117	ขมิ้น	Khamin	46000	2025-12-18 04:35:45.855	4601
460119	460119	โพนทอง	Phon Thong	46000	2025-12-18 04:35:45.857	4601
460120	460120	นาจารย์	Na Chan	46000	2025-12-18 04:35:45.86	4601
460121	460121	ลำคลอง	Lam Khlong	46000	2025-12-18 04:35:45.862	4601
460201	460201	นามน	Na Mon	46230	2025-12-18 04:35:45.866	4602
460202	460202	ยอดแกง	Yot Kaeng	46230	2025-12-18 04:35:45.868	4602
460203	460203	สงเปลือย	Song Plueai	46230	2025-12-18 04:35:45.871	4602
460204	460204	หลักเหลี่ยม	Lak Liam	46230	2025-12-18 04:35:45.874	4602
460205	460205	หนองบัว	Nong Bua	46230	2025-12-18 04:35:45.877	4602
460301	460301	กมลาไสย	Kamalasai	46130	2025-12-18 04:35:45.879	4603
460302	460302	หลักเมือง	Lak Mueang	46130	2025-12-18 04:35:45.882	4603
460303	460303	โพนงาม	Phon Ngam	46130	2025-12-18 04:35:45.884	4603
460304	460304	ดงลิง	Dong Ling	46130	2025-12-18 04:35:45.887	4603
460305	460305	ธัญญา	Thanya	46130	2025-12-18 04:35:45.89	4603
460308	460308	หนองแปน	Nong Paen	46130	2025-12-18 04:35:45.893	4603
460310	460310	เจ้าท่า	Chao Tha	46130	2025-12-18 04:35:45.896	4603
460311	460311	โคกสมบูรณ์	Khok Sombun	46130	2025-12-18 04:35:45.898	4603
460401	460401	ร่องคำ	Rong Kham	46210	2025-12-18 04:35:45.901	4604
460402	460402	สามัคคี	Samakkhi	46210	2025-12-18 04:35:45.904	4604
460403	460403	เหล่าอ้อย	Lao Oi	46210	2025-12-18 04:35:45.907	4604
460501	460501	บัวขาว	Bua Khao	46110	2025-12-18 04:35:45.909	4605
460502	460502	แจนแลน	Chaen Laen	46110	2025-12-18 04:35:45.912	4605
460503	460503	เหล่าใหญ่	Lao Yai	46110	2025-12-18 04:35:45.915	4605
460504	460504	จุมจัง	Chum Chang	46110	2025-12-18 04:35:45.918	4605
460505	460505	เหล่าไฮงาม	Lao Hai Ngam	46110	2025-12-18 04:35:45.92	4605
460506	460506	กุดหว้า	Kut Wa	46110	2025-12-18 04:35:45.923	4605
460507	460507	สามขา	Sam Kha	46110	2025-12-18 04:35:45.925	4605
460508	460508	นาขาม	Na Kham	46110	2025-12-18 04:35:45.928	4605
460509	460509	หนองห้าง	Nong Hang	46110	2025-12-18 04:35:45.931	4605
460510	460510	นาโก	Na Ko	46110	2025-12-18 04:35:45.934	4605
460511	460511	สมสะอาด	Som Sa-at	46110	2025-12-18 04:35:45.938	4605
460512	460512	กุดค้าว	Kut Khao	46110	2025-12-18 04:35:45.941	4605
460601	460601	คุ้มเก่า	Khum Kao	46160	2025-12-18 04:35:45.944	4606
460602	460602	สงเปลือย	Song Plueai	46160	2025-12-18 04:35:45.947	4606
460603	460603	หนองผือ	Nong Phue	46160	2025-12-18 04:35:45.95	4606
460606	460606	กุดสิมคุ้มใหม่	Kut Sim Khum Mai	46160	2025-12-18 04:35:45.953	4606
460608	460608	สระพังทอง	Saphang Thong	46160	2025-12-18 04:35:45.956	4606
460611	460611	กุดปลาค้าว	Kut Pla Khao	46160	2025-12-18 04:35:45.96	4606
460701	460701	ยางตลาด	Yang Talat	46120	2025-12-18 04:35:45.963	4607
460702	460702	หัวงัว	Hua Ngua	46120	2025-12-18 04:35:45.966	4607
460703	460703	อุ่มเม่า	Um Mao	46120	2025-12-18 04:35:45.97	4607
460704	460704	บัวบาน	Bua Ban	46120	2025-12-18 04:35:45.972	4607
460705	460705	เว่อ	Woe	46120	2025-12-18 04:35:45.975	4607
460706	460706	อิตื้อ	Itue	46120	2025-12-18 04:35:45.978	4607
460707	460707	หัวนาคำ	Hua Na Kham	46120	2025-12-18 04:35:45.981	4607
460708	460708	หนองอิเฒ่า	Nong I Thao	46120	2025-12-18 04:35:45.984	4607
460709	460709	ดอนสมบูรณ์	Don Sombun	46120	2025-12-18 04:35:45.987	4607
460710	460710	นาเชือก	Na Chueak	46120	2025-12-18 04:35:45.99	4607
460711	460711	คลองขาม	Khlong Kham	46120	2025-12-18 04:35:45.993	4607
460712	460712	เขาพระนอน	Khao Phra Non	46120	2025-12-18 04:35:45.997	4607
460713	460713	นาดี	Na Di	46120	2025-12-18 04:35:45.999	4607
460714	460714	โนนสูง	Non Sung	46120	2025-12-18 04:35:46.003	4607
460715	460715	หนองตอกแป้น	Nong Tok Paen	46120	2025-12-18 04:35:46.006	4607
460801	460801	ห้วยเม็ก	Huai Mek	46170	2025-12-18 04:35:46.009	4608
460802	460802	คำใหญ่	Kham Yai	46170	2025-12-18 04:35:46.012	4608
460803	460803	กุดโดน	Kut Don	46170	2025-12-18 04:35:46.014	4608
460804	460804	บึงนาเรียง	Bueng Na Riang	46170	2025-12-18 04:35:46.017	4608
460805	460805	หัวหิน	Hua Hin	46170	2025-12-18 04:35:46.019	4608
460806	460806	พิมูล	Phimun	46170	2025-12-18 04:35:46.021	4608
460807	460807	คำเหมือดแก้ว	Kham Mueat Kaeo	46170	2025-12-18 04:35:46.023	4608
460808	460808	โนนสะอาด	Non Sa-at	46170	2025-12-18 04:35:46.026	4608
460809	460809	ทรายทอง	Sai Thong	46170	2025-12-18 04:35:46.028	4608
460901	460901	ภูสิงห์	Phu Sing	46140	2025-12-18 04:35:46.03	4609
460902	460902	สหัสขันธ์	Sahatsakhan	46140	2025-12-18 04:35:46.033	4609
460903	460903	นามะเขือ	Na Makhuea	46140	2025-12-18 04:35:46.035	4609
460904	460904	โนนศิลา	Non Sila	46140	2025-12-18 04:35:46.038	4609
460905	460905	นิคม	Nikhom	46140	2025-12-18 04:35:46.04	4609
460906	460906	โนนแหลมทอง	Non Laem Thong	46140	2025-12-18 04:35:46.042	4609
460907	460907	โนนบุรี	Non Buri	46140	2025-12-18 04:35:46.045	4609
460908	460908	โนนน้ำเกลี้ยง	Non Nam Kliang	46140	2025-12-18 04:35:46.047	4609
461001	461001	ทุ่งคลอง	Thung Khlong	46180	2025-12-18 04:35:46.049	4610
461002	461002	โพน	Phon	46180	2025-12-18 04:35:46.052	4610
461005	461005	ดินจี่	Din Chi	46180	2025-12-18 04:35:46.054	4610
461006	461006	นาบอน	Na Bon	46180	2025-12-18 04:35:46.057	4610
461007	461007	นาทัน	Na Than	46180	2025-12-18 04:35:46.059	4610
461009	461009	เนินยาง	Noen Yang	46180	2025-12-18 04:35:46.062	4610
461101	461101	ท่าคันโท	Tha Khantho	46190	2025-12-18 04:35:46.065	4611
461102	461102	กุงเก่า	Kung Kao	46190	2025-12-18 04:35:46.068	4611
461103	461103	ยางอู้ม	Yang Um	46190	2025-12-18 04:35:46.071	4611
461104	461104	กุดจิก	Kut Chik	46190	2025-12-18 04:35:46.074	4611
461105	461105	นาตาล	Na Tan	46190	2025-12-18 04:35:46.077	4611
461106	461106	ดงสมบูรณ์	Dong Sombun	46190	2025-12-18 04:35:46.08	4611
461201	461201	หนองกุงศรี	Nong Kung Si	46220	2025-12-18 04:35:46.084	4612
461202	461202	หนองบัว	Nong Bua	46220	2025-12-18 04:35:46.087	4612
461203	461203	โคกเครือ	Khok Khruea	46220	2025-12-18 04:35:46.09	4612
461204	461204	หนองสรวง	Nong Suang	46220	2025-12-18 04:35:46.093	4612
461205	461205	เสาเล้า	Sao Lao	46220	2025-12-18 04:35:46.096	4612
461206	461206	หนองใหญ่	Nong Yai	46220	2025-12-18 04:35:46.1	4612
461207	461207	ดงมูล	Dong Mun	46220	2025-12-18 04:35:46.103	4612
461208	461208	ลำหนองแสน	Lam Nong Saen	46220	2025-12-18 04:35:46.106	4612
461209	461209	หนองหิน	Nong Hin	46220	2025-12-18 04:35:46.109	4612
461301	461301	สมเด็จ	Somdet	46150	2025-12-18 04:35:46.112	4613
461302	461302	หนองแวง	Nong Waeng	46150	2025-12-18 04:35:46.114	4613
461303	461303	แซงบาดาล	Saeng Badan	46150	2025-12-18 04:35:46.117	4613
461304	461304	มหาไชย	Maha Chai	46150	2025-12-18 04:35:46.12	4613
461305	461305	หมูม่น	Mu Mon	46150	2025-12-18 04:35:46.123	4613
461306	461306	ผาเสวย	Pha Sawoei	46150	2025-12-18 04:35:46.126	4613
461307	461307	ศรีสมเด็จ	Si Somdet	46150	2025-12-18 04:35:46.129	4613
461308	461308	ลำห้วยหลัว	Lam Huai Lua	46150	2025-12-18 04:35:46.132	4613
461401	461401	คำบง	Kham Bong	46240	2025-12-18 04:35:46.135	4614
461402	461402	ไค้นุ่น	Khai Nun	46240	2025-12-18 04:35:46.138	4614
461403	461403	นิคมห้วยผึ้ง	Nikhom Huai Phueng	46240	2025-12-18 04:35:46.141	4614
461404	461404	หนองอีบุตร	Nong I But	46240	2025-12-18 04:35:46.145	4614
461501	461501	สำราญ	Samran	46180	2025-12-18 04:35:46.148	4615
461502	461502	สำราญใต้	Samran Tai	46180	2025-12-18 04:35:46.151	4615
461503	461503	คำสร้างเที่ยง	Kham Sang Thiang	46180	2025-12-18 04:35:46.154	4615
461504	461504	หนองช้าง	Nong Chang	46180	2025-12-18 04:35:46.157	4615
461601	461601	นาคู	Na Khu	46160	2025-12-18 04:35:46.16	4616
461602	461602	สายนาวัง	Sai Na Wang	46160	2025-12-18 04:35:46.163	4616
461603	461603	โนนนาจาน	Non Na Chan	46160	2025-12-18 04:35:46.166	4616
461604	461604	บ่อแก้ว	Bo Kaeo	46160	2025-12-18 04:35:46.169	4616
461605	461605	ภูแล่นช้าง	Phu Laen Chang	46160	2025-12-18 04:35:46.172	4616
461701	461701	ดอนจาน	Don Chan	46000	2025-12-18 04:35:46.175	4617
461702	461702	สะอาดไชยศรี	Sa-at Chai Si	46000	2025-12-18 04:35:46.179	4617
461703	461703	ดงพยุง	Dong Phayung	46000	2025-12-18 04:35:46.182	4617
461704	461704	ม่วงนา	Muang Na	46000	2025-12-18 04:35:46.185	4617
461705	461705	นาจำปา	Na Champa	46000	2025-12-18 04:35:46.188	4617
461801	461801	ฆ้องชัยพัฒนา	Khong Chai Phatthana	46130	2025-12-18 04:35:46.191	4618
461802	461802	เหล่ากลาง	Lao Klang	46130	2025-12-18 04:35:46.194	4618
461803	461803	โคกสะอาด	Khok Sa-at	46130	2025-12-18 04:35:46.197	4618
461804	461804	โนนศิลาเลิง	Non Sila Loeng	46130	2025-12-18 04:35:46.2	4618
461805	461805	ลำชี	Lam Chi	46130	2025-12-18 04:35:46.203	4618
470101	470101	ธาตุเชิงชุม	That Choeng Chum	47000	2025-12-18 04:35:46.206	4701
470102	470102	ขมิ้น	Khamin	47220	2025-12-18 04:35:46.209	4701
470103	470103	งิ้วด่อน	Ngio Don	47000	2025-12-18 04:35:46.211	4701
470104	470104	โนนหอม	Non Hom	47000	2025-12-18 04:35:46.214	4701
470106	470106	เชียงเครือ	Chiang Khruea	47000	2025-12-18 04:35:46.217	4701
470107	470107	ท่าแร่	Tha Rae	47000	2025-12-18 04:35:46.22	4701
470109	470109	ม่วงลาย	Muang Lai	47000	2025-12-18 04:35:46.223	4701
470111	470111	ดงชน	Dong Chon	47000	2025-12-18 04:35:46.226	4701
470112	470112	ห้วยยาง	Huai Yang	47000	2025-12-18 04:35:46.228	4701
470113	470113	พังขว้าง	Phang Khwang	47000	2025-12-18 04:35:46.231	4701
470115	470115	ดงมะไฟ	Dong Mafai	47000	2025-12-18 04:35:46.233	4701
470116	470116	ธาตุนาเวง	That Na Weng	47000	2025-12-18 04:35:46.236	4701
470117	470117	เหล่าปอแดง	Lao Po Daeng	47000	2025-12-18 04:35:46.238	4701
470118	470118	หนองลาด	Nong Lat	47220	2025-12-18 04:35:46.241	4701
470120	470120	ฮางโฮง	Hang Hong	47000	2025-12-18 04:35:46.243	4701
470121	470121	โคกก่อง	Khok Kong	47000	2025-12-18 04:35:46.247	4701
470201	470201	กุสุมาลย์	Kusuman	47210	2025-12-18 04:35:46.25	4702
470203	470203	นาเพียง	Na Phiang	47230	2025-12-18 04:35:46.257	4702
470204	470204	โพธิไพศาล	Phothi Phaisan	47210	2025-12-18 04:35:46.261	4702
470205	470205	อุ่มจาน	Um Chan	47230	2025-12-18 04:35:46.264	4702
470301	470301	กุดบาก	Kut Bak	47180	2025-12-18 04:35:46.268	4703
470303	470303	นาม่อง	Na Mong	47180	2025-12-18 04:35:46.271	4703
470305	470305	กุดไห	Kut Hai	47180	2025-12-18 04:35:46.274	4703
470401	470401	พรรณา	Phanna	47130	2025-12-18 04:35:46.277	4704
470402	470402	วังยาง	Wang Yang	47130	2025-12-18 04:35:46.28	4704
470403	470403	พอกน้อย	Phok Noi	47220	2025-12-18 04:35:46.284	4704
470404	470404	นาหัวบ่อ	Na Hua Bo	47220	2025-12-18 04:35:46.287	4704
470405	470405	ไร่	Rai	47130	2025-12-18 04:35:46.291	4704
470406	470406	ช้างมิ่ง	Chang Ming	47130	2025-12-18 04:35:46.294	4704
470407	470407	นาใน	Na Nai	47130	2025-12-18 04:35:46.297	4704
470408	470408	สว่าง	Sawang	47130	2025-12-18 04:35:46.299	4704
470409	470409	บะฮี	Ba Hi	47130	2025-12-18 04:35:46.302	4704
470410	470410	เชิงชุม	Choeng Chum	47130	2025-12-18 04:35:46.305	4704
470501	470501	พังโคน	Phang Khon	47160	2025-12-18 04:35:46.308	4705
470502	470502	ม่วงไข่	Muang Khai	47160	2025-12-18 04:35:46.311	4705
470503	470503	แร่	Rae	47160	2025-12-18 04:35:46.314	4705
470504	470504	ไฮหย่อง	Hai Yong	47160	2025-12-18 04:35:46.317	4705
470505	470505	ต้นผึ้ง	Ton Phueng	47160	2025-12-18 04:35:46.32	4705
340504	340504	เจียด	Chiat	34170	2025-12-18 04:35:42.938	3405
470601	470601	วาริชภูมิ	Waritchaphum	47150	2025-12-18 04:35:46.323	4706
470602	470602	ปลาโหล	Pla Lo	47150	2025-12-18 04:35:46.327	4706
470603	470603	หนองลาด	Nong Lat	47150	2025-12-18 04:35:46.33	4706
470604	470604	คำบ่อ	Kham Bo	47150	2025-12-18 04:35:46.333	4706
470605	470605	ค้อเขียว	Kho Khiao	47150	2025-12-18 04:35:46.336	4706
470701	470701	นิคมน้ำอูน	Nikhom Nam Un	47270	2025-12-18 04:35:46.339	4707
470702	470702	หนองปลิง	Nong Pling	47270	2025-12-18 04:35:46.342	4707
470703	470703	หนองบัว	Nong Bua	47270	2025-12-18 04:35:46.345	4707
470704	470704	สุวรรณคาม	*Suwannakarm	47270	2025-12-18 04:35:46.348	4707
470801	470801	วานรนิวาส	Wanon Niwat	47120	2025-12-18 04:35:46.351	4708
470802	470802	เดื่อศรีคันไชย	Duea Si Khan Chai	47120	2025-12-18 04:35:46.354	4708
470803	470803	ขัวก่าย	Khua Kai	47120	2025-12-18 04:35:46.357	4708
470804	470804	หนองสนม	Nong Sanom	47120	2025-12-18 04:35:46.359	4708
470805	470805	คูสะคาม	Khu Sakham	47120	2025-12-18 04:35:46.362	4708
470806	470806	ธาตุ	That	47120	2025-12-18 04:35:46.365	4708
470807	470807	หนองแวง	Nong Waeng	47120	2025-12-18 04:35:46.368	4708
470808	470808	ศรีวิชัย	Si Wichai	47120	2025-12-18 04:35:46.371	4708
470809	470809	นาซอ	Na So	47120	2025-12-18 04:35:46.373	4708
470810	470810	อินทร์แปลง	In Plaeng	47120	2025-12-18 04:35:46.375	4708
470811	470811	นาคำ	Na Kham	47120	2025-12-18 04:35:46.378	4708
470812	470812	คอนสวรรค์	Khon Sawan	47120	2025-12-18 04:35:46.381	4708
470813	470813	กุดเรือคำ	Kut Ruea Kham	47120	2025-12-18 04:35:46.383	4708
470814	470814	หนองแวงใต้	Nong Waeng Tai	47120	2025-12-18 04:35:46.385	4708
470901	470901	คำตากล้า	Kham Ta Kla	47250	2025-12-18 04:35:46.387	4709
470902	470902	หนองบัวสิม	Nong Bua Sim	47250	2025-12-18 04:35:46.39	4709
470903	470903	นาแต้	Na Tae	47250	2025-12-18 04:35:46.394	4709
471001	471001	ม่วง	Muang	47140	2025-12-18 04:35:46.4	4710
471002	471002	มาย	Mai	47140	2025-12-18 04:35:46.403	4710
471003	471003	ดงหม้อทอง	Dong Mo Thong	47140	2025-12-18 04:35:46.406	4710
471004	471004	ดงเหนือ	Dong Nuea	47140	2025-12-18 04:35:46.409	4710
471005	471005	ดงหม้อทองใต้	Dong Mo Thong Tai	47140	2025-12-18 04:35:46.412	4710
471006	471006	ห้วยหลัว	Huai Lua	47140	2025-12-18 04:35:46.415	4710
471007	471007	โนนสะอาด	Non Sa-at	47140	2025-12-18 04:35:46.418	4710
471008	471008	หนองกวั่ง	Nong Kwang	47140	2025-12-18 04:35:46.421	4710
471009	471009	บ่อแก้ว	Bo Kaeo	47140	2025-12-18 04:35:46.424	4710
471101	471101	อากาศ	Akat	47170	2025-12-18 04:35:46.427	4711
471102	471102	โพนแพง	Phon Phaeng	47170	2025-12-18 04:35:46.43	4711
471103	471103	วาใหญ่	Wa Yai	47170	2025-12-18 04:35:46.433	4711
471104	471104	โพนงาม	Phon Ngam	47170	2025-12-18 04:35:46.435	4711
471105	471105	ท่าก้อน	Tha Kon	47170	2025-12-18 04:35:46.438	4711
471106	471106	นาฮี	Na Hi	47170	2025-12-18 04:35:46.441	4711
471107	471107	บะหว้า	Ba Wa	47170	2025-12-18 04:35:46.444	4711
471108	471108	สามัคคีพัฒนา	Samakkhi Phatthana	47170	2025-12-18 04:35:46.448	4711
471201	471201	สว่างแดนดิน	Sawang Daen Din	47110	2025-12-18 04:35:46.451	4712
471203	471203	คำสะอาด	Kham Sa-at	47110	2025-12-18 04:35:46.453	4712
471204	471204	บ้านต้าย	Ban Tai	47110	2025-12-18 04:35:46.456	4712
471206	471206	บงเหนือ	Bong Nuea	47110	2025-12-18 04:35:46.459	4712
471207	471207	โพนสูง	Phon Sung	47110	2025-12-18 04:35:46.462	4712
471208	471208	โคกสี	Khok Si	47110	2025-12-18 04:35:46.465	4712
471210	471210	หนองหลวง	Nong Luang	47110	2025-12-18 04:35:46.469	4712
471211	471211	บงใต้	Bong Tai	47110	2025-12-18 04:35:46.472	4712
471212	471212	ค้อใต้	Kho Tai	47110	2025-12-18 04:35:46.475	4712
471213	471213	พันนา	Phan Na	47240	2025-12-18 04:35:46.478	4712
471214	471214	แวง	Waeng	47240	2025-12-18 04:35:46.482	4712
471215	471215	ทรายมูล	Sai Mun	47110	2025-12-18 04:35:46.485	4712
471216	471216	ตาลโกน	Tan Kon	47240	2025-12-18 04:35:46.489	4712
471217	471217	ตาลเนิ้ง	Tan Noeng	47240	2025-12-18 04:35:46.492	4712
471220	471220	ธาตุทอง	That Thong	47240	2025-12-18 04:35:46.494	4712
471221	471221	บ้านถ่อน	Ban Thon	47110	2025-12-18 04:35:46.496	4712
471301	471301	ส่องดาว	Song Dao	47190	2025-12-18 04:35:46.499	4713
471302	471302	ท่าศิลา	Tha Sila	47190	2025-12-18 04:35:46.501	4713
471303	471303	วัฒนา	Watthana	47190	2025-12-18 04:35:46.502	4713
471304	471304	ปทุมวาปี	Pathum Wapi	47190	2025-12-18 04:35:46.504	4713
471401	471401	เต่างอย	Tao Ngoi	47260	2025-12-18 04:35:46.506	4714
471402	471402	บึงทวาย	Bueng Thawai	47260	2025-12-18 04:35:46.508	4714
471403	471403	นาตาล	Na Tan	47260	2025-12-18 04:35:46.51	4714
471404	471404	จันทร์เพ็ญ	Chan Phen	47260	2025-12-18 04:35:46.512	4714
471501	471501	ตองโขบ	Tong Khop	47280	2025-12-18 04:35:46.514	4715
471502	471502	เหล่าโพนค้อ	Lao Phon Kho	47280	2025-12-18 04:35:46.515	4715
471503	471503	ด่านม่วงคำ	Dan Muang Kham	47280	2025-12-18 04:35:46.516	4715
471504	471504	แมดนาท่ม	Maet Na Thom	47280	2025-12-18 04:35:46.519	4715
471601	471601	บ้านเหล่า	Ban Lao	47290	2025-12-18 04:35:46.521	4716
471602	471602	เจริญศิลป์	Charoen Sin	47290	2025-12-18 04:35:46.524	4716
471603	471603	ทุ่งแก	Thung Kae	47290	2025-12-18 04:35:46.526	4716
471604	471604	โคกศิลา	Khok Sila	47290	2025-12-18 04:35:46.528	4716
471605	471605	หนองแปน	Nong Paen	47290	2025-12-18 04:35:46.53	4716
471701	471701	บ้านโพน	Ban Phon	47230	2025-12-18 04:35:46.531	4717
471702	471702	นาแก้ว	Na Kaeo	47230	2025-12-18 04:35:46.533	4717
471703	471703	นาตงวัฒนา	Na Tong Watthana	47230	2025-12-18 04:35:46.534	4717
471704	471704	บ้านแป้น	Ban Paen	47230	2025-12-18 04:35:46.537	4717
471705	471705	เชียงสือ	Chiang Sue	47230	2025-12-18 04:35:46.539	4717
471801	471801	สร้างค้อ	Sang Kho	47180	2025-12-18 04:35:46.541	4718
471802	471802	หลุบเลา	Lup Lao	47180	2025-12-18 04:35:46.542	4718
471803	471803	โคกภู	Khok Phu	47180	2025-12-18 04:35:46.551	4718
471804	471804	กกปลาซิว	Kok Pla Sio	47180	2025-12-18 04:35:46.56	4718
480101	480101	ในเมือง	Nai Mueang	48000	2025-12-18 04:35:46.572	4801
480102	480102	หนองแสง	Nong Saeng	48000	2025-12-18 04:35:46.577	4801
480103	480103	นาทราย	Na Sai	48000	2025-12-18 04:35:46.58	4801
480104	480104	นาราชควาย	Na Rat Khwai	48000	2025-12-18 04:35:46.582	4801
480105	480105	กุรุคุ	Kurukhu	48000	2025-12-18 04:35:46.584	4801
480106	480106	บ้านผึ้ง	Ban Phueng	48000	2025-12-18 04:35:46.587	4801
480107	480107	อาจสามารถ	At Samat	48000	2025-12-18 04:35:46.591	4801
480108	480108	ขามเฒ่า	Kham Thao	48000	2025-12-18 04:35:46.594	4801
480109	480109	บ้านกลาง	Ban Klang	48000	2025-12-18 04:35:46.595	4801
480110	480110	ท่าค้อ	Tha Kho	48000	2025-12-18 04:35:46.597	4801
480111	480111	คำเตย	Kham Toei	48000	2025-12-18 04:35:46.599	4801
480112	480112	หนองญาติ	Nong Yat	48000	2025-12-18 04:35:46.601	4801
480113	480113	ดงขวาง	Dong Khwang	48000	2025-12-18 04:35:46.602	4801
480114	480114	วังตามัว	Wang Ta Mua	48000	2025-12-18 04:35:46.604	4801
480115	480115	โพธิ์ตาก	Pho Tak	48000	2025-12-18 04:35:46.606	4801
480201	480201	ปลาปาก	Pla Pak	48160	2025-12-18 04:35:46.608	4802
480202	480202	หนองฮี	Nong Hi	48160	2025-12-18 04:35:46.61	4802
480203	480203	กุตาไก้	Kutakai	48160	2025-12-18 04:35:46.611	4802
480204	480204	โคกสว่าง	Khok Sawan	48160	2025-12-18 04:35:46.613	4802
480205	480205	โคกสูง	Khok Sung	48160	2025-12-18 04:35:46.615	4802
480206	480206	มหาชัย	Maha Chai	48160	2025-12-18 04:35:46.616	4802
480207	480207	นามะเขือ	Na Makhuea	48160	2025-12-18 04:35:46.618	4802
480208	480208	หนองเทาใหญ่	Nong Thao Yai	48160	2025-12-18 04:35:46.62	4802
480301	480301	ท่าอุเทน	Tha Uthen	48120	2025-12-18 04:35:46.621	4803
480302	480302	โนนตาล	Non Tan	48120	2025-12-18 04:35:46.623	4803
480303	480303	ท่าจำปา	Tha Champa	48120	2025-12-18 04:35:46.625	4803
480304	480304	ไชยบุรี	Chai Buri	48120	2025-12-18 04:35:46.627	4803
480305	480305	พนอม	Phanom	48120	2025-12-18 04:35:46.628	4803
480306	480306	พะทาย	Phathai	48120	2025-12-18 04:35:46.629	4803
480311	480311	เวินพระบาท	Woen Phra Bat	48120	2025-12-18 04:35:46.631	4803
480312	480312	รามราช	Ram Rat	48120	2025-12-18 04:35:46.632	4803
480314	480314	หนองเทา	Nong Thao	48120	2025-12-18 04:35:46.634	4803
480401	480401	บ้านแพง	Ban Phaeng	48140	2025-12-18 04:35:46.635	4804
480402	480402	ไผ่ล้อม	Phai Lom	48140	2025-12-18 04:35:46.637	4804
480403	480403	โพนทอง	Phon Thong	48140	2025-12-18 04:35:46.638	4804
480404	480404	หนองแวง	Nong Waeng	48140	2025-12-18 04:35:46.639	4804
480408	480408	นางัว	Na Ngua	48140	2025-12-18 04:35:46.641	4804
480409	480409	นาเข	Na Khe	48140	2025-12-18 04:35:46.643	4804
480501	480501	ธาตุพนม	That Phanom	48110	2025-12-18 04:35:46.644	4805
480502	480502	ฝั่งแดง	Fang Daeng	48110	2025-12-18 04:35:46.646	4805
480503	480503	โพนแพง	Phon Phaeng	48110	2025-12-18 04:35:46.647	4805
480504	480504	พระกลางทุ่ง	Phra Klang Thung	48110	2025-12-18 04:35:46.648	4805
480505	480505	นาถ่อน	Na Thon	48110	2025-12-18 04:35:46.65	4805
480506	480506	แสนพัน	Saen Phan	48110	2025-12-18 04:35:46.652	4805
480507	480507	ดอนนางหงส์	Don Nang Hong	48110	2025-12-18 04:35:46.654	4805
480508	480508	น้ำก่ำ	Nam Kam	48110	2025-12-18 04:35:46.655	4805
480509	480509	อุ่มเหม้า	Um Mao	48110	2025-12-18 04:35:46.657	4805
480510	480510	นาหนาด	Na Nat	48110	2025-12-18 04:35:46.659	4805
480511	480511	กุดฉิม	Kut Chim	48110	2025-12-18 04:35:46.661	4805
480512	480512	ธาตุพนมเหนือ	That Phanom Nuea	48110	2025-12-18 04:35:46.662	4805
480601	480601	เรณู	Renu	48170	2025-12-18 04:35:46.664	4806
480602	480602	โพนทอง	Phon Thong	48170	2025-12-18 04:35:46.666	4806
480603	480603	ท่าลาด	Tha Lat	48170	2025-12-18 04:35:46.668	4806
480604	480604	นางาม	Na Ngam	48170	2025-12-18 04:35:46.67	4806
480605	480605	โคกหินแฮ่	Khok Hin Hae	48170	2025-12-18 04:35:46.671	4806
480607	480607	หนองย่างชิ้น	Nong Yang Chin	48170	2025-12-18 04:35:46.673	4806
480608	480608	เรณูใต้	Renu Tai	48170	2025-12-18 04:35:46.675	4806
480609	480609	นาขาม	Na Kham	48170	2025-12-18 04:35:46.676	4806
480701	480701	นาแก	Na Kae	48130	2025-12-18 04:35:46.679	4807
480702	480702	พระซอง	Phra Song	48130	2025-12-18 04:35:46.681	4807
480703	480703	หนองสังข์	Nong Sang	48130	2025-12-18 04:35:46.684	4807
480704	480704	นาคู่	Na Khu	48130	2025-12-18 04:35:46.687	4807
480705	480705	พิมาน	Phiman	48130	2025-12-18 04:35:46.689	4807
480706	480706	พุ่มแก	Phum Kae	48130	2025-12-18 04:35:46.691	4807
480707	480707	ก้านเหลือง	Kan Lueang	48130	2025-12-18 04:35:46.693	4807
480708	480708	หนองบ่อ	Nong Bo	48130	2025-12-18 04:35:46.695	4807
480709	480709	นาเลียง	Na Liang	48130	2025-12-18 04:35:46.696	4807
480712	480712	บ้านแก้ง	Ban Kaeng	48130	2025-12-18 04:35:46.698	4807
480713	480713	คำพี้	Kham Phi	48130	2025-12-18 04:35:46.7	4807
480715	480715	สีชมพู	Si Chomphu	48130	2025-12-18 04:35:46.702	4807
480801	480801	ศรีสงคราม	Si Songkhram	48150	2025-12-18 04:35:46.703	4808
480802	480802	นาเดื่อ	Na Duea	48150	2025-12-18 04:35:46.705	4808
480803	480803	บ้านเอื้อง	Ban Ueang	48150	2025-12-18 04:35:46.707	4808
480804	480804	สามผง	Sam Phong	48150	2025-12-18 04:35:46.709	4808
480805	480805	ท่าบ่อสงคราม	Tha Bo Songkhram	48150	2025-12-18 04:35:46.711	4808
480806	480806	บ้านข่า	Ban Kha	48150	2025-12-18 04:35:46.713	4808
480807	480807	นาคำ	Na Kham	48150	2025-12-18 04:35:46.715	4808
480808	480808	โพนสว่าง	Phon Sawang	48150	2025-12-18 04:35:46.717	4808
480809	480809	หาดแพง	Hat Phaeng	48150	2025-12-18 04:35:46.719	4808
480901	480901	นาหว้า	Na Wa	48180	2025-12-18 04:35:46.721	4809
341901	341901	พิบูล	Phibun	34110	2025-12-18 04:35:43.032	3419
480902	480902	นางัว	Na Ngua	48180	2025-12-18 04:35:46.722	4809
480903	480903	บ้านเสียว	Ban Siao	48180	2025-12-18 04:35:46.724	4809
480904	480904	นาคูณใหญ่	Na Khun Yai	48180	2025-12-18 04:35:46.726	4809
480905	480905	เหล่าพัฒนา	Lao Phatthana	48180	2025-12-18 04:35:46.728	4809
480906	480906	ท่าเรือ	Tha Ruea	48180	2025-12-18 04:35:46.73	4809
481002	481002	นาหัวบ่อ	Na Hua Bo	48190	2025-12-18 04:35:46.734	4810
481003	481003	นาขมิ้น	Na Khamin	48190	2025-12-18 04:35:46.736	4810
481004	481004	โพนบก	Phon Bok	48190	2025-12-18 04:35:46.738	4810
481005	481005	บ้านค้อ	Ban Kho	48190	2025-12-18 04:35:46.739	4810
481006	481006	โพนจาน	Phon Chan	48190	2025-12-18 04:35:46.741	4810
481007	481007	นาใน	Na Nai	48190	2025-12-18 04:35:46.743	4810
481101	481101	นาทม	Na Thom	48140	2025-12-18 04:35:46.745	4811
481102	481102	หนองซน	Nong Son	48140	2025-12-18 04:35:46.747	4811
481103	481103	ดอนเตย	Don Toei	48140	2025-12-18 04:35:46.749	4811
481201	481201	วังยาง	Wang Yang	48130	2025-12-18 04:35:46.751	4812
481202	481202	โคกสี	Khok Si	48130	2025-12-18 04:35:46.753	4812
481203	481203	ยอดชาด	Yot Chat	48130	2025-12-18 04:35:46.755	4812
481204	481204	หนองโพธิ์	Nong Pho	48130	2025-12-18 04:35:46.757	4812
490101	490101	มุกดาหาร	Mukdahan	49000	2025-12-18 04:35:46.759	4901
490102	490102	ศรีบุญเรือง	Si Bun Rueang	49000	2025-12-18 04:35:46.761	4901
490103	490103	บ้านโคก	Ban Khok	49000	2025-12-18 04:35:46.763	4901
490104	490104	บางทรายใหญ่	Bang Sai Yai	49000	2025-12-18 04:35:46.765	4901
490105	490105	โพนทราย	Phon Sai	49000	2025-12-18 04:35:46.767	4901
490106	490106	ผึ่งแดด	Phueng Daet	49000	2025-12-18 04:35:46.769	4901
490107	490107	นาโสก	Na Sok	49000	2025-12-18 04:35:46.771	4901
490108	490108	นาสีนวน	Na Si Nuan	49000	2025-12-18 04:35:46.773	4901
490109	490109	คำป่าหลาย	Kham Pa Lai	49000	2025-12-18 04:35:46.774	4901
490110	490110	คำอาฮวน	Kham Ahuan	49000	2025-12-18 04:35:46.776	4901
490111	490111	ดงเย็น	Dong Yen	49000	2025-12-18 04:35:46.778	4901
490112	490112	ดงมอน	Dong Mon	49000	2025-12-18 04:35:46.78	4901
490113	490113	กุดแข้	Kut Khae	49000	2025-12-18 04:35:46.782	4901
490201	490201	นิคมคำสร้อย	Nikhom Kham Soi	49130	2025-12-18 04:35:46.784	4902
490202	490202	นากอก	Na Kok	49130	2025-12-18 04:35:46.786	4902
490203	490203	หนองแวง	Nong Waeng	49130	2025-12-18 04:35:46.788	4902
490204	490204	กกแดง	Kok Daeng	49130	2025-12-18 04:35:46.79	4902
490205	490205	นาอุดม	Na Udom	49130	2025-12-18 04:35:46.792	4902
490206	490206	โชคชัย	Chok Chai	49130	2025-12-18 04:35:46.794	4902
490207	490207	ร่มเกล้า	Rom Klao	49130	2025-12-18 04:35:46.795	4902
490301	490301	ดอนตาล	Don Tan	49120	2025-12-18 04:35:46.797	4903
490302	490302	โพธิ์ไทร	Pho Sai	49120	2025-12-18 04:35:46.799	4903
490303	490303	ป่าไร่	Pa Rai	49120	2025-12-18 04:35:46.801	4903
490304	490304	เหล่าหมี	Lao Mi	49120	2025-12-18 04:35:46.803	4903
490305	490305	บ้านบาก	Ban Bak	49120	2025-12-18 04:35:46.805	4903
490306	490306	นาสะเม็ง	Na Sameng	49120	2025-12-18 04:35:46.807	4903
490307	490307	บ้านแก้ง	Ban Kaeng	49120	2025-12-18 04:35:46.809	4903
490401	490401	ดงหลวง	Dong Luang	49140	2025-12-18 04:35:46.811	4904
490402	490402	หนองบัว	Nong Bua	49140	2025-12-18 04:35:46.813	4904
490403	490403	กกตูม	Kok Tum	49140	2025-12-18 04:35:46.814	4904
490404	490404	หนองแคน	Nong Khaen	49140	2025-12-18 04:35:46.816	4904
490405	490405	ชะโนดน้อย	Chanot Noi	49140	2025-12-18 04:35:46.818	4904
490406	490406	พังแดง	Phang Daeng	49140	2025-12-18 04:35:46.82	4904
490503	490503	บ้านซ่ง	Ban Song	49110	2025-12-18 04:35:46.822	4905
490504	490504	คำชะอี	Khamcha-i	49110	2025-12-18 04:35:46.824	4905
490505	490505	หนองเอี่ยน	(Nong Ian	49110	2025-12-18 04:35:46.826	4905
490506	490506	บ้านค้อ	Ban Kho	49110	2025-12-18 04:35:46.828	4905
490507	490507	บ้านเหล่า	Ban Lao	49110	2025-12-18 04:35:46.83	4905
490508	490508	โพนงาม	Phon Ngam	49110	2025-12-18 04:35:46.832	4905
490511	490511	เหล่าสร้างถ่อ	Lao Sang Tho	49110	2025-12-18 04:35:46.834	4905
490512	490512	คำบก	Kham Bok	49110	2025-12-18 04:35:46.836	4905
490514	490514	น้ำเที่ยง	Nam Thiang	49110	2025-12-18 04:35:46.837	4905
490601	490601	หว้านใหญ่	Wan Yai	49150	2025-12-18 04:35:46.839	4906
490602	490602	ป่งขาม	Pong Kham	49150	2025-12-18 04:35:46.84	4906
490603	490603	บางทรายน้อย	Bang Sai Noi	49150	2025-12-18 04:35:46.842	4906
490604	490604	ชะโนด	Chanot	49150	2025-12-18 04:35:46.844	4906
490605	490605	ดงหมู	Dong Mu	49150	2025-12-18 04:35:46.845	4906
490701	490701	หนองสูง	Nong Sung	49160	2025-12-18 04:35:46.847	4907
490702	490702	โนนยาง	Non Yang	49160	2025-12-18 04:35:46.849	4907
490703	490703	ภูวง	Phu Wong	49160	2025-12-18 04:35:46.851	4907
490704	490704	บ้านเป้า	Ban Pao	49160	2025-12-18 04:35:46.853	4907
490705	490705	หนองสูงใต้	Nong Sung Tai	49160	2025-12-18 04:35:46.855	4907
490706	490706	หนองสูงเหนือ	Nong Sung Nuea	49160	2025-12-18 04:35:46.857	4907
500101	500101	ศรีภูมิ	Si Phum	50200	2025-12-18 04:35:46.859	5001
500102	500102	พระสิงห์	Phra Sing	50200	2025-12-18 04:35:46.861	5001
500104	500104	ช้างม่อย	Chang Moi	50300	2025-12-18 04:35:46.866	5001
500105	500105	ช้างคลาน	Chang Khlan	50100	2025-12-18 04:35:46.868	5001
500106	500106	วัดเกต	Wat Ket	50000	2025-12-18 04:35:46.87	5001
500107	500107	ช้างเผือก	Chang Phueak	50300	2025-12-18 04:35:46.872	5001
500108	500108	สุเทพ	Suthep	50200	2025-12-18 04:35:46.874	5001
500109	500109	แม่เหียะ	Mae Hia	50100	2025-12-18 04:35:46.875	5001
500110	500110	ป่าแดด	Pa Daet	50100	2025-12-18 04:35:46.877	5001
500111	500111	หนองหอย	Nong Hoi	50000	2025-12-18 04:35:46.879	5001
500112	500112	ท่าศาลา	Tha Sala	50000	2025-12-18 04:35:46.881	5001
500113	500113	หนองป่าครั่ง	Nong Pa Khrang	50000	2025-12-18 04:35:46.883	5001
500114	500114	ฟ้าฮ่าม	Fa Ham	50000	2025-12-18 04:35:46.885	5001
500115	500115	ป่าตัน	Pa Tan	50300	2025-12-18 04:35:46.887	5001
500116	500116	สันผีเสื้อ	San Phi Suea	50300	2025-12-18 04:35:46.89	5001
500203	500203	บ้านหลวง	Ban Luang	50160	2025-12-18 04:35:46.892	5002
500204	500204	ข่วงเปา	Khuang Pao	50160	2025-12-18 04:35:46.894	5002
500205	500205	สบเตี๊ยะ	Sop Tia	50160	2025-12-18 04:35:46.896	5002
500206	500206	บ้านแปะ	Ban Pae	50240	2025-12-18 04:35:46.898	5002
500207	500207	ดอยแก้ว	Doi Kaeo	50160	2025-12-18 04:35:46.9	5002
500209	500209	แม่สอย	Mae Soi	50240	2025-12-18 04:35:46.902	5002
500301	500301	ช่างเคิ่ง	Chang Khoeng	50270	2025-12-18 04:35:46.904	5003
500302	500302	ท่าผา	Tha Pha	50270	2025-12-18 04:35:46.907	5003
500303	500303	บ้านทับ	Ban Thap	50270	2025-12-18 04:35:46.909	5003
500304	500304	แม่ศึก	Mae Suek	50270	2025-12-18 04:35:46.911	5003
500305	500305	แม่นาจร	Mae Na Chon	50270	2025-12-18 04:35:46.913	5003
500306	500306	บ้านจันทร์	Ban Chan	58130	2025-12-18 04:35:46.915	5003
500307	500307	ปางหินฝน	Pang Hin Fon	50270	2025-12-18 04:35:46.917	5003
500308	500308	กองแขก	Kong Khaek	50270	2025-12-18 04:35:46.919	5003
500309	500309	แม่แดด	Mae Dad	58130	2025-12-18 04:35:46.921	5003
500310	500310	แจ่มหลวง	Chaem Luang	58130	2025-12-18 04:35:46.923	5003
500401	500401	เชียงดาว	Chiang Dao	50170	2025-12-18 04:35:46.925	5004
500402	500402	เมืองนะ	Mueang Na	50170	2025-12-18 04:35:46.927	5004
500403	500403	เมืองงาย	Mueang Ngai	50170	2025-12-18 04:35:46.929	5004
500404	500404	แม่นะ	Mae Na	50170	2025-12-18 04:35:46.931	5004
500405	500405	เมืองคอง	Mueang Khong	50170	2025-12-18 04:35:46.933	5004
500406	500406	ปิงโค้ง	Ping Khong	50170	2025-12-18 04:35:46.935	5004
500407	500407	ทุ่งข้าวพวง	Thung Khao Phuang	50170	2025-12-18 04:35:46.938	5004
500501	500501	เชิงดอย	Choeng Doi	50220	2025-12-18 04:35:46.94	5005
500502	500502	สันปูเลย	San Pu Loei	50220	2025-12-18 04:35:46.942	5005
500503	500503	ลวงเหนือ	Luang Nuea	50220	2025-12-18 04:35:46.944	5005
500504	500504	ป่าป้อง	Pa Pong	50220	2025-12-18 04:35:46.946	5005
500505	500505	สง่าบ้าน	Sa-nga Ban	50220	2025-12-18 04:35:46.948	5005
500506	500506	ป่าลาน	Pa Lan	50220	2025-12-18 04:35:46.95	5005
500507	500507	ตลาดขวัญ	Talat Khwan	50220	2025-12-18 04:35:46.952	5005
500508	500508	สำราญราษฎร์	Samran Rat	50220	2025-12-18 04:35:46.954	5005
500509	500509	แม่คือ	Mae Khue	50220	2025-12-18 04:35:46.957	5005
500510	500510	ตลาดใหญ่	Talat Yai	50220	2025-12-18 04:35:46.959	5005
500511	500511	แม่ฮ้อยเงิน	Mae Hoi Ngoen	50220	2025-12-18 04:35:46.961	5005
500512	500512	แม่โป่ง	Mae Pong	50220	2025-12-18 04:35:46.963	5005
500513	500513	ป่าเมี่ยง	Pa Miang	50220	2025-12-18 04:35:46.965	5005
500514	500514	เทพเสด็จ	Thep Sadet	50220	2025-12-18 04:35:46.967	5005
500601	500601	สันมหาพน	San Maha Phon	50150	2025-12-18 04:35:46.969	5006
500602	500602	แม่แตง	Mae Taeng	50150	2025-12-18 04:35:46.971	5006
500603	500603	ขี้เหล็ก	Khilek	50150	2025-12-18 04:35:46.974	5006
500604	500604	ช่อแล	Cho Lae	50150	2025-12-18 04:35:46.976	5006
500605	500605	แม่หอพระ	Mae Ho Phra	50150	2025-12-18 04:35:46.978	5006
500606	500606	สบเปิง	Sop Poeng	50150	2025-12-18 04:35:46.98	5006
500607	500607	บ้านเป้า	Ban Pao	50150	2025-12-18 04:35:46.982	5006
500608	500608	สันป่ายาง	San Pa Yang	50330	2025-12-18 04:35:46.984	5006
500609	500609	ป่าแป๋	Pa Pae	50150	2025-12-18 04:35:46.986	5006
500610	500610	เมืองก๋าย	Mueang Kai	50150	2025-12-18 04:35:46.989	5006
500611	500611	บ้านช้าง	Ban Chang	50150	2025-12-18 04:35:46.991	5006
500612	500612	กื้ดช้าง	Kuet Chang	50150	2025-12-18 04:35:46.993	5006
500613	500613	อินทขิล	Inthakhin	50150	2025-12-18 04:35:46.995	5006
500614	500614	สมก๋าย	Som Kai	50150	2025-12-18 04:35:46.997	5006
500701	500701	ริมใต้	Rim Tai	50180	2025-12-18 04:35:47	5007
500702	500702	ริมเหนือ	Rim Nuea	50180	2025-12-18 04:35:47.003	5007
500703	500703	สันโป่ง	San Pong	50180	2025-12-18 04:35:47.012	5007
500704	500704	ขี้เหล็ก	Khilek	50180	2025-12-18 04:35:47.013	5007
500705	500705	สะลวง	Saluang	50330	2025-12-18 04:35:47.015	5007
500706	500706	ห้วยทราย	Huai Sai	50180	2025-12-18 04:35:47.017	5007
500707	500707	แม่แรม	Mae Raem	50180	2025-12-18 04:35:47.019	5007
500708	500708	โป่งแยง	Pong Yaeng	50180	2025-12-18 04:35:47.02	5007
500709	500709	แม่สา	Mae Sa	50180	2025-12-18 04:35:47.022	5007
500710	500710	ดอนแก้ว	Don Kaeo	50180	2025-12-18 04:35:47.024	5007
500711	500711	เหมืองแก้ว	Mueang Kaeo	50180	2025-12-18 04:35:47.025	5007
500801	500801	สะเมิงใต้	Samoeng Tai	50250	2025-12-18 04:35:47.027	5008
500802	500802	สะเมิงเหนือ	Samoeng Nuea	50250	2025-12-18 04:35:47.029	5008
500803	500803	แม่สาบ	Mae Sap	50250	2025-12-18 04:35:47.031	5008
500804	500804	บ่อแก้ว	Bo Kaeo	50250	2025-12-18 04:35:47.033	5008
500805	500805	ยั้งเมิน	Yang Moen	50250	2025-12-18 04:35:47.035	5008
500901	500901	เวียง	Wiang	50110	2025-12-18 04:35:47.037	5009
500903	500903	ม่อนปิ่น	Mon Pin	50110	2025-12-18 04:35:47.039	5009
500904	500904	แม่งอน	Mae Ngon	50320	2025-12-18 04:35:47.04	5009
500905	500905	แม่สูน	Mae Sun	50110	2025-12-18 04:35:47.042	5009
500910	500910	แม่คะ	Mae Kha	50110	2025-12-18 04:35:47.047	5009
500911	500911	แม่ข่า	Mae Kha	50320	2025-12-18 04:35:47.049	5009
500912	500912	โป่งน้ำร้อน	Pong Nam Ron	50110	2025-12-18 04:35:47.052	5009
501001	501001	แม่อาย	Mae Ai	50280	2025-12-18 04:35:47.054	5010
501002	501002	แม่สาว	Mae Sao	50280	2025-12-18 04:35:47.056	5010
501003	501003	สันต้นหมื้อ	San Ton Mue	50280	2025-12-18 04:35:47.058	5010
501004	501004	แม่นาวาง	Mae Na Wang	50280	2025-12-18 04:35:47.06	5010
501005	501005	ท่าตอน	Tha Ton	50280	2025-12-18 04:35:47.062	5010
501006	501006	บ้านหลวง	Ban Luang	50280	2025-12-18 04:35:47.064	5010
501007	501007	มะลิกา	Malika	50280	2025-12-18 04:35:47.066	5010
501101	501101	เวียง	Wiang	50190	2025-12-18 04:35:47.067	5011
501102	501102	ทุ่งหลวง	Thung Luang	50190	2025-12-18 04:35:47.069	5011
501103	501103	ป่าตุ้ม	Pa Tum	50190	2025-12-18 04:35:47.07	5011
501104	501104	ป่าไหน่	Pa Nai	50190	2025-12-18 04:35:47.072	5011
501105	501105	สันทราย	San Sai	50190	2025-12-18 04:35:47.074	5011
501106	501106	บ้านโป่ง	Ban Pong	50190	2025-12-18 04:35:47.075	5011
501107	501107	น้ำแพร่	Nam Phrae	50190	2025-12-18 04:35:47.077	5011
501108	501108	เขื่อนผาก	Khuean Phak	50190	2025-12-18 04:35:47.078	5011
501109	501109	แม่แวน	Mae Waen	50190	2025-12-18 04:35:47.08	5011
501110	501110	แม่ปั๋ง	Mae Pang	50190	2025-12-18 04:35:47.081	5011
501111	501111	โหล่งขอด	Long Khot	50190	2025-12-18 04:35:47.082	5011
501201	501201	ยุหว่า	Yu Wa	50120	2025-12-18 04:35:47.084	5012
501202	501202	สันกลาง	San Klang	50120	2025-12-18 04:35:47.086	5012
501203	501203	ท่าวังพร้าว	Tha Wang Phrao	50120	2025-12-18 04:35:47.089	5012
501204	501204	มะขามหลวง	Makham Luang	50120	2025-12-18 04:35:47.09	5012
501205	501205	แม่ก๊า	Mae Ka	50120	2025-12-18 04:35:47.091	5012
501206	501206	บ้านแม	Ban Mae	50120	2025-12-18 04:35:47.092	5012
501207	501207	บ้านกลาง	Ban Klang	50120	2025-12-18 04:35:47.093	5012
501208	501208	ทุ่งสะโตก	Thung Satok	50120	2025-12-18 04:35:47.094	5012
501210	501210	ทุ่งต้อม	Thung Tom	50120	2025-12-18 04:35:47.096	5012
501214	501214	น้ำบ่อหลวง	Nam Bo Luang	50120	2025-12-18 04:35:47.097	5012
501215	501215	มะขุนหวาน	Makhun Wan	50120	2025-12-18 04:35:47.098	5012
501301	501301	สันกำแพง	San Kamphaeng	50130	2025-12-18 04:35:47.099	5013
501302	501302	ทรายมูล	Sai Mun	50130	2025-12-18 04:35:47.1	5013
501303	501303	ร้องวัวแดง	Rong Wua Daeng	50130	2025-12-18 04:35:47.101	5013
501304	501304	บวกค้าง	Buak Khang	50130	2025-12-18 04:35:47.103	5013
501305	501305	แช่ช้าง	Chae Chang	50130	2025-12-18 04:35:47.104	5013
501306	501306	ออนใต้	On Tai	50130	2025-12-18 04:35:47.105	5013
501310	501310	แม่ปูคา	Mae Pu Kha	50130	2025-12-18 04:35:47.106	5013
501311	501311	ห้วยทราย	Huai Sai	50130	2025-12-18 04:35:47.107	5013
501312	501312	ต้นเปา	Ton Pao	50130	2025-12-18 04:35:47.108	5013
501313	501313	สันกลาง	San Klang	50130	2025-12-18 04:35:47.109	5013
501401	501401	สันทรายหลวง	San Sai Luang	50210	2025-12-18 04:35:47.11	5014
501402	501402	สันทรายน้อย	San Sai Noi	50210	2025-12-18 04:35:47.111	5014
501403	501403	สันพระเนตร	San Phranet	50210	2025-12-18 04:35:47.112	5014
501404	501404	สันนาเม็ง	San Na Meng	50210	2025-12-18 04:35:47.114	5014
501405	501405	สันป่าเปา	San Pa Pao	50210	2025-12-18 04:35:47.115	5014
501406	501406	หนองแหย่ง	Nong Yaeng	50210	2025-12-18 04:35:47.116	5014
501407	501407	หนองจ๊อม	Nong Chom	50210	2025-12-18 04:35:47.117	5014
501408	501408	หนองหาร	Nong Han	50290	2025-12-18 04:35:47.118	5014
501409	501409	แม่แฝก	Mae Faek	50290	2025-12-18 04:35:47.119	5014
501410	501410	แม่แฝกใหม่	Mae Faek Mai	50290	2025-12-18 04:35:47.121	5014
501411	501411	เมืองเล็น	Mueang Len	50210	2025-12-18 04:35:47.122	5014
501412	501412	ป่าไผ่	Pa Phai	50210	2025-12-18 04:35:47.123	5014
501501	501501	หางดง	Hang Dong	50230	2025-12-18 04:35:47.124	5015
501502	501502	หนองแก๋ว	Nong Kaeo	50230	2025-12-18 04:35:47.125	5015
501503	501503	หารแก้ว	Han Kaeo	50230	2025-12-18 04:35:47.126	5015
501504	501504	หนองตอง	Nong Tong	50340	2025-12-18 04:35:47.127	5015
501505	501505	ขุนคง	Khun Khong	50230	2025-12-18 04:35:47.128	5015
501506	501506	สบแม่ข่า	Sop Mae Kha	50230	2025-12-18 04:35:47.129	5015
501507	501507	บ้านแหวน	Ban Waen	50230	2025-12-18 04:35:47.13	5015
501508	501508	สันผักหวาน	San Phak Wan	50230	2025-12-18 04:35:47.132	5015
501509	501509	หนองควาย	Nong Khwai	50230	2025-12-18 04:35:47.133	5015
501510	501510	บ้านปง	Ban Pong	50230	2025-12-18 04:35:47.134	5015
501511	501511	น้ำแพร่	Nam Phrae	50230	2025-12-18 04:35:47.135	5015
501601	501601	หางดง	Hang Dong	50240	2025-12-18 04:35:47.136	5016
501602	501602	ฮอด	Hot	50240	2025-12-18 04:35:47.137	5016
501603	501603	บ้านตาล	Ban Tan	50240	2025-12-18 04:35:47.139	5016
501604	501604	บ่อหลวง	Bo Luang	50240	2025-12-18 04:35:47.14	5016
501605	501605	บ่อสลี	Bo Sali	50240	2025-12-18 04:35:47.141	5016
501606	501606	นาคอเรือ	Na Kho Ruea	50240	2025-12-18 04:35:47.142	5016
501701	501701	ดอยเต่า	Doi Tao	50260	2025-12-18 04:35:47.143	5017
501702	501702	ท่าเดื่อ	Tha Duea	50260	2025-12-18 04:35:47.144	5017
501703	501703	มืดกา	Muet Ka	50260	2025-12-18 04:35:47.145	5017
501704	501704	บ้านแอ่น	Ban Aen	50260	2025-12-18 04:35:47.147	5017
501705	501705	บงตัน	Bong Tan	50260	2025-12-18 04:35:47.148	5017
501706	501706	โปงทุ่ง	Pong Thung	50260	2025-12-18 04:35:47.149	5017
501801	501801	อมก๋อย	Omkoi	50310	2025-12-18 04:35:47.15	5018
501802	501802	ยางเปียง	Yang Piang	50310	2025-12-18 04:35:47.151	5018
501803	501803	แม่ตื่น	Mae Tuen	50310	2025-12-18 04:35:47.152	5018
501804	501804	ม่อนจอง	Mon Chong	50310	2025-12-18 04:35:47.154	5018
501805	501805	สบโขง	Sop Khong	50310	2025-12-18 04:35:47.156	5018
501806	501806	นาเกียน	Na Kian	50310	2025-12-18 04:35:47.157	5018
501901	501901	ยางเนิ้ง	Yang Noeng	50140	2025-12-18 04:35:47.158	5019
501902	501902	สารภี	Saraphi	50140	2025-12-18 04:35:47.16	5019
501903	501903	ชมภู	Chom Phu	50140	2025-12-18 04:35:47.161	5019
501904	501904	ไชยสถาน	Chai Sathan	50140	2025-12-18 04:35:47.162	5019
501905	501905	ขัวมุง	Khua Mung	50140	2025-12-18 04:35:47.163	5019
501906	501906	หนองแฝก	Nong Faek	50140	2025-12-18 04:35:47.164	5019
501907	501907	หนองผึ้ง	Nong Phueng	50140	2025-12-18 04:35:47.166	5019
501908	501908	ท่ากว้าง	Tha Kwang	50140	2025-12-18 04:35:47.167	5019
110308	110308	ราชาเทวะ	Racha Thewa	10540	2025-12-18 04:35:38.831	1103
501909	501909	ดอนแก้ว	Don Kaeo	50140	2025-12-18 04:35:47.168	5019
501910	501910	ท่าวังตาล	Tha Wang Tan	50140	2025-12-18 04:35:47.169	5019
501911	501911	สันทราย	San Sai	50140	2025-12-18 04:35:47.171	5019
501912	501912	ป่าบง	Pa Bong	50140	2025-12-18 04:35:47.172	5019
502001	502001	เมืองแหง	Mueang Haeng	50350	2025-12-18 04:35:47.173	5020
502002	502002	เปียงหลวง	Piang Luang	50350	2025-12-18 04:35:47.175	5020
502003	502003	แสนไห	Saen Hai	50350	2025-12-18 04:35:47.176	5020
502101	502101	ปงตำ	Pong Tam	50320	2025-12-18 04:35:47.177	5021
502102	502102	ศรีดงเย็น	Si Dong Yen	50320	2025-12-18 04:35:47.178	5021
502103	502103	แม่ทะลบ	Mae Thalop	50320	2025-12-18 04:35:47.179	5021
502104	502104	หนองบัว	Nong Bua	50320	2025-12-18 04:35:47.181	5021
502201	502201	บ้านกาด	Ban Kat	50360	2025-12-18 04:35:47.182	5022
502202	502202	ทุ่งปี้	Thung Pi	50360	2025-12-18 04:35:47.183	5022
502203	502203	ทุ่งรวงทอง	Thung Ruang Thong	50360	2025-12-18 04:35:47.185	5022
502204	502204	แม่วิน	Mae Win	50360	2025-12-18 04:35:47.186	5022
502205	502205	ดอนเปา	Don Pao	50360	2025-12-18 04:35:47.187	5022
502301	502301	ออนเหนือ	On Nuea	50130	2025-12-18 04:35:47.188	5023
502302	502302	ออนกลาง	On Klang	50130	2025-12-18 04:35:47.19	5023
502303	502303	บ้านสหกรณ์	Ban Sahakon	50130	2025-12-18 04:35:47.191	5023
502304	502304	ห้วยแก้ว	Huai Kaeo	50130	2025-12-18 04:35:47.192	5023
502305	502305	แม่ทา	Mae Tha	50130	2025-12-18 04:35:47.194	5023
502306	502306	ทาเหนือ	Tha Nuea	50130	2025-12-18 04:35:47.195	5023
502401	502401	ดอยหล่อ	Doi Lo	50160	2025-12-18 04:35:47.196	5024
502402	502402	สองแคว	Song Khwae	50160	2025-12-18 04:35:47.198	5024
502403	502403	ยางคราม	Yang Khram	50160	2025-12-18 04:35:47.199	5024
502404	502404	สันติสุข	Santi Suk	50160	2025-12-18 04:35:47.2	5024
510101	510101	ในเมือง	Nai Mueang	51000	2025-12-18 04:35:47.202	5101
510102	510102	เหมืองง่า	Mueang Nga	51000	2025-12-18 04:35:47.203	5101
510103	510103	อุโมงค์	Umong	51150	2025-12-18 04:35:47.204	5101
510104	510104	หนองช้างคืน	Nong Chang Khuen	51150	2025-12-18 04:35:47.205	5101
510105	510105	ประตูป่า	Pratu Pa	51000	2025-12-18 04:35:47.207	5101
510106	510106	ริมปิง	Rim Ping	51000	2025-12-18 04:35:47.208	5101
510107	510107	ต้นธง	Ton Thong	51000	2025-12-18 04:35:47.209	5101
510108	510108	บ้านแป้น	Ban Paen	51000	2025-12-18 04:35:47.211	5101
510109	510109	เหมืองจี้	Mueang Chi	51000	2025-12-18 04:35:47.212	5101
510110	510110	ป่าสัก	Pa Sak	51000	2025-12-18 04:35:47.213	5101
510111	510111	เวียงยอง	Wiang Yong	51000	2025-12-18 04:35:47.214	5101
510112	510112	บ้านกลาง	Ban Klang	51000	2025-12-18 04:35:47.216	5101
510113	510113	มะเขือแจ้	Makhuea Chae	51000	2025-12-18 04:35:47.217	5101
510116	510116	ศรีบัวบาน	Si Bua Ban	51000	2025-12-18 04:35:47.219	5101
510117	510117	หนองหนาม	Nong Nam	51000	2025-12-18 04:35:47.22	5101
510201	510201	ทาปลาดุก	Tha Pla Duk	51140	2025-12-18 04:35:47.222	5102
510202	510202	ทาสบเส้า	Tha Sop Sao	51140	2025-12-18 04:35:47.224	5102
510203	510203	ทากาศ	Tha Kat	51170	2025-12-18 04:35:47.225	5102
510204	510204	ทาขุมเงิน	Tha Khum Ngoen	51170	2025-12-18 04:35:47.227	5102
510205	510205	ทาทุ่งหลวง	Tha Thung Luang	51170	2025-12-18 04:35:47.229	5102
510206	510206	ทาแม่ลอบ	Tha Mae Lop	51170	2025-12-18 04:35:47.23	5102
510301	510301	บ้านโฮ่ง	Ban Hong	51130	2025-12-18 04:35:47.231	5103
510302	510302	ป่าพลู	Pa Phlu	51130	2025-12-18 04:35:47.233	5103
510303	510303	เหล่ายาว	Lao Yao	51130	2025-12-18 04:35:47.234	5103
510304	510304	ศรีเตี้ย	Si Tia	51130	2025-12-18 04:35:47.236	5103
510305	510305	หนองปลาสะวาย	Nong Pla Sawai	51130	2025-12-18 04:35:47.238	5103
510401	510401	ลี้	Li	51110	2025-12-18 04:35:47.239	5104
510402	510402	แม่ตืน	Mae Tuen	51110	2025-12-18 04:35:47.241	5104
510403	510403	นาทราย	Na Sai	51110	2025-12-18 04:35:47.242	5104
510404	510404	ดงดำ	Dong Dam	51110	2025-12-18 04:35:47.244	5104
510405	510405	ก้อ	Ko	51110	2025-12-18 04:35:47.245	5104
510406	510406	แม่ลาน	Mae Lan	51110	2025-12-18 04:35:47.247	5104
510408	510408	ป่าไผ่	Pa Phai	51110	2025-12-18 04:35:47.248	5104
510409	510409	ศรีวิชัย	Si Wichai	51110	2025-12-18 04:35:47.25	5104
510501	510501	ทุ่งหัวช้าง	Thung Hua Chang	51160	2025-12-18 04:35:47.251	5105
510502	510502	บ้านปวง	Ban Puang	51160	2025-12-18 04:35:47.253	5105
510503	510503	ตะเคียนปม	Takhian Pom	51160	2025-12-18 04:35:47.254	5105
510601	510601	ปากบ่อง	Pak Bong	51120	2025-12-18 04:35:47.256	5106
510602	510602	ป่าซาง	Pa Sang	51120	2025-12-18 04:35:47.258	5106
510603	510603	แม่แรง	Mae Raeng	51120	2025-12-18 04:35:47.259	5106
510604	510604	ม่วงน้อย	Muang Noi	51120	2025-12-18 04:35:47.261	5106
510605	510605	บ้านเรือน	Ban Ruean	51120	2025-12-18 04:35:47.262	5106
510606	510606	มะกอก	Makok	51120	2025-12-18 04:35:47.264	5106
510607	510607	ท่าตุ้ม	Tha Tum	51120	2025-12-18 04:35:47.266	5106
510608	510608	น้ำดิบ	Nam Dip	51120	2025-12-18 04:35:47.267	5106
510611	510611	นครเจดีย์	Nakhon Chedi	51120	2025-12-18 04:35:47.269	5106
510701	510701	บ้านธิ	Ban Thi	51180	2025-12-18 04:35:47.271	5107
510702	510702	ห้วยยาบ	Huai Yap	51180	2025-12-18 04:35:47.272	5107
510801	510801	หนองล่อง	Nong Long	51120	2025-12-18 04:35:47.274	5108
510802	510802	หนองยวง	Nong Yuang	51120	2025-12-18 04:35:47.276	5108
510803	510803	วังผาง	Wang Phang	51120	2025-12-18 04:35:47.277	5108
520101	520101	เวียงเหนือ	Wiang Nuea	52000	2025-12-18 04:35:47.279	5201
520102	520102	หัวเวียง	Hua Wiang	52000	2025-12-18 04:35:47.281	5201
520103	520103	สวนดอก	Suan Dok	52100	2025-12-18 04:35:47.282	5201
520104	520104	สบตุ๋ย	Sop Tui	52100	2025-12-18 04:35:47.284	5201
360504	360504	นางแดด	Nang Daet	36210	2025-12-18 04:35:43.227	3605
520105	520105	พระบาท	Phra Bat	52000	2025-12-18 04:35:47.286	5201
520106	520106	ชมพู	Chomphu	52100	2025-12-18 04:35:47.287	5201
520107	520107	กล้วยแพะ	Kluai Phae	52000	2025-12-18 04:35:47.289	5201
520108	520108	ปงแสนทอง	Pong Saen Thong	52100	2025-12-18 04:35:47.291	5201
520109	520109	บ้านแลง	Ban Laeng	52000	2025-12-18 04:35:47.293	5201
520110	520110	บ้านเสด็จ	Ban Sadet	52000	2025-12-18 04:35:47.295	5201
520111	520111	พิชัย	Phichai	52000	2025-12-18 04:35:47.297	5201
520112	520112	ทุ่งฝาย	Thung Fai	52000	2025-12-18 04:35:47.298	5201
520113	520113	บ้านเอื้อม	Ban Ueam	52100	2025-12-18 04:35:47.3	5201
520114	520114	บ้านเป้า	Ban Pao	52100	2025-12-18 04:35:47.302	5201
520115	520115	บ้านค่า	Ban Kha	52100	2025-12-18 04:35:47.304	5201
520116	520116	บ่อแฮ้ว	Bo Haeo	52100	2025-12-18 04:35:47.306	5201
520117	520117	ต้นธงชัย	Ton Thong Chai	52000	2025-12-18 04:35:47.308	5201
520118	520118	นิคมพัฒนา	Nikhom Phatthana	52000	2025-12-18 04:35:47.31	5201
520119	520119	บุญนาคพัฒนา	Bunnak Phatthana	52000	2025-12-18 04:35:47.312	5201
520201	520201	บ้านดง	Ban Dong	52220	2025-12-18 04:35:47.314	5202
520202	520202	นาสัก	Na Sak	52220	2025-12-18 04:35:47.315	5202
520203	520203	จางเหนือ	Chang Nuea	52220	2025-12-18 04:35:47.317	5202
520204	520204	แม่เมาะ	Mae Mo	52220	2025-12-18 04:35:47.319	5202
520205	520205	สบป้าด	Sop Pat	52220	2025-12-18 04:35:47.321	5202
520301	520301	ลำปางหลวง	Lampang Luang	52130	2025-12-18 04:35:47.323	5203
520302	520302	นาแก้ว	Na Kaeo	52130	2025-12-18 04:35:47.325	5203
520303	520303	ไหล่หิน	Lai Hin	52130	2025-12-18 04:35:47.327	5203
520304	520304	วังพร้าว	Wang Phrao	52130	2025-12-18 04:35:47.329	5203
520305	520305	ศาลา	Sala	52130	2025-12-18 04:35:47.331	5203
520306	520306	เกาะคา	Ko Kha	52130	2025-12-18 04:35:47.333	5203
520307	520307	นาแส่ง	Na Saeng	52130	2025-12-18 04:35:47.334	5203
520308	520308	ท่าผา	Tha Pha	52130	2025-12-18 04:35:47.336	5203
520309	520309	ใหม่พัฒนา	Mai Phatthana	52130	2025-12-18 04:35:47.338	5203
520401	520401	ทุ่งงาม	Thung Ngam	52210	2025-12-18 04:35:47.34	5204
520402	520402	เสริมขวา	Soem Khwa	52210	2025-12-18 04:35:47.342	5204
520403	520403	เสริมซ้าย	Soem Sai	52210	2025-12-18 04:35:47.344	5204
520404	520404	เสริมกลาง	Soem Klang	52210	2025-12-18 04:35:47.346	5204
520501	520501	หลวงเหนือ	Luang Nuea	52110	2025-12-18 04:35:47.347	5205
520502	520502	หลวงใต้	Luang Tai	52110	2025-12-18 04:35:47.349	5205
520503	520503	บ้านโป่ง	Ban Pong	52110	2025-12-18 04:35:47.351	5205
520504	520504	บ้านร้อง	Ban Rong	52110	2025-12-18 04:35:47.353	5205
520506	520506	นาแก	Na Kae	52110	2025-12-18 04:35:47.358	5205
520507	520507	บ้านอ้อน	Ban On	52110	2025-12-18 04:35:47.36	5205
520508	520508	บ้านแหง	Ban Haeng	52110	2025-12-18 04:35:47.362	5205
520509	520509	บ้านหวด	Ban Huat	52110	2025-12-18 04:35:47.364	5205
520510	520510	แม่ตีบ	Mae Tip	52110	2025-12-18 04:35:47.366	5205
520601	520601	แจ้ห่ม	Chae Hom	52120	2025-12-18 04:35:47.368	5206
520602	520602	บ้านสา	Ban Sa	52120	2025-12-18 04:35:47.37	5206
520603	520603	ปงดอน	Pong Don	52120	2025-12-18 04:35:47.372	5206
520604	520604	แม่สุก	Mae Suk	52120	2025-12-18 04:35:47.374	5206
520605	520605	เมืองมาย	Mueang Mai	52120	2025-12-18 04:35:47.376	5206
520606	520606	ทุ่งผึ้ง	Thung Phueng	52120	2025-12-18 04:35:47.378	5206
520607	520607	วิเชตนคร	Wichet Nakhon	52120	2025-12-18 04:35:47.38	5206
520701	520701	ทุ่งฮั้ว	Thung Hua	52140	2025-12-18 04:35:47.382	5207
520702	520702	วังเหนือ	Wang Nuea	52140	2025-12-18 04:35:47.384	5207
520703	520703	วังใต้	Wang Tai	52140	2025-12-18 04:35:47.386	5207
520704	520704	ร่องเคาะ	Rong Kho	52140	2025-12-18 04:35:47.388	5207
520705	520705	วังทอง	Wang Thong	52140	2025-12-18 04:35:47.39	5207
520706	520706	วังซ้าย	Wang Sai	52140	2025-12-18 04:35:47.392	5207
520707	520707	วังแก้ว	Wang Kaeo	52140	2025-12-18 04:35:47.394	5207
520708	520708	วังทรายคำ	Wang Sai Kham	52140	2025-12-18 04:35:47.397	5207
520801	520801	ล้อมแรด	Lom Raet	52160	2025-12-18 04:35:47.399	5208
520802	520802	แม่วะ	Mae Wa	52230	2025-12-18 04:35:47.402	5208
520803	520803	แม่ปะ	Mae Pa	52160	2025-12-18 04:35:47.404	5208
520804	520804	แม่มอก	Mae Mok	52160	2025-12-18 04:35:47.406	5208
520805	520805	เวียงมอก	Wiang Mok	52160	2025-12-18 04:35:47.408	5208
520806	520806	นาโป่ง	Na Pong	52160	2025-12-18 04:35:47.41	5208
520807	520807	แม่ถอด	Mae Thot	52160	2025-12-18 04:35:47.412	5208
520808	520808	เถินบุรี	Thoen Buri	52160	2025-12-18 04:35:47.414	5208
520901	520901	แม่พริก	Mae Phrik	52180	2025-12-18 04:35:47.417	5209
520902	520902	ผาปัง	Pha Pang	52180	2025-12-18 04:35:47.419	5209
520903	520903	แม่ปุ	Mae Pu	52180	2025-12-18 04:35:47.421	5209
520904	520904	พระบาทวังตวง	Phra Bat Wang Tuang	52180	2025-12-18 04:35:47.423	5209
521001	521001	แม่ทะ	Mae Tha	52150	2025-12-18 04:35:47.425	5210
521002	521002	นาครัว	Na Khrua	52150	2025-12-18 04:35:47.427	5210
521003	521003	ป่าตัน	Pa Tan	52150	2025-12-18 04:35:47.429	5210
521004	521004	บ้านกิ่ว	Ban Kio	52150	2025-12-18 04:35:47.431	5210
521005	521005	บ้านบอม	Ban Bom	52150	2025-12-18 04:35:47.433	5210
521006	521006	น้ำโจ้	Nam Cho	52150	2025-12-18 04:35:47.436	5210
521007	521007	ดอนไฟ	Don Fai	52150	2025-12-18 04:35:47.438	5210
521008	521008	หัวเสือ	Hua Suea	52150	2025-12-18 04:35:47.44	5210
521010	521010	วังเงิน	Wang Ngoen	52150	2025-12-18 04:35:47.443	5210
521011	521011	สันดอนแก้ว	San Don Kaeo	52150	2025-12-18 04:35:47.445	5210
521101	521101	สบปราบ	Sop Prap	52170	2025-12-18 04:35:47.448	5211
521102	521102	สมัย	Samai	52170	2025-12-18 04:35:47.45	5211
521103	521103	แม่กัวะ	Mae Kua	52170	2025-12-18 04:35:47.453	5211
361503	361503	กะฮาด	Kahat	36130	2025-12-18 04:35:43.339	3615
521104	521104	นายาง	Na Yang	52170	2025-12-18 04:35:47.456	5211
521201	521201	ห้างฉัตร	Hang Chat	52190	2025-12-18 04:35:47.459	5212
521202	521202	หนองหล่ม	Nong Lom	52190	2025-12-18 04:35:47.462	5212
521203	521203	เมืองยาว	Mueang Yao	52190	2025-12-18 04:35:47.464	5212
521204	521204	ปงยางคก	Pong Yang Khok	52190	2025-12-18 04:35:47.468	5212
521205	521205	เวียงตาล	Wiang Tan	52190	2025-12-18 04:35:47.471	5212
521206	521206	แม่สัน	Mae San	52190	2025-12-18 04:35:47.474	5212
521207	521207	วอแก้ว	Wo Kaeo	52190	2025-12-18 04:35:47.478	5212
521301	521301	เมืองปาน	Mueang Pan	52240	2025-12-18 04:35:47.481	5213
521302	521302	บ้านขอ	Ban Kho	52240	2025-12-18 04:35:47.483	5213
521303	521303	ทุ่งกว๋าว	Thung Kwao	52240	2025-12-18 04:35:47.486	5213
521304	521304	แจ้ซ้อน	Chae Son	52240	2025-12-18 04:35:47.489	5213
521305	521305	หัวเมือง	Hua Mueang	52240	2025-12-18 04:35:47.492	5213
530101	530101	ท่าอิฐ	Tha It	53000	2025-12-18 04:35:47.495	5301
530102	530102	ท่าเสา	Tha Sao	53000	2025-12-18 04:35:47.498	5301
530103	530103	บ้านเกาะ	Ban Ko	53000	2025-12-18 04:35:47.501	5301
530104	530104	ป่าเซ่า	Pa Sao	53000	2025-12-18 04:35:47.504	5301
530105	530105	คุ้งตะเภา	Khung Taphao	53000	2025-12-18 04:35:47.506	5301
530106	530106	วังกะพี้	Wang Kaphi	53170	2025-12-18 04:35:47.508	5301
530107	530107	หาดกรวด	Hat Kruat	53000	2025-12-18 04:35:47.511	5301
530108	530108	น้ำริด	Nam Rit	53000	2025-12-18 04:35:47.514	5301
530109	530109	งิ้วงาม	Ngio Ngam	53000	2025-12-18 04:35:47.516	5301
540210	540210	ไผ่โทน	Phai Thon	54140	2025-12-18 04:35:47.668	5402
530110	530110	บ้านด่านนาขาม	Ban Dan Na Kham	53000	2025-12-18 04:35:47.518	5301
530111	530111	บ้านด่าน	Ban Dan	53000	2025-12-18 04:35:47.521	5301
530112	530112	ผาจุก	Pha Chuk	53000	2025-12-18 04:35:47.524	5301
530113	530113	วังดิน	Wang Din	53000	2025-12-18 04:35:47.526	5301
530114	530114	แสนตอ	Saen To	53000	2025-12-18 04:35:47.528	5301
530115	530115	หาดงิ้ว	Hat Ngio	53000	2025-12-18 04:35:47.53	5301
530116	530116	ขุนฝาง	Khun Fang	53000	2025-12-18 04:35:47.532	5301
530117	530117	ถ้ำฉลอง	Tham Chalong	53000	2025-12-18 04:35:47.534	5301
530201	530201	วังแดง	Wang Daeng	53140	2025-12-18 04:35:47.535	5302
530202	530202	บ้านแก่ง	Ban Kaeng	53140	2025-12-18 04:35:47.537	5302
530203	530203	หาดสองแคว	Hat Song Khwae	53140	2025-12-18 04:35:47.539	5302
530204	530204	น้ำอ่าง	Nam Ang	53140	2025-12-18 04:35:47.541	5302
530205	530205	ข่อยสูง	Khoi Sung	53140	2025-12-18 04:35:47.543	5302
530301	530301	ท่าปลา	Tha Pla	53150	2025-12-18 04:35:47.545	5303
530302	530302	หาดล้า	Hat La	53150	2025-12-18 04:35:47.547	5303
530303	530303	ผาเลือด	Pha Lueat	53190	2025-12-18 04:35:47.548	5303
530304	530304	จริม	Charim	53150	2025-12-18 04:35:47.55	5303
530305	530305	น้ำหมัน	Nam Man	53150	2025-12-18 04:35:47.552	5303
530307	530307	นางพญา	Nang Phaya	53150	2025-12-18 04:35:47.555	5303
530308	530308	ร่วมจิต	Ruam Chit	53190	2025-12-18 04:35:47.557	5303
530401	530401	แสนตอ	Saen To	53110	2025-12-18 04:35:47.558	5304
530402	530402	บ้านฝาย	Ban Fai	53110	2025-12-18 04:35:47.56	5304
530403	530403	เด่นเหล็ก	Den Lek	53110	2025-12-18 04:35:47.561	5304
530404	530404	น้ำไคร้	Nam Khrai	53110	2025-12-18 04:35:47.566	5304
530405	530405	น้ำไผ่	Nam Phai	53110	2025-12-18 04:35:47.569	5304
530406	530406	ห้วยมุ่น	Huai Mun	53110	2025-12-18 04:35:47.571	5304
530501	530501	ฟากท่า	Fak Tha	53160	2025-12-18 04:35:47.573	5305
530502	530502	สองคอน	Song Khon	53160	2025-12-18 04:35:47.574	5305
530503	530503	บ้านเสี้ยว	Ban Siao	53160	2025-12-18 04:35:47.576	5305
530504	530504	สองห้อง	Song Hong	53160	2025-12-18 04:35:47.577	5305
530601	530601	ม่วงเจ็ดต้น	Muang Chet Ton	53180	2025-12-18 04:35:47.579	5306
530602	530602	บ้านโคก	Ban Khok	53180	2025-12-18 04:35:47.581	5306
530604	530604	บ่อเบี้ย	Bo Bia	53180	2025-12-18 04:35:47.584	5306
530701	530701	ในเมือง	Nai Mueang	53120	2025-12-18 04:35:47.585	5307
530702	530702	บ้านดารา	Ban Dara	53220	2025-12-18 04:35:47.587	5307
530703	530703	ไร่อ้อย	Rai Oi	53120	2025-12-18 04:35:47.588	5307
530704	530704	ท่าสัก	Tha Sak	53220	2025-12-18 04:35:47.59	5307
530705	530705	คอรุม	Kho Rum	53120	2025-12-18 04:35:47.591	5307
530706	530706	บ้านหม้อ	Ban Mo	53120	2025-12-18 04:35:47.593	5307
530707	530707	ท่ามะเฟือง	Tha Mafueang	53120	2025-12-18 04:35:47.594	5307
530708	530708	บ้านโคน	Ban Khon	53120	2025-12-18 04:35:47.596	5307
530709	530709	พญาแมน	Phaya Maen	53120	2025-12-18 04:35:47.598	5307
530710	530710	นาอิน	Na In	53120	2025-12-18 04:35:47.599	5307
530711	530711	นายาง	Na Yang	53120	2025-12-18 04:35:47.601	5307
530801	530801	ศรีพนมมาศ	Si Phanom Mat	53130	2025-12-18 04:35:47.602	5308
530802	530802	แม่พูล	Mae Phun	53130	2025-12-18 04:35:47.604	5308
530803	530803	นานกกก	Na Nok Kok	53130	2025-12-18 04:35:47.606	5308
530804	530804	ฝายหลวง	Fai Luang	53130	2025-12-18 04:35:47.607	5308
530805	530805	ชัยจุมพล	Chai Chumphon	53130	2025-12-18 04:35:47.609	5308
530806	530806	ไผ่ล้อม	Phai Lom	53210	2025-12-18 04:35:47.611	5308
530807	530807	ทุ่งยั้ง	Thung Yang	53210	2025-12-18 04:35:47.613	5308
530808	530808	ด่านแม่คำมัน	Dan Mae Kham Man	53210	2025-12-18 04:35:47.615	5308
530901	530901	ผักขวง	Phak Khuang	53230	2025-12-18 04:35:47.617	5309
530902	530902	บ่อทอง	Bo Thong	53230	2025-12-18 04:35:47.619	5309
530903	530903	ป่าคาย	Pa Khai	53230	2025-12-18 04:35:47.62	5309
530904	530904	น้ำพี้	Nam Phi	53230	2025-12-18 04:35:47.622	5309
540101	540101	ในเวียง	Nai Wiang	54000	2025-12-18 04:35:47.624	5401
540102	540102	นาจักร	Na Chak	54000	2025-12-18 04:35:47.625	5401
540103	540103	น้ำชำ	Nam Cham	54000	2025-12-18 04:35:47.627	5401
540104	540104	ป่าแดง	Pa Daeng	54000	2025-12-18 04:35:47.629	5401
370301	370301	หนองข่า	Nong Kha	37110	2025-12-18 04:35:43.399	3703
540105	540105	ทุ่งโฮ้ง	Thung Hong	54000	2025-12-18 04:35:47.631	5401
540106	540106	เหมืองหม้อ	Mueang Mo	54000	2025-12-18 04:35:47.633	5401
540107	540107	วังธง	Wang Thong	54000	2025-12-18 04:35:47.634	5401
540108	540108	แม่หล่าย	Mae Lai	54000	2025-12-18 04:35:47.636	5401
540109	540109	ห้วยม้า	Huai Ma	54000	2025-12-18 04:35:47.638	5401
540110	540110	ป่าแมต	Pa Maet	54000	2025-12-18 04:35:47.639	5401
540111	540111	บ้านถิ่น	Ban Thin	54000	2025-12-18 04:35:47.642	5401
540112	540112	สวนเขื่อน	Suan Khuean	54000	2025-12-18 04:35:47.644	5401
540113	540113	วังหงส์	Wang Hong	54000	2025-12-18 04:35:47.645	5401
540114	540114	แม่คำมี	Mae Kham Mi	54000	2025-12-18 04:35:47.649	5401
540115	540115	ทุ่งกวาว	Thung Kwao	54000	2025-12-18 04:35:47.65	5401
540116	540116	ท่าข้าม	Tha Kham	54000	2025-12-18 04:35:47.652	5401
540117	540117	แม่ยม	Mae Yom	54000	2025-12-18 04:35:47.654	5401
540118	540118	ช่อแฮ	Cho Hae	54000	2025-12-18 04:35:47.655	5401
540119	540119	ร่องฟอง	Rong Fong	54000	2025-12-18 04:35:47.657	5401
540120	540120	กาญจนา	Kanchana	54000	2025-12-18 04:35:47.658	5401
540201	540201	ร้องกวาง	Rong Kwang	54140	2025-12-18 04:35:47.66	5402
540204	540204	ร้องเข็ม	Rong Khem	54140	2025-12-18 04:35:47.661	5402
540205	540205	น้ำเลา	Nam Lao	54140	2025-12-18 04:35:47.662	5402
540206	540206	บ้านเวียง	Ban Wiang	54140	2025-12-18 04:35:47.663	5402
540207	540207	ทุ่งศรี	Thung Si	54140	2025-12-18 04:35:47.665	5402
540208	540208	แม่ยางตาล	Mae Yang Tan	54140	2025-12-18 04:35:47.666	5402
540209	540209	แม่ยางฮ่อ	Mae Yang Ho	54140	2025-12-18 04:35:47.667	5402
540213	540213	ห้วยโรง	Huai Rong	54140	2025-12-18 04:35:47.67	5402
540214	540214	แม่ทราย	Mae Sai	54140	2025-12-18 04:35:47.671	5402
540215	540215	แม่ยางร้อง	Mae Yang Rong	54140	2025-12-18 04:35:47.672	5402
540301	540301	ห้วยอ้อ	Huai O	54150	2025-12-18 04:35:47.673	5403
540302	540302	บ้านปิน	Ban Pin	54150	2025-12-18 04:35:47.675	5403
540303	540303	ต้าผามอก	Ta Pha Mok	54150	2025-12-18 04:35:47.679	5403
540304	540304	เวียงต้า	Wiang Ta	54150	2025-12-18 04:35:47.682	5403
540305	540305	ปากกาง	Pak Kang	54150	2025-12-18 04:35:47.685	5403
540306	540306	หัวทุ่ง	Hua Thung	54150	2025-12-18 04:35:47.688	5403
540307	540307	ทุ่งแล้ง	Thung Laeng	54150	2025-12-18 04:35:47.69	5403
540308	540308	บ่อเหล็กลอง	Bo Lek Long	54150	2025-12-18 04:35:47.692	5403
540309	540309	แม่ปาน	Mae Pan	54150	2025-12-18 04:35:47.693	5403
540401	540401	สูงเม่น	Sung Men	54130	2025-12-18 04:35:47.694	5404
540402	540402	น้ำชำ	Nam Cham	54130	2025-12-18 04:35:47.695	5404
540403	540403	หัวฝาย	Hua Fai	54130	2025-12-18 04:35:47.696	5404
540404	540404	ดอนมูล	Don Mun	54130	2025-12-18 04:35:47.697	5404
540405	540405	บ้านเหล่า	Ban Lao	54130	2025-12-18 04:35:47.698	5404
540406	540406	บ้านกวาง	Ban Kwang	54130	2025-12-18 04:35:47.699	5404
540407	540407	บ้านปง	Ban Pong	54130	2025-12-18 04:35:47.7	5404
540408	540408	บ้านกาศ	Ban Kat	54130	2025-12-18 04:35:47.701	5404
540409	540409	ร่องกาศ	Rong Kat	54130	2025-12-18 04:35:47.702	5404
540410	540410	สบสาย	Sop Sai	54130	2025-12-18 04:35:47.703	5404
540411	540411	เวียงทอง	Wiang Thong	54000	2025-12-18 04:35:47.704	5404
540412	540412	พระหลวง	Phra Luang	54130	2025-12-18 04:35:47.705	5404
540501	540501	เด่นชัย	Den Chai	54110	2025-12-18 04:35:47.706	5405
540502	540502	แม่จั๊วะ	Mae Chua	54110	2025-12-18 04:35:47.707	5405
540503	540503	ไทรย้อย	Sai Yoi	54110	2025-12-18 04:35:47.708	5405
540504	540504	ห้วยไร่	Huai Rai	54110	2025-12-18 04:35:47.709	5405
540505	540505	ปงป่าหวาย	Pong Pa Wai	54110	2025-12-18 04:35:47.71	5405
540601	540601	บ้านหนุน	Ban Nun	54120	2025-12-18 04:35:47.711	5406
540602	540602	บ้านกลาง	Ban Klang	54120	2025-12-18 04:35:47.711	5406
540603	540603	ห้วยหม้าย	Huai Mai	54120	2025-12-18 04:35:47.712	5406
540604	540604	เตาปูน	Tao Pun	54120	2025-12-18 04:35:47.714	5406
540605	540605	หัวเมือง	Hua Mueang	54120	2025-12-18 04:35:47.715	5406
540606	540606	สะเอียบ	Sa-iap	54120	2025-12-18 04:35:47.716	5406
540607	540607	แดนชุมพล	Daen Chumphon	54120	2025-12-18 04:35:47.716	5406
540608	540608	ทุ่งน้าว	Thung Nao	54120	2025-12-18 04:35:47.717	5406
540701	540701	วังชิ้น	Wang Chin	54160	2025-12-18 04:35:47.718	5407
540703	540703	แม่ป้าก	Mae Pak	54160	2025-12-18 04:35:47.72	5407
540704	540704	นาพูน	Na Phun	54160	2025-12-18 04:35:47.721	5407
540705	540705	แม่พุง	Mae Phung	54160	2025-12-18 04:35:47.722	5407
540706	540706	ป่าสัก	Pa Sak	54160	2025-12-18 04:35:47.723	5407
540707	540707	แม่เกิ๋ง	Mae Koeng	54160	2025-12-18 04:35:47.724	5407
540801	540801	แม่คำมี	Mae Kham Mi	54170	2025-12-18 04:35:47.725	5408
540802	540802	หนองม่วงไข่	Nong Muang Khai	54170	2025-12-18 04:35:47.726	5408
540803	540803	น้ำรัด	Nam Rat	54170	2025-12-18 04:35:47.727	5408
540804	540804	วังหลวง	Wang Luang	54170	2025-12-18 04:35:47.728	5408
540805	540805	ตำหนักธรรม	Tamnak Tham	54170	2025-12-18 04:35:47.729	5408
540806	540806	ทุ่งแค้ว	Thung Khaeo	54170	2025-12-18 04:35:47.73	5408
550101	550101	ในเวียง	Nai Wiang	55000	2025-12-18 04:35:47.731	5501
550102	550102	บ่อ	Bo	55000	2025-12-18 04:35:47.732	5501
550103	550103	ผาสิงห์	Pha Sing	55000	2025-12-18 04:35:47.733	5501
550104	550104	ไชยสถาน	Chai Sathan	55000	2025-12-18 04:35:47.734	5501
550105	550105	ถืมตอง	Thuem Tong	55000	2025-12-18 04:35:47.735	5501
550106	550106	เรือง	Rueang	55000	2025-12-18 04:35:47.736	5501
550107	550107	นาซาว	Na Sao	55000	2025-12-18 04:35:47.737	5501
550108	550108	ดู่ใต้	Du Tai	55000	2025-12-18 04:35:47.737	5501
550109	550109	กองควาย	Kong Khwai	55000	2025-12-18 04:35:47.738	5501
110309	110309	หนองปรือ	Nong Prue	10540	2025-12-18 04:35:38.832	1103
550116	550116	สวก	Suak	55000	2025-12-18 04:35:47.739	5501
550117	550117	สะเนียน	Sanian	55000	2025-12-18 04:35:47.74	5501
550202	550202	หนองแดง	Nong Daeng	55170	2025-12-18 04:35:47.741	5502
550203	550203	หมอเมือง	Mo Mueang	55170	2025-12-18 04:35:47.742	5502
550204	550204	น้ำพาง	Nam Phang	55170	2025-12-18 04:35:47.743	5502
550205	550205	น้ำปาย	Nam Pai	55170	2025-12-18 04:35:47.744	5502
550206	550206	แม่จริม	Mae Charim	55170	2025-12-18 04:35:47.745	5502
550301	550301	บ้านฟ้า	Ban Fa	55190	2025-12-18 04:35:47.746	5503
550302	550302	ป่าคาหลวง	Pa Kha Luang	55190	2025-12-18 04:35:47.747	5503
550303	550303	สวด	Suat	55190	2025-12-18 04:35:47.748	5503
550304	550304	บ้านพี้	Ban Phi	55190	2025-12-18 04:35:47.749	5503
550401	550401	นาน้อย	Na Noi	55150	2025-12-18 04:35:47.75	5504
550402	550402	เชียงของ	Chiang Khong	55150	2025-12-18 04:35:47.751	5504
550403	550403	ศรีษะเกษ	Sisaket	55150	2025-12-18 04:35:47.752	5504
550404	550404	สถาน	Sathan	55150	2025-12-18 04:35:47.753	5504
550405	550405	สันทะ	Santha	55150	2025-12-18 04:35:47.754	5504
550406	550406	บัวใหญ่	Bua Yai	55150	2025-12-18 04:35:47.755	5504
550407	550407	น้ำตก	Nam Tok	55150	2025-12-18 04:35:47.757	5504
550501	550501	ปัว	Pua	55120	2025-12-18 04:35:47.759	5505
550502	550502	แงง	Ngaeng	55120	2025-12-18 04:35:47.76	5505
550503	550503	สถาน	Sathan	55120	2025-12-18 04:35:47.762	5505
550504	550504	ศิลาแลง	Sila Laeng	55120	2025-12-18 04:35:47.763	5505
550505	550505	ศิลาเพชร	Sila Phet	55120	2025-12-18 04:35:47.764	5505
550506	550506	อวน	Uan	55120	2025-12-18 04:35:47.765	5505
550509	550509	ไชยวัฒนา	Chai Watthana	55120	2025-12-18 04:35:47.766	5505
550510	550510	เจดีย์ชัย	Chedi Chai	55120	2025-12-18 04:35:47.767	5505
550511	550511	ภูคา	Phu Kha	55120	2025-12-18 04:35:47.768	5505
550512	550512	สกาด	Sakat	55120	2025-12-18 04:35:47.769	5505
550513	550513	ป่ากลาง	Pa Klang	55120	2025-12-18 04:35:47.77	5505
550514	550514	วรนคร	Woranakhon	55120	2025-12-18 04:35:47.771	5505
550601	550601	ริม	Rim	55140	2025-12-18 04:35:47.772	5506
550602	550602	ป่าคา	Pa Kha	55140	2025-12-18 04:35:47.773	5506
550603	550603	ผาตอ	Pha To	55140	2025-12-18 04:35:47.774	5506
550604	550604	ยม	Yom	55140	2025-12-18 04:35:47.775	5506
550605	550605	ตาลชุม	Tan Chum	55140	2025-12-18 04:35:47.776	5506
550606	550606	ศรีภูมิ	Si Phum	55140	2025-12-18 04:35:47.777	5506
550607	550607	จอมพระ	Chom Phra	55140	2025-12-18 04:35:47.778	5506
550608	550608	แสนทอง	Saen Thong	55140	2025-12-18 04:35:47.779	5506
550609	550609	ท่าวังผา	Tha Wang Pha	55140	2025-12-18 04:35:47.78	5506
550610	550610	ผาทอง	Pha Thong	55140	2025-12-18 04:35:47.781	5506
550701	550701	กลางเวียง	Klang Wiang	55110	2025-12-18 04:35:47.782	5507
550702	550702	ขึ่ง	Khueng	55110	2025-12-18 04:35:47.783	5507
550703	550703	ไหล่น่าน	Lai Nan	55110	2025-12-18 04:35:47.784	5507
550704	550704	ตาลชุม	Tan Chum	55110	2025-12-18 04:35:47.785	5507
550705	550705	นาเหลือง	Na Lueang	55110	2025-12-18 04:35:47.786	5507
550707	550707	น้ำมวบ	Nam Muap	55110	2025-12-18 04:35:47.788	5507
550708	550708	น้ำปั้ว	Nam Pua	55110	2025-12-18 04:35:47.789	5507
550709	550709	ยาบหัวนา	Yap Hua Na	55110	2025-12-18 04:35:47.79	5507
550710	550710	ปงสนุก	Pong Sanuk	55110	2025-12-18 04:35:47.791	5507
550711	550711	อ่ายนาไลย	Ai Na Lai	55110	2025-12-18 04:35:47.792	5507
550712	550712	ส้านนาหนองใหม่	San Na Nong Mai	55110	2025-12-18 04:35:47.792	5507
550713	550713	แม่ขะนิง	Mae Khaning	55110	2025-12-18 04:35:47.793	5507
550714	550714	แม่สาคร	Mae Sakhon	55110	2025-12-18 04:35:47.794	5507
550715	550715	จอมจันทร์	Chom Chan	55110	2025-12-18 04:35:47.795	5507
550716	550716	แม่สา	Mae Sa	55110	2025-12-18 04:35:47.796	5507
550717	550717	ทุ่งศรีทอง	Thung Si Thong	55110	2025-12-18 04:35:47.797	5507
550801	550801	ปอน	Pon	55130	2025-12-18 04:35:47.799	5508
550802	550802	งอบ	Ngop	55130	2025-12-18 04:35:47.799	5508
550803	550803	และ	Lae	55130	2025-12-18 04:35:47.8	5508
550804	550804	ทุ่งช้าง	Thung Chang	55130	2025-12-18 04:35:47.801	5508
550901	550901	เชียงกลาง	Chiang Klang	55160	2025-12-18 04:35:47.802	5509
550902	550902	เปือ	Puea	55160	2025-12-18 04:35:47.803	5509
550903	550903	เชียงคาน	Chiang Khan	55160	2025-12-18 04:35:47.804	5509
550904	550904	พระธาตุ	Phra That	55160	2025-12-18 04:35:47.805	5509
550908	550908	พญาแก้ว	Phaya Kaeo	55160	2025-12-18 04:35:47.806	5509
550909	550909	พระพุทธบาท	Phra Phutthabat	55160	2025-12-18 04:35:47.807	5509
551001	551001	นาทะนุง	Na Thanung	55180	2025-12-18 04:35:47.809	5510
551002	551002	บ่อแก้ว	Bo Kaeo	55180	2025-12-18 04:35:47.809	5510
551003	551003	เมืองลี	Mueang Li	55180	2025-12-18 04:35:47.81	5510
551004	551004	ปิงหลวง	Ping Luang	55180	2025-12-18 04:35:47.811	5510
551101	551101	ดู่พงษ์	Du Phong	55210	2025-12-18 04:35:47.812	5511
551102	551102	ป่าแลวหลวง	Pa Laeo Luang	55210	2025-12-18 04:35:47.813	5511
551103	551103	พงษ์	Phong	55210	2025-12-18 04:35:47.814	5511
551201	551201	บ่อเกลือเหนือ	Bo Kluea Nuea	55220	2025-12-18 04:35:47.815	5512
551202	551202	บ่อเกลือใต้	Bo Kluea Tai	55220	2025-12-18 04:35:47.816	5512
551204	551204	ภูฟ้า	Phu Fa	55220	2025-12-18 04:35:47.817	5512
551205	551205	ดงพญา	Dong Phaya	55220	2025-12-18 04:35:47.818	5512
551301	551301	นาไร่หลวง	Na Rai Luang	55160	2025-12-18 04:35:47.819	5513
551302	551302	ชนแดน	Chon Daen	55160	2025-12-18 04:35:47.82	5513
551303	551303	ยอด	Yot	55160	2025-12-18 04:35:47.821	5513
551401	551401	ม่วงตึ๊ด	Muang Tuet	55000	2025-12-18 04:35:47.822	5514
551402	551402	นาปัง	Na Pang	55000	2025-12-18 04:35:47.823	5514
551403	551403	น้ำแก่น	Nam Kaen	55000	2025-12-18 04:35:47.823	5514
551404	551404	น้ำเกี๋ยน	Nam Kian	55000	2025-12-18 04:35:47.824	5514
551405	551405	เมืองจัง	Mueang Chang	55000	2025-12-18 04:35:47.825	5514
551406	551406	ท่าน้าว	Tha Nao	55000	2025-12-18 04:35:47.826	5514
551407	551407	ฝายแก้ว	Fai Kaeo	55000	2025-12-18 04:35:47.827	5514
551501	551501	ห้วยโก๋น	Huai Kon	55130	2025-12-18 04:35:47.828	5515
551502	551502	ขุนน่าน	Khun Nan	55130	2025-12-18 04:35:47.83	5515
560101	560101	เวียง	Wiang	56000	2025-12-18 04:35:47.831	5601
560102	560102	แม่ต๋ำ	Mae Tam	56000	2025-12-18 04:35:47.832	5601
560104	560104	แม่นาเรือ	Mae Na Ruea	56000	2025-12-18 04:35:47.833	5601
560105	560105	บ้านตุ่น	Ban Tun	56000	2025-12-18 04:35:47.834	5601
560106	560106	บ้านต๊ำ	Ban Tam	56000	2025-12-18 04:35:47.835	5601
560107	560107	บ้านต๋อม	Ban Tom	56000	2025-12-18 04:35:47.836	5601
560108	560108	แม่ปืม	Mae Puem	56000	2025-12-18 04:35:47.837	5601
560110	560110	แม่กา	Mae Ka	56000	2025-12-18 04:35:47.838	5601
560111	560111	บ้านใหม่	Ban Mai	56000	2025-12-18 04:35:47.839	5601
560112	560112	จำป่าหวาย	Cham Pa Wai	56000	2025-12-18 04:35:47.84	5601
560113	560113	ท่าวังทอง	Tha Wang Thong	56000	2025-12-18 04:35:47.841	5601
560114	560114	แม่ใส	Mae Sai	56000	2025-12-18 04:35:47.842	5601
560115	560115	บ้านสาง	Ban Sang	56000	2025-12-18 04:35:47.843	5601
560116	560116	ท่าจำปี	Tha Champi	56000	2025-12-18 04:35:47.844	5601
560118	560118	สันป่าม่วง	San Pa Muang	56000	2025-12-18 04:35:47.845	5601
560201	560201	ห้วยข้าวก่ำ	Huai Khao Kam	56150	2025-12-18 04:35:47.846	5602
560202	560202	จุน	Chun	56150	2025-12-18 04:35:47.847	5602
560203	560203	ลอ	Lo	56150	2025-12-18 04:35:47.848	5602
560204	560204	หงส์หิน	Hong Hin	56150	2025-12-18 04:35:47.849	5602
560205	560205	ทุ่งรวงทอง	Thung Ruang Thong	56150	2025-12-18 04:35:47.849	5602
560206	560206	ห้วยยางขาม	Huai Yang Kham	56150	2025-12-18 04:35:47.85	5602
560207	560207	พระธาตุขิงแกง	Phra That Khing Kaeng	56150	2025-12-18 04:35:47.851	5602
560301	560301	หย่วน	Yuan	56110	2025-12-18 04:35:47.852	5603
560306	560306	น้ำแวน	Nam Waen	56110	2025-12-18 04:35:47.853	5603
560307	560307	เวียง	Wiang	56110	2025-12-18 04:35:47.854	5603
560308	560308	ฝายกวาง	Fai Kwang	56110	2025-12-18 04:35:47.855	5603
560309	560309	เจดีย์คำ	Chedi Kham	56110	2025-12-18 04:35:47.856	5603
560310	560310	ร่มเย็น	Rom Yen	56110	2025-12-18 04:35:47.857	5603
560311	560311	เชียงบาน	Chiang Ban	56110	2025-12-18 04:35:47.858	5603
560312	560312	แม่ลาว	Mae Lao	56110	2025-12-18 04:35:47.859	5603
560313	560313	อ่างทอง	Ang Thong	56110	2025-12-18 04:35:47.86	5603
560314	560314	ทุ่งผาสุข	Thung Pha Suk	56110	2025-12-18 04:35:47.861	5603
560401	560401	เชียงม่วน	Chiang Muan	56160	2025-12-18 04:35:47.862	5604
560402	560402	บ้านมาง	Ban Mang	56160	2025-12-18 04:35:47.864	5604
560403	560403	สระ	Sa	56160	2025-12-18 04:35:47.865	5604
560501	560501	ดอกคำใต้	Dok Khamtai	56120	2025-12-18 04:35:47.866	5605
560502	560502	ดอนศรีชุม	Don Si Chum	56120	2025-12-18 04:35:47.867	5605
560503	560503	บ้านถ้ำ	Ban Tham	56120	2025-12-18 04:35:47.868	5605
560504	560504	บ้านปิน	Ban Pin	56120	2025-12-18 04:35:47.869	5605
560505	560505	ห้วยลาน	Huai Lan	56120	2025-12-18 04:35:47.87	5605
560506	560506	สันโค้ง	San Khong	56120	2025-12-18 04:35:47.871	5605
560507	560507	ป่าซาง	Pa Sang	56120	2025-12-18 04:35:47.872	5605
560508	560508	หนองหล่ม	Nong Lom	56120	2025-12-18 04:35:47.873	5605
560509	560509	ดงสุวรรณ	Dong Suwan	56120	2025-12-18 04:35:47.874	5605
560510	560510	บุญเกิด	Bun Koet	56120	2025-12-18 04:35:47.875	5605
560511	560511	สว่างอารมณ์	Sawang Arom	56120	2025-12-18 04:35:47.876	5605
560512	560512	คือเวียง	Khue Wiang	56120	2025-12-18 04:35:47.877	5605
560601	560601	ปง	Pong	56140	2025-12-18 04:35:47.878	5606
560602	560602	ควร	Khuan	56140	2025-12-18 04:35:47.879	5606
560603	560603	ออย	Oi	56140	2025-12-18 04:35:47.88	5606
560604	560604	งิม	Ngim	56140	2025-12-18 04:35:47.881	5606
560605	560605	ผาช้างน้อย	Pha Chang Noi	56140	2025-12-18 04:35:47.882	5606
560606	560606	นาปรัง	Na Prang	56140	2025-12-18 04:35:47.883	5606
560607	560607	ขุนควร	Khun Khuan	56140	2025-12-18 04:35:47.884	5606
560701	560701	แม่ใจ	Mae Chai	56130	2025-12-18 04:35:47.885	5607
560702	560702	ศรีถ้อย	Si Thoi	56130	2025-12-18 04:35:47.886	5607
560703	560703	แม่สุก	Mae Suk	56130	2025-12-18 04:35:47.887	5607
560704	560704	ป่าแฝก	Pa Faek	56130	2025-12-18 04:35:47.888	5607
560705	560705	บ้านเหล่า	Ban Lao	56130	2025-12-18 04:35:47.889	5607
560706	560706	เจริญราษฎร์	Charoen Rat	56130	2025-12-18 04:35:47.89	5607
560801	560801	ภูซาง	Phu Sang	56110	2025-12-18 04:35:47.891	5608
560802	560802	ป่าสัก	Pa Sak	56110	2025-12-18 04:35:47.892	5608
560803	560803	ทุ่งกล้วย	Thung Kluai	56110	2025-12-18 04:35:47.893	5608
560804	560804	เชียงแรง	Chiang Raeng	56110	2025-12-18 04:35:47.894	5608
560805	560805	สบบง	Sop Bong	56110	2025-12-18 04:35:47.894	5608
560901	560901	ห้วยแก้ว	Huai Kaeo	56000	2025-12-18 04:35:47.895	5609
560902	560902	ดงเจน	Dong Chen	56000	2025-12-18 04:35:47.896	5609
560903	560903	แม่อิง	Mae Ing	56000	2025-12-18 04:35:47.897	5609
570101	570101	เวียง	Wiang	57000	2025-12-18 04:35:47.898	5701
570102	570102	รอบเวียง	Rop Wiang	57000	2025-12-18 04:35:47.899	5701
570103	570103	บ้านดู่	Ban Du	57100	2025-12-18 04:35:47.9	5701
570104	570104	นางแล	Nang Lae	57100	2025-12-18 04:35:47.901	5701
570105	570105	แม่ข้าวต้ม	Mae Khao Tom	57100	2025-12-18 04:35:47.902	5701
570106	570106	แม่ยาว	Mae Yao	57100	2025-12-18 04:35:47.903	5701
570107	570107	สันทราย	San Sai	57000	2025-12-18 04:35:47.904	5701
570111	570111	แม่กรณ์	Mae Kon	57000	2025-12-18 04:35:47.905	5701
570112	570112	ห้วยชมภู	Huai Chomphu	57000	2025-12-18 04:35:47.905	5701
570113	570113	ห้วยสัก	Huai Sak	57000	2025-12-18 04:35:47.906	5701
570114	570114	ริมกก	Rim Kok	57100	2025-12-18 04:35:47.907	5701
570115	570115	ดอยลาน	Doi Lan	57000	2025-12-18 04:35:47.908	5701
400114	400114	ศิลา	Sila	40000	2025-12-18 04:35:43.764	4001
570116	570116	ป่าอ้อดอนชัย	Pa O Don Chai	57000	2025-12-18 04:35:47.909	5701
570118	570118	ท่าสาย	Tha Sai	57000	2025-12-18 04:35:47.91	5701
570120	570120	ดอยฮาง	Doi Hang	57000	2025-12-18 04:35:47.911	5701
570121	570121	ท่าสุด	Tha Sut	57100	2025-12-18 04:35:47.912	5701
570202	570202	เวียงชัย	Wiang Chai	57210	2025-12-18 04:35:47.913	5702
570203	570203	ผางาม	Pha Ngam	57210	2025-12-18 04:35:47.914	5702
570204	570204	เวียงเหนือ	Wiang Nuea	57210	2025-12-18 04:35:47.915	5702
570206	570206	ดอนศิลา	Don Sila	57210	2025-12-18 04:35:47.916	5702
570208	570208	เมืองชุม	Mueang Chum	57210	2025-12-18 04:35:47.917	5702
570301	570301	เวียง	Wiang	57140	2025-12-18 04:35:47.918	5703
570302	570302	สถาน	Sathan	57140	2025-12-18 04:35:47.918	5703
570303	570303	ครึ่ง	Khrueng	57140	2025-12-18 04:35:47.921	5703
570304	570304	บุญเรือง	Bun Rueang	57140	2025-12-18 04:35:47.921	5703
570305	570305	ห้วยซ้อ	Huai So	57140	2025-12-18 04:35:47.922	5703
570308	570308	ศรีดอนชัย	Si Don Chai	57230	2025-12-18 04:35:47.923	5703
570310	570310	ริมโขง	Rim Khong	57140	2025-12-18 04:35:47.924	5703
570401	570401	เวียง	Wiang	57160	2025-12-18 04:35:47.925	5704
570402	570402	งิ้ว	Ngio	57160	2025-12-18 04:35:47.926	5704
570403	570403	ปล้อง	Plong	57230	2025-12-18 04:35:47.927	5704
570404	570404	แม่ลอย	Mae Loi	57230	2025-12-18 04:35:47.928	5704
570405	570405	เชียงเคี่ยน	Chiang Khian	57230	2025-12-18 04:35:47.929	5704
570409	570409	ตับเต่า	Tap Tao	57160	2025-12-18 04:35:47.93	5704
570410	570410	หงาว	Ngao	57160	2025-12-18 04:35:47.931	5704
570411	570411	สันทรายงาม	San Sai Ngam	57160	2025-12-18 04:35:47.932	5704
570412	570412	ศรีดอนไชย	Si Don Chai	57160	2025-12-18 04:35:47.933	5704
570413	570413	หนองแรด	Nong Raet	57160	2025-12-18 04:35:47.933	5704
570501	570501	สันมะเค็ด	San Makhet	57120	2025-12-18 04:35:47.934	5705
570502	570502	แม่อ้อ	Mae O	57120	2025-12-18 04:35:47.935	5705
570503	570503	ธารทอง	Than Thong	57250	2025-12-18 04:35:47.936	5705
570504	570504	สันติสุข	Santi Suk	57120	2025-12-18 04:35:47.937	5705
570505	570505	ดอยงาม	Doi Ngam	57120	2025-12-18 04:35:47.938	5705
570506	570506	หัวง้ม	Hua Ngom	57120	2025-12-18 04:35:47.939	5705
570507	570507	เจริญเมือง	Charoen Mueang	57120	2025-12-18 04:35:47.94	5705
570508	570508	ป่าหุ่ง	Pa Hung	57120	2025-12-18 04:35:47.941	5705
570509	570509	ม่วงคำ	Muang Kham	57120	2025-12-18 04:35:47.942	5705
570510	570510	ทรายขาว	Sai Khao	57120	2025-12-18 04:35:47.943	5705
570511	570511	สันกลาง	San Klang	57120	2025-12-18 04:35:47.944	5705
570512	570512	แม่เย็น	Mae Yen	57280	2025-12-18 04:35:47.944	5705
570513	570513	เมืองพาน	Mueang Phan	57120	2025-12-18 04:35:47.945	5705
570514	570514	ทานตะวัน	Than Tawan	57280	2025-12-18 04:35:47.946	5705
570515	570515	เวียงห้าว	Wiang Hao	57120	2025-12-18 04:35:47.947	5705
570601	570601	ป่าแดด	Pa Daet	57190	2025-12-18 04:35:47.948	5706
570602	570602	ป่าแงะ	Pa Ngae	57190	2025-12-18 04:35:47.949	5706
570603	570603	สันมะค่า	San Makha	57190	2025-12-18 04:35:47.95	5706
570605	570605	โรงช้าง	Rong Chang	57190	2025-12-18 04:35:47.951	5706
570606	570606	ศรีโพธิ์เงิน	Si Pho Ngoen	57190	2025-12-18 04:35:47.952	5706
570701	570701	แม่จัน	Mae Chan	57110	2025-12-18 04:35:47.953	5707
570702	570702	จันจว้า	Chan Chwa	57270	2025-12-18 04:35:47.954	5707
570703	570703	แม่คำ	Mae Kham	57240	2025-12-18 04:35:47.955	5707
570704	570704	ป่าซาง	Pa Sang	57110	2025-12-18 04:35:47.956	5707
570705	570705	สันทราย	San Sai	57110	2025-12-18 04:35:47.956	5707
570706	570706	ท่าข้าวเปลือก	Tha Khao Plueak	57110	2025-12-18 04:35:47.957	5707
570708	570708	ป่าตึง	Pa Tueng	57110	2025-12-18 04:35:47.958	5707
570710	570710	แม่ไร่	Mae Rai	57240	2025-12-18 04:35:47.959	5707
570711	570711	ศรีค้ำ	Si Kham	57110	2025-12-18 04:35:47.96	5707
570712	570712	จันจว้าใต้	Chan Chwa Tai	57270	2025-12-18 04:35:47.961	5707
570713	570713	จอมสวรรค์	Chom Sawan	57110	2025-12-18 04:35:47.962	5707
570801	570801	เวียง	Wiang	57150	2025-12-18 04:35:47.963	5708
570802	570802	ป่าสัก	Pa Sak	57150	2025-12-18 04:35:47.964	5708
570803	570803	บ้านแซว	Ban Saeo	57150	2025-12-18 04:35:47.965	5708
570804	570804	ศรีดอนมูล	Si Don Mun	57150	2025-12-18 04:35:47.965	5708
570805	570805	แม่เงิน	Mae Ngoen	57150	2025-12-18 04:35:47.966	5708
570806	570806	โยนก	Yonok	57150	2025-12-18 04:35:47.967	5708
570901	570901	แม่สาย	Mae Sai	57130	2025-12-18 04:35:47.968	5709
570902	570902	ห้วยไคร้	Huai Khrai	57220	2025-12-18 04:35:47.969	5709
570903	570903	เกาะช้าง	Ko Chang	57130	2025-12-18 04:35:47.97	5709
570904	570904	โป่งผา	Pong Pha	57130	2025-12-18 04:35:47.971	5709
570905	570905	ศรีเมืองชุม	Si Mueang Chum	57130	2025-12-18 04:35:47.972	5709
570906	570906	เวียงพางคำ	Wiang Phang Kham	57130	2025-12-18 04:35:47.973	5709
570908	570908	บ้านด้าย	Ban Dai	57220	2025-12-18 04:35:47.974	5709
570909	570909	โป่งงาม	Pong Ngam	57130	2025-12-18 04:35:47.975	5709
571001	571001	แม่สรวย	Mae Suai	57180	2025-12-18 04:35:47.976	5710
571002	571002	ป่าแดด	Pa Daet	57180	2025-12-18 04:35:47.977	5710
571003	571003	แม่พริก	Mae Phrik	57180	2025-12-18 04:35:47.977	5710
571004	571004	ศรีถ้อย	Si Thoi	57180	2025-12-18 04:35:47.978	5710
571005	571005	ท่าก๊อ	Tha Ko	57180	2025-12-18 04:35:47.979	5710
571006	571006	วาวี	Wawi	57180	2025-12-18 04:35:47.98	5710
571007	571007	เจดีย์หลวง	Chedi Luang	57180	2025-12-18 04:35:47.981	5710
571101	571101	สันสลี	San Sali	57170	2025-12-18 04:35:47.982	5711
571102	571102	เวียง	Wiang	57170	2025-12-18 04:35:47.983	5711
571103	571103	บ้านโป่ง	Ban Pong	57170	2025-12-18 04:35:47.984	5711
571104	571104	ป่างิ้ว	Pa Ngio	57170	2025-12-18 04:35:47.985	5711
110401	110401	ตลาด	Talat	10130	2025-12-18 04:35:38.833	1104
571105	571105	เวียงกาหลง	Wiang Kalong	57260	2025-12-18 04:35:47.986	5711
571106	571106	แม่เจดีย์	Mae Chedi	57260	2025-12-18 04:35:47.987	5711
571107	571107	แม่เจดีย์ใหม่	Mae Chedi Mai	57260	2025-12-18 04:35:47.988	5711
571201	571201	แม่เปา	Mae Pao	57290	2025-12-18 04:35:47.989	5712
571202	571202	แม่ต๋ำ	Mae Tam	57290	2025-12-18 04:35:47.99	5712
571203	571203	ไม้ยา	Mai Ya	57290	2025-12-18 04:35:47.99	5712
571204	571204	เม็งราย	Mengrai	57290	2025-12-18 04:35:47.991	5712
571205	571205	ตาดควัน	Tat Khwan	57290	2025-12-18 04:35:47.992	5712
571301	571301	ม่วงยาย	Muang Yai	57310	2025-12-18 04:35:47.993	5713
571302	571302	ปอ	Por	57310	2025-12-18 04:35:47.994	5713
571303	571303	หล่ายงาว	Lai Ngao	57310	2025-12-18 04:35:47.995	5713
571304	571304	ท่าข้าม	Tha Kham	57310	2025-12-18 04:35:47.996	5713
571402	571402	ป่าตาล	Pa Tan	57340	2025-12-18 04:35:47.998	5714
571403	571403	ยางฮอม	Yang Hom	57340	2025-12-18 04:35:47.999	5714
571501	571501	เทอดไทย	Thoet Thai	57240	2025-12-18 04:35:48	5715
571502	571502	แม่สลองใน	Mae Salong Nai	57110	2025-12-18 04:35:48.001	5715
571503	571503	แม่สลองนอก	Mae Salong Nok	57110	2025-12-18 04:35:48.001	5715
571504	571504	แม่ฟ้าหลวง	Mae Fa Luang	57240	2025-12-18 04:35:48.002	5715
571601	571601	ดงมะดะ	Dong Mada	57250	2025-12-18 04:35:48.003	5716
571602	571602	จอมหมอกแก้ว	Chom Mok Kaeo	57250	2025-12-18 04:35:48.004	5716
571603	571603	บัวสลี	Bua Sali	57250	2025-12-18 04:35:48.005	5716
571604	571604	ป่าก่อดำ	Pa Ko Dam	57250	2025-12-18 04:35:48.006	5716
571605	571605	โป่งแพร่	Pong Phrae	57000	2025-12-18 04:35:48.007	5716
571701	571701	ทุ่งก่อ	Thung Ko	57210	2025-12-18 04:35:48.008	5717
571702	571702	ดงมหาวัน	Dong Maha Wan	57210	2025-12-18 04:35:48.009	5717
571703	571703	ป่าซาง	Pa Sang	57210	2025-12-18 04:35:48.01	5717
571801	571801	ปงน้อย	Pong Noi	57110	2025-12-18 04:35:48.011	5718
571802	571802	โชคชัย	Chok Chai	57110	2025-12-18 04:35:48.012	5718
571803	571803	หนองป่าก่อ	Nong Pa Ko	57110	2025-12-18 04:35:48.013	5718
580101	580101	จองคำ	Chong Kham	58000	2025-12-18 04:35:48.014	5801
580102	580102	ห้วยโป่ง	Huai Pong	58000	2025-12-18 04:35:48.015	5801
580103	580103	ผาบ่อง	Pha Bong	58000	2025-12-18 04:35:48.015	5801
580104	580104	ปางหมู	Pang Mu	58000	2025-12-18 04:35:48.016	5801
580105	580105	หมอกจำแป่	Mok Champae	58000	2025-12-18 04:35:48.017	5801
580106	580106	ห้วยผา	Huai Pha	58000	2025-12-18 04:35:48.019	5801
580109	580109	ห้วยปูลิง	Huai Pu Ling	58000	2025-12-18 04:35:48.02	5801
580201	580201	ขุนยวม	Khun Yuam	58140	2025-12-18 04:35:48.02	5802
580202	580202	แม่เงา	Mae Ngao	58140	2025-12-18 04:35:48.021	5802
580203	580203	เมืองปอน	Mueang Pon	58140	2025-12-18 04:35:48.022	5802
580204	580204	แม่ยวมน้อย	Mae Yuam Noi	58140	2025-12-18 04:35:48.023	5802
580205	580205	แม่กิ๊	Mae Ki	58140	2025-12-18 04:35:48.024	5802
580206	580206	แม่อูคอ	Mae Uo Kor	58140	2025-12-18 04:35:48.025	5802
580301	580301	เวียงใต้	Wiang Tai	58130	2025-12-18 04:35:48.026	5803
580302	580302	เวียงเหนือ	Wiang Nuea	58130	2025-12-18 04:35:48.027	5803
580303	580303	แม่นาเติง	Mae Na Toeng	58130	2025-12-18 04:35:48.028	5803
580304	580304	แม่ฮี้	Mae Hi	58130	2025-12-18 04:35:48.029	5803
580305	580305	ทุ่งยาว	Thung Yao	58130	2025-12-18 04:35:48.03	5803
580306	580306	เมืองแปง	Mueang Paeng	58130	2025-12-18 04:35:48.03	5803
580307	580307	โป่งสา	Pong Sa	58130	2025-12-18 04:35:48.031	5803
580401	580401	บ้านกาศ	Ban Kat	58110	2025-12-18 04:35:48.032	5804
580402	580402	แม่สะเรียง	Mae Sariang	58110	2025-12-18 04:35:48.033	5804
580403	580403	แม่คง	Mae Khong	58110	2025-12-18 04:35:48.034	5804
580404	580404	แม่เหาะ	Mae Ho	58110	2025-12-18 04:35:48.035	5804
580405	580405	แม่ยวม	Mae Yuam	58110	2025-12-18 04:35:48.036	5804
580406	580406	เสาหิน	Sao Hin	58110	2025-12-18 04:35:48.037	5804
580408	580408	ป่าแป๋	Pa Pae	58110	2025-12-18 04:35:48.038	5804
580501	580501	แม่ลาน้อย	Mae La Noi	58120	2025-12-18 04:35:48.039	5805
580502	580502	แม่ลาหลวง	Mae La Luang	58120	2025-12-18 04:35:48.039	5805
580503	580503	ท่าผาปุ้ม	Tha Pha Pum	58120	2025-12-18 04:35:48.04	5805
580504	580504	แม่โถ	Mae Tho	58120	2025-12-18 04:35:48.041	5805
580505	580505	ห้วยห้อม	Huai Hom	58120	2025-12-18 04:35:48.042	5805
580506	580506	แม่นาจาง	Mae Na Chang	58120	2025-12-18 04:35:48.043	5805
580507	580507	สันติคีรี	Santi Khiri	58120	2025-12-18 04:35:48.044	5805
580508	580508	ขุนแม่ลาน้อย	Khun Mae La Noi	58120	2025-12-18 04:35:48.045	5805
580601	580601	สบเมย	Sop Moei	58110	2025-12-18 04:35:48.046	5806
580602	580602	แม่คะตวน	Mae Khatuan	58110	2025-12-18 04:35:48.047	5806
580603	580603	กองก๋อย	Kong Koi	58110	2025-12-18 04:35:48.048	5806
580604	580604	แม่สวด	Mae Suat	58110	2025-12-18 04:35:48.049	5806
580605	580605	ป่าโปง	Pa Pong	58110	2025-12-18 04:35:48.05	5806
580606	580606	แม่สามแลบ	Mae Sam Laep	58110	2025-12-18 04:35:48.051	5806
580701	580701	สบป่อง	Sop Pong	58150	2025-12-18 04:35:48.052	5807
580702	580702	ปางมะผ้า	Pang Mapha	58150	2025-12-18 04:35:48.053	5807
580703	580703	ถ้ำลอด	Tham Lot	58150	2025-12-18 04:35:48.054	5807
580704	580704	นาปู่ป้อม	Na Pu Pom	58150	2025-12-18 04:35:48.054	5807
600101	600101	ปากน้ำโพ	Paknam Pho	60000	2025-12-18 04:35:48.055	6001
600102	600102	กลางแดด	Klang Daet	60000	2025-12-18 04:35:48.056	6001
600103	600103	เกรียงไกร	Kriangkrai	60000	2025-12-18 04:35:48.058	6001
600104	600104	แควใหญ่	Khwae Yai	60000	2025-12-18 04:35:48.059	6001
600105	600105	ตะเคียนเลื่อน	Takhian Luean	60000	2025-12-18 04:35:48.06	6001
600106	600106	นครสวรรค์ตก	Nakhon Sawan Tok	60000	2025-12-18 04:35:48.061	6001
110402	110402	บางพึ่ง	Bang Phueng	10130	2025-12-18 04:35:38.834	1104
600107	600107	นครสวรรค์ออก	Nakhon Sawan Ok	60000	2025-12-18 04:35:48.062	6001
600108	600108	บางพระหลวง	Bang Phra Luang	60000	2025-12-18 04:35:48.063	6001
600109	600109	บางม่วง	Bang Muang	60000	2025-12-18 04:35:48.064	6001
600110	600110	บ้านมะเกลือ	Ban Makluea	60000	2025-12-18 04:35:48.064	6001
600111	600111	บ้านแก่ง	Ban Kaeng	60000	2025-12-18 04:35:48.065	6001
600112	600112	พระนอน	Phra Non	60000	2025-12-18 04:35:48.067	6001
600113	600113	วัดไทร	Wat Sai	60000	2025-12-18 04:35:48.068	6001
600114	600114	หนองกรด	Nong Krot	60240	2025-12-18 04:35:48.069	6001
600115	600115	หนองกระโดน	Nong Kradon	60240	2025-12-18 04:35:48.069	6001
600116	600116	หนองปลิง	Nong Pling	60000	2025-12-18 04:35:48.07	6001
600117	600117	บึงเสนาท	Bueng Senat	60000	2025-12-18 04:35:48.071	6001
600201	600201	โกรกพระ	Krok Phra	60170	2025-12-18 04:35:48.072	6002
600202	600202	ยางตาล	Yang Tan	60170	2025-12-18 04:35:48.073	6002
600203	600203	บางมะฝ่อ	Bang Mafo	60170	2025-12-18 04:35:48.074	6002
600204	600204	บางประมุง	Bang Pramung	60170	2025-12-18 04:35:48.075	6002
600205	600205	นากลาง	Na Klang	60170	2025-12-18 04:35:48.076	6002
600206	600206	ศาลาแดง	Sala Daeng	60170	2025-12-18 04:35:48.077	6002
600207	600207	เนินกว้าว	Noen Kwao	60170	2025-12-18 04:35:48.078	6002
600208	600208	เนินศาลา	Noen Sala	60170	2025-12-18 04:35:48.079	6002
600209	600209	หาดสูง	Hat Sung	60170	2025-12-18 04:35:48.08	6002
600301	600301	ชุมแสง	Chum Saeng	60120	2025-12-18 04:35:48.081	6003
600302	600302	ทับกฤช	Thap Krit	60250	2025-12-18 04:35:48.082	6003
600303	600303	พิกุล	Phikun	60120	2025-12-18 04:35:48.083	6003
600304	600304	เกยไชย	Koei Chai	60120	2025-12-18 04:35:48.083	6003
600305	600305	ท่าไม้	Tha Mai	60120	2025-12-18 04:35:48.084	6003
600306	600306	บางเคียน	Bang Khian	60120	2025-12-18 04:35:48.085	6003
600307	600307	หนองกระเจา	Nong Krachao	60120	2025-12-18 04:35:48.086	6003
600308	600308	พันลาน	Phan Lan	60250	2025-12-18 04:35:48.087	6003
600309	600309	โคกหม้อ	Khok Mo	60120	2025-12-18 04:35:48.088	6003
600310	600310	ไผ่สิงห์	Phai Sing	60120	2025-12-18 04:35:48.09	6003
600311	600311	ฆะมัง	Khamang	60120	2025-12-18 04:35:48.092	6003
600312	600312	ทับกฤชใต้	Thap Krit Tai	60250	2025-12-18 04:35:48.094	6003
600401	600401	หนองบัว	Nong Bua	60110	2025-12-18 04:35:48.096	6004
600402	600402	หนองกลับ	Nong Klap	60110	2025-12-18 04:35:48.097	6004
600403	600403	ธารทหาร	Than Thahan	60110	2025-12-18 04:35:48.098	6004
600404	600404	ห้วยร่วม	Huai Ruam	60110	2025-12-18 04:35:48.099	6004
600405	600405	ห้วยถั่วใต้	Huai Thua Tai	60110	2025-12-18 04:35:48.099	6004
600406	600406	ห้วยถั่วเหนือ	Huai Thua Nuea	60110	2025-12-18 04:35:48.1	6004
600407	600407	ห้วยใหญ่	Huai Yai	60110	2025-12-18 04:35:48.101	6004
600408	600408	ทุ่งทอง	Thung Thong	60110	2025-12-18 04:35:48.102	6004
600409	600409	วังบ่อ	Wang Bo	60110	2025-12-18 04:35:48.103	6004
600501	600501	ท่างิ้ว	Tha Ngio	60180	2025-12-18 04:35:48.104	6005
600502	600502	บางตาหงาย	Bang Ta Ngai	60180	2025-12-18 04:35:48.105	6005
600503	600503	หูกวาง	Hukwang	60180	2025-12-18 04:35:48.106	6005
600504	600504	อ่างทอง	Ang Thong	60180	2025-12-18 04:35:48.107	6005
600505	600505	บ้านแดน	Ban Daen	60180	2025-12-18 04:35:48.108	6005
600506	600506	บางแก้ว	Bang Kaeo	60180	2025-12-18 04:35:48.109	6005
600507	600507	ตาขีด	Ta Khit	60180	2025-12-18 04:35:48.11	6005
600508	600508	ตาสัง	Ta Sang	60180	2025-12-18 04:35:48.111	6005
600509	600509	ด่านช้าง	Dan Chang	60180	2025-12-18 04:35:48.112	6005
600510	600510	หนองกรด	Nong Krot	60180	2025-12-18 04:35:48.113	6005
600511	600511	หนองตางู	Nong Ta Ngu	60180	2025-12-18 04:35:48.114	6005
600512	600512	บึงปลาทู	Bueng Pla Thu	60180	2025-12-18 04:35:48.115	6005
600513	600513	เจริญผล	Charoen Phon	60180	2025-12-18 04:35:48.116	6005
600601	600601	มหาโพธิ	Maha Phot	60230	2025-12-18 04:35:48.117	6006
600602	600602	เก้าเลี้ยว	Kao Liao	60230	2025-12-18 04:35:48.118	6006
600603	600603	หนองเต่า	Nong Tao	60230	2025-12-18 04:35:48.119	6006
600604	600604	เขาดิน	Khao Din	60230	2025-12-18 04:35:48.12	6006
600605	600605	หัวดง	Hua Dong	60230	2025-12-18 04:35:48.121	6006
600701	600701	ตาคลี	Takhli	60140	2025-12-18 04:35:48.122	6007
600702	600702	ช่องแค	Chong Khae	60210	2025-12-18 04:35:48.123	6007
600703	600703	จันเสน	Chan Sen	60260	2025-12-18 04:35:48.124	6007
600704	600704	ห้วยหอม	Huai Hom	60210	2025-12-18 04:35:48.125	6007
600705	600705	หัวหวาย	Hua Wai	60140	2025-12-18 04:35:48.126	6007
600706	600706	หนองโพ	Nong Pho	60140	2025-12-18 04:35:48.127	6007
600707	600707	หนองหม้อ	Nong Mo	60140	2025-12-18 04:35:48.128	6007
600708	600708	สร้อยทอง	Soi Thong	60210	2025-12-18 04:35:48.129	6007
600709	600709	ลาดทิพรส	Lat Thippharot	60260	2025-12-18 04:35:48.13	6007
600710	600710	พรหมนิมิต	Phrom Nimit	60210	2025-12-18 04:35:48.131	6007
600801	600801	ท่าตะโก	Tha Tako	60160	2025-12-18 04:35:48.132	6008
600802	600802	พนมรอก	Phanom Rok	60160	2025-12-18 04:35:48.133	6008
600803	600803	หัวถนน	Hua Thanon	60160	2025-12-18 04:35:48.134	6008
600804	600804	สายลำโพง	Sai Lamphong	60160	2025-12-18 04:35:48.136	6008
600805	600805	วังมหากร	Wang Mahakon	60160	2025-12-18 04:35:48.137	6008
600806	600806	ดอนคา	Don Kha	60160	2025-12-18 04:35:48.138	6008
600807	600807	ทำนบ	Thamnop	60160	2025-12-18 04:35:48.139	6008
600808	600808	วังใหญ่	Wang Yai	60160	2025-12-18 04:35:48.14	6008
600809	600809	พนมเศษ	Phanom Set	60160	2025-12-18 04:35:48.141	6008
600810	600810	หนองหลวง	Nong Luang	60160	2025-12-18 04:35:48.142	6008
600901	600901	โคกเดื่อ	Khok Duea	60220	2025-12-18 04:35:48.143	6009
600902	600902	สำโรงชัย	Samrong Chai	60220	2025-12-18 04:35:48.144	6009
600903	600903	วังน้ำลัด	Wang Nam Lat	60220	2025-12-18 04:35:48.145	6009
600904	600904	ตะคร้อ	Takhro	60220	2025-12-18 04:35:48.146	6009
600905	600905	โพธิ์ประสาท	Pho Prasat	60220	2025-12-18 04:35:48.147	6009
600906	600906	วังข่อย	Wang Khoi	60220	2025-12-18 04:35:48.148	6009
600907	600907	นาขอม	Na Khom	60220	2025-12-18 04:35:48.149	6009
600908	600908	ไพศาลี	Phaisali	60220	2025-12-18 04:35:48.15	6009
601001	601001	พยุหะ	Phayuha	60130	2025-12-18 04:35:48.151	6010
601002	601002	เนินมะกอก	Noen Makok	60130	2025-12-18 04:35:48.152	6010
601003	601003	นิคมเขาบ่อแก้ว	Nikhom Khao Bo Kaeo	60130	2025-12-18 04:35:48.153	6010
601004	601004	ม่วงหัก	Muang Hak	60130	2025-12-18 04:35:48.154	6010
601005	601005	ยางขาว	Yang Khao	60130	2025-12-18 04:35:48.155	6010
601006	601006	ย่านมัทรี	Yan Matsi	60130	2025-12-18 04:35:48.156	6010
601007	601007	เขาทอง	Khao Thong	60130	2025-12-18 04:35:48.157	6010
601008	601008	ท่าน้ำอ้อย	Tha Nam Oi	60130	2025-12-18 04:35:48.158	6010
601009	601009	น้ำทรง	Nam Song	60130	2025-12-18 04:35:48.159	6010
601010	601010	เขากะลา	Khao Kala	60130	2025-12-18 04:35:48.16	6010
601011	601011	สระทะเล	Sa Thale	60130	2025-12-18 04:35:48.161	6010
601101	601101	ลาดยาว	Lat Yao	60150	2025-12-18 04:35:48.162	6011
601102	601102	ห้วยน้ำหอม	Huai Nam Hom	60150	2025-12-18 04:35:48.163	6011
601103	601103	วังม้า	Wang Ma	60150	2025-12-18 04:35:48.164	6011
601104	601104	วังเมือง	Wang Mueang	60150	2025-12-18 04:35:48.165	6011
601105	601105	สร้อยละคร	Soi Lakhon	60150	2025-12-18 04:35:48.166	6011
601106	601106	มาบแก	Map Kae	60150	2025-12-18 04:35:48.167	6011
601107	601107	หนองยาว	Nong Yao	60150	2025-12-18 04:35:48.168	6011
601108	601108	หนองนมวัว	Nong Nom Wua	60150	2025-12-18 04:35:48.169	6011
601109	601109	บ้านไร่	Ban Rai	60150	2025-12-18 04:35:48.17	6011
601110	601110	เนินขี้เหล็ก	Noen Khilek	60150	2025-12-18 04:35:48.171	6011
601116	601116	ศาลเจ้าไก่ต่อ	San Chao Kai To	60150	2025-12-18 04:35:48.172	6011
601117	601117	สระแก้ว	Sa Kaeo	60150	2025-12-18 04:35:48.173	6011
601201	601201	ตากฟ้า	Tak Fa	60190	2025-12-18 04:35:48.174	6012
601202	601202	ลำพยนต์	Lam Phayon	60190	2025-12-18 04:35:48.175	6012
601203	601203	สุขสำราญ	Suk Samran	60190	2025-12-18 04:35:48.176	6012
601204	601204	หนองพิกุล	Nong Phikun	60190	2025-12-18 04:35:48.177	6012
601205	601205	พุนกยูง	Phu Nok Yung	60190	2025-12-18 04:35:48.177	6012
601206	601206	อุดมธัญญา	Udom Thanya	60190	2025-12-18 04:35:48.178	6012
601207	601207	เขาชายธง	Khao Chai Thong	60190	2025-12-18 04:35:48.179	6012
601301	601301	แม่วงก์	Mae Wong	60150	2025-12-18 04:35:48.18	6013
601303	601303	แม่เล่ย์	Mae Le	60150	2025-12-18 04:35:48.181	6013
601305	601305	เขาชนกัน	Khao Chon Kan	60150	2025-12-18 04:35:48.183	6013
601401	601401	แม่เปิน	Mae Poen	60150	2025-12-18 04:35:48.184	6014
601501	601501	ชุมตาบง	Chum Ta Bong	60150	2025-12-18 04:35:48.185	6015
601502	601502	ปางสวรรค์	Pang Sawan	60150	2025-12-18 04:35:48.186	6015
610101	610101	อุทัยใหม่	Uthai Mai	61000	2025-12-18 04:35:48.187	6101
610102	610102	น้ำซึม	Nam Suem	61000	2025-12-18 04:35:48.188	6101
610103	610103	สะแกกรัง	Sakae Krang	61000	2025-12-18 04:35:48.189	6101
610104	610104	ดอนขวาง	Don Khwang	61000	2025-12-18 04:35:48.19	6101
610105	610105	หาดทนง	Hat Thanong	61000	2025-12-18 04:35:48.191	6101
610106	610106	เกาะเทโพ	Ko Thepho	61000	2025-12-18 04:35:48.192	6101
610107	610107	ท่าซุง	Tha Sung	61000	2025-12-18 04:35:48.193	6101
610108	610108	หนองแก	Nong Kae	61000	2025-12-18 04:35:48.194	6101
610109	610109	โนนเหล็ก	Non Lek	61000	2025-12-18 04:35:48.195	6101
610110	610110	หนองเต่า	Nong Tao	61000	2025-12-18 04:35:48.196	6101
610111	610111	หนองไผ่แบน	Nong Phai Baen	61000	2025-12-18 04:35:48.197	6101
610112	610112	หนองพังค่า	Nong Phang Kha	61000	2025-12-18 04:35:48.197	6101
610113	610113	ทุ่งใหญ่	Thung Yai	61000	2025-12-18 04:35:48.198	6101
610114	610114	เนินแจง	Noen Chaeng	61000	2025-12-18 04:35:48.199	6101
610201	610201	ทัพทัน	Thap Than	61120	2025-12-18 04:35:48.2	6102
610202	610202	ทุ่งนาไทย	Thung Na Thai	61120	2025-12-18 04:35:48.201	6102
610203	610203	เขาขี้ฝอย	Khao Khi Foi	61120	2025-12-18 04:35:48.202	6102
610204	610204	หนองหญ้าปล้อง	Nong Ya Plong	61120	2025-12-18 04:35:48.203	6102
610205	610205	โคกหม้อ	Khok Mo	61120	2025-12-18 04:35:48.204	6102
610206	610206	หนองยายดา	Nong Yai Da	61120	2025-12-18 04:35:48.205	6102
610207	610207	หนองกลางดง	Nong Klang Dong	61120	2025-12-18 04:35:48.206	6102
610208	610208	หนองกระทุ่ม	Nong Krathum	61120	2025-12-18 04:35:48.207	6102
610209	610209	หนองสระ	Nong Sa	61120	2025-12-18 04:35:48.208	6102
610210	610210	ตลุกดู่	Taluk Du	61120	2025-12-18 04:35:48.209	6102
610301	610301	สว่างอารมณ์	Sawang Arom	61150	2025-12-18 04:35:48.21	6103
610302	610302	หนองหลวง	Nong Luang	61150	2025-12-18 04:35:48.211	6103
610303	610303	พลวงสองนาง	Phluang Song Nang	61150	2025-12-18 04:35:48.212	6103
610304	610304	ไผ่เขียว	Phai Khiao	61150	2025-12-18 04:35:48.212	6103
610305	610305	บ่อยาง	Bor Yang	61150	2025-12-18 04:35:48.213	6103
610401	610401	หนองฉาง	Nong Chang	61110	2025-12-18 04:35:48.214	6104
610402	610402	หนองยาง	Nong Yang	61110	2025-12-18 04:35:48.215	6104
610403	610403	หนองนางนวล	Nong Nang Nuan	61110	2025-12-18 04:35:48.216	6104
610404	610404	หนองสรวง	Nong Suang	61110	2025-12-18 04:35:48.217	6104
610405	610405	บ้านเก่า	Ban Kao	61110	2025-12-18 04:35:48.218	6104
610406	610406	อุทัยเก่า	Uthai Kao	61110	2025-12-18 04:35:48.219	6104
610407	610407	ทุ่งโพ	Thung Pho	61110	2025-12-18 04:35:48.22	6104
610408	610408	ทุ่งพง	Thung Phong	61110	2025-12-18 04:35:48.221	6104
610409	610409	เขาบางแกรก	Khao Bang Kraek	61170	2025-12-18 04:35:48.222	6104
610410	610410	เขากวางทอง	Khao Kwang Thong	61110	2025-12-18 04:35:48.223	6104
610501	610501	หนองขาหย่าง	Nong Khayang	61130	2025-12-18 04:35:48.224	6105
610502	610502	หนองไผ่	Nong Phai	61130	2025-12-18 04:35:48.225	6105
610503	610503	ดอนกลอย	Don Kloi	61130	2025-12-18 04:35:48.226	6105
610504	610504	ห้วยรอบ	Huai Rop	61130	2025-12-18 04:35:48.226	6105
610505	610505	ทุ่งพึ่ง	Thung Phueng	61130	2025-12-18 04:35:48.227	6105
610506	610506	ท่าโพ	Tha Pho	61130	2025-12-18 04:35:48.228	6105
610507	610507	หมกแถว	Mok Thaeo	61130	2025-12-18 04:35:48.229	6105
610508	610508	หลุมเข้า	Lum Khao	61130	2025-12-18 04:35:48.23	6105
610509	610509	ดงขวาง	Dong Kwang	61130	2025-12-18 04:35:48.231	6105
610601	610601	บ้านไร่	Ban Rai	61140	2025-12-18 04:35:48.232	6106
610602	610602	ทัพหลวง	Thap Luang	61140	2025-12-18 04:35:48.233	6106
610603	610603	ห้วยแห้ง	Huai Haeng	61140	2025-12-18 04:35:48.234	6106
610604	610604	คอกควาย	Khok Khwai	61140	2025-12-18 04:35:48.235	6106
610605	610605	วังหิน	Wang Hin	61180	2025-12-18 04:35:48.236	6106
610606	610606	เมืองการุ้ง	Mueang Ka Rung	61180	2025-12-18 04:35:48.237	6106
610607	610607	แก่นมะกรูด	Kaen Makrut	61140	2025-12-18 04:35:48.238	6106
610609	610609	หนองจอก	Nong Chok	61180	2025-12-18 04:35:48.239	6106
610610	610610	หูช้าง	Hu Chang	61180	2025-12-18 04:35:48.24	6106
610612	610612	บ้านใหม่คลองเคียน	Ban Mai Khlong Khian	61180	2025-12-18 04:35:48.242	6106
610613	610613	หนองบ่มกล้วย	Nong Bom Kluai	61180	2025-12-18 04:35:48.243	6106
610614	610614	เจ้าวัด	Chao Wat	61140	2025-12-18 04:35:48.244	6106
610701	610701	ลานสัก	Lan Sak	61160	2025-12-18 04:35:48.244	6107
610702	610702	ประดู่ยืน	Pradu Yuen	61160	2025-12-18 04:35:48.245	6107
610703	610703	ป่าอ้อ	Pa O	61160	2025-12-18 04:35:48.246	6107
610704	610704	ระบำ	Rabam	61160	2025-12-18 04:35:48.247	6107
610705	610705	น้ำรอบ	Nam Rop	61160	2025-12-18 04:35:48.248	6107
610706	610706	ทุ่งนางาม	Thung Na Ngam	61160	2025-12-18 04:35:48.249	6107
610801	610801	สุขฤทัย	Suk Ruethai	61170	2025-12-18 04:35:48.25	6108
610802	610802	ทองหลาง	Thonglang	61170	2025-12-18 04:35:48.251	6108
610803	610803	ห้วยคต	Huai Khot	61170	2025-12-18 04:35:48.252	6108
620101	620101	ในเมือง	Nai Mueang	62000	2025-12-18 04:35:48.253	6201
620102	620102	ไตรตรึงษ์	Trai Trueng	62160	2025-12-18 04:35:48.254	6201
620103	620103	อ่างทอง	Ang Thong	62000	2025-12-18 04:35:48.255	6201
620104	620104	นาบ่อคำ	Na Bo Kham	62000	2025-12-18 04:35:48.256	6201
620105	620105	นครชุม	Nakhon Chum	62000	2025-12-18 04:35:48.257	6201
620106	620106	ทรงธรรม	Song Tham	62000	2025-12-18 04:35:48.258	6201
620107	620107	ลานดอกไม้	Lan Dokmai	62000	2025-12-18 04:35:48.259	6201
620110	620110	หนองปลิง	Nong Pling	62000	2025-12-18 04:35:48.259	6201
620111	620111	คณฑี	Khonthi	62000	2025-12-18 04:35:48.26	6201
620112	620112	นิคมทุ่งโพธิ์ทะเล	Nikhom Thung Pho Thale	62000	2025-12-18 04:35:48.261	6201
620113	620113	เทพนคร	Thep Nakhon	62000	2025-12-18 04:35:48.262	6201
620114	620114	วังทอง	Wang Thong	62000	2025-12-18 04:35:48.263	6201
620115	620115	ท่าขุนราม	Tha Khun Ram	62000	2025-12-18 04:35:48.264	6201
620117	620117	คลองแม่ลาย	Khlong Mae Lai	62000	2025-12-18 04:35:48.265	6201
620118	620118	ธำมรงค์	Thammarong	62160	2025-12-18 04:35:48.266	6201
620119	620119	สระแก้ว	Sa Kaeo	62000	2025-12-18 04:35:48.267	6201
620201	620201	ไทรงาม	Sai Ngam	62150	2025-12-18 04:35:48.268	6202
620202	620202	หนองคล้า	Nong Khla	62150	2025-12-18 04:35:48.269	6202
620203	620203	หนองทอง	Nong Thong	62150	2025-12-18 04:35:48.27	6202
620204	620204	หนองไม้กอง	Nong Mai Kong	62150	2025-12-18 04:35:48.271	6202
620205	620205	มหาชัย	Maha Chai	62150	2025-12-18 04:35:48.272	6202
620206	620206	พานทอง	Phan Thong	62150	2025-12-18 04:35:48.273	6202
620207	620207	หนองแม่แตง	Nong Mae Taeng	62150	2025-12-18 04:35:48.275	6202
620301	620301	คลองน้ำไหล	Khlong Nam Lai	62180	2025-12-18 04:35:48.276	6203
620302	620302	โป่งน้ำร้อน	Pong Nam Ron	62180	2025-12-18 04:35:48.276	6203
620303	620303	คลองลานพัฒนา	Khlong Lan Phatthana	62180	2025-12-18 04:35:48.277	6203
620304	620304	สักงาม	Sak Ngam	62180	2025-12-18 04:35:48.278	6203
620403	620403	ยางสูง	Yang Sung	62130	2025-12-18 04:35:48.279	6204
620404	620404	ป่าพุทรา	Pa Phutsa	62130	2025-12-18 04:35:48.28	6204
620405	620405	แสนตอ	Saen To	62130	2025-12-18 04:35:48.281	6204
620406	620406	สลกบาตร	Salok Bat	62140	2025-12-18 04:35:48.282	6204
620407	620407	บ่อถ้ำ	Bo Tham	62140	2025-12-18 04:35:48.283	6204
620408	620408	ดอนแตง	Don Taeng	62140	2025-12-18 04:35:48.284	6204
620409	620409	วังชะพลู	Wang Chaphlu	62140	2025-12-18 04:35:48.285	6204
620410	620410	โค้งไผ่	Khong Phai	62140	2025-12-18 04:35:48.286	6204
620411	620411	ปางมะค่า	Pang Makha	62140	2025-12-18 04:35:48.287	6204
620412	620412	วังหามแห	Wang Ham Hae	62140	2025-12-18 04:35:48.288	6204
620413	620413	เกาะตาล	Ko Tan	62130	2025-12-18 04:35:48.289	6204
620501	620501	คลองขลุง	Khlong Khlung	62120	2025-12-18 04:35:48.289	6205
620502	620502	ท่ามะเขือ	Tha Makhuea	62120	2025-12-18 04:35:48.29	6205
620504	620504	ท่าพุทรา	Tha Phutsa	62120	2025-12-18 04:35:48.291	6205
620505	620505	แม่ลาด	Mae Lat	62120	2025-12-18 04:35:48.292	6205
620506	620506	วังยาง	Wang Yang	62120	2025-12-18 04:35:48.293	6205
620507	620507	วังแขม	Wang Khaem	62120	2025-12-18 04:35:48.294	6205
620508	620508	หัวถนน	Hua Thanon	62120	2025-12-18 04:35:48.295	6205
620509	620509	วังไทร	Wang Sai	62120	2025-12-18 04:35:48.296	6205
620513	620513	วังบัว	Wang Bua	62120	2025-12-18 04:35:48.297	6205
620516	620516	คลองสมบูรณ์	Khlong Sombun	62120	2025-12-18 04:35:48.298	6205
620601	620601	พรานกระต่าย	Phran Kratai	62110	2025-12-18 04:35:48.299	6206
620602	620602	หนองหัววัว	Nong Hua Wua	62110	2025-12-18 04:35:48.3	6206
620603	620603	ท่าไม้	Tha Mai	62110	2025-12-18 04:35:48.301	6206
620604	620604	วังควง	Wang Khuang	62110	2025-12-18 04:35:48.302	6206
620605	620605	วังตะแบก	Wang Tabaek	62110	2025-12-18 04:35:48.303	6206
620606	620606	เขาคีริส	Khao Khirit	62110	2025-12-18 04:35:48.303	6206
620607	620607	คุยบ้านโอง	Khui Ban Ong	62110	2025-12-18 04:35:48.304	6206
620608	620608	คลองพิไกร	Khlong Phikrai	62110	2025-12-18 04:35:48.305	6206
620609	620609	ถ้ำกระต่ายทอง	Tham Kratai Thong	62110	2025-12-18 04:35:48.306	6206
620610	620610	ห้วยยั้ง	Huai Yang	62110	2025-12-18 04:35:48.307	6206
620701	620701	ลานกระบือ	Lan Krabue	62170	2025-12-18 04:35:48.308	6207
620702	620702	ช่องลม	Chong Lom	62170	2025-12-18 04:35:48.309	6207
620703	620703	หนองหลวง	Nong Luang	62170	2025-12-18 04:35:48.31	6207
620704	620704	โนนพลวง	Non Phluang	62170	2025-12-18 04:35:48.311	6207
620705	620705	ประชาสุขสันต์	Pracha Suk San	62170	2025-12-18 04:35:48.312	6207
620706	620706	บึงทับแรต	Bueng Thap Raet	62170	2025-12-18 04:35:48.313	6207
620707	620707	จันทิมา	Chanthima	62170	2025-12-18 04:35:48.314	6207
620801	620801	ทุ่งทราย	Thung Sai	62190	2025-12-18 04:35:48.315	6208
620802	620802	ทุ่งทอง	Thung Thong	62190	2025-12-18 04:35:48.316	6208
620803	620803	ถาวรวัฒนา	Thawon Watthana	62190	2025-12-18 04:35:48.317	6208
620901	620901	โพธิ์ทอง	Pho Thong	62120	2025-12-18 04:35:48.317	6209
620902	620902	หินดาต	Hin Dat	62120	2025-12-18 04:35:48.318	6209
620903	620903	ปางตาไว	Pang Ta Wai	62120	2025-12-18 04:35:48.319	6209
621001	621001	บึงสามัคคี	Bueng Samakkhi	62210	2025-12-18 04:35:48.32	6210
621002	621002	วังชะโอน	Wang Cha-on	62210	2025-12-18 04:35:48.321	6210
621003	621003	ระหาน	Rahan	62210	2025-12-18 04:35:48.322	6210
621004	621004	เทพนิมิต	Thep Nimit	62210	2025-12-18 04:35:48.323	6210
621101	621101	โกสัมพี	Kosamphi	62000	2025-12-18 04:35:48.324	6211
621102	621102	เพชรชมภู	Phet Chomphu	62000	2025-12-18 04:35:48.325	6211
621103	621103	ลานดอกไม้ตก	Lan Dokmai Tok	62000	2025-12-18 04:35:48.326	6211
630101	630101	ระแหง	Rahaeng	63000	2025-12-18 04:35:48.327	6301
630102	630102	หนองหลวง	Nong Luang	63000	2025-12-18 04:35:48.328	6301
630103	630103	เชียงเงิน	Chiang Ngoen	63000	2025-12-18 04:35:48.329	6301
630104	630104	หัวเดียด	Hua Diat	63000	2025-12-18 04:35:48.33	6301
630105	630105	หนองบัวเหนือ	Nong Bua Nuea	63000	2025-12-18 04:35:48.331	6301
630106	630106	ไม้งาม	Mai Ngam	63000	2025-12-18 04:35:48.332	6301
630107	630107	โป่งแดง	Pong Daeng	63000	2025-12-18 04:35:48.333	6301
630108	630108	น้ำรึม	Nam Ruem	63000	2025-12-18 04:35:48.334	6301
630109	630109	วังหิน	Wang Hin	63000	2025-12-18 04:35:48.334	6301
630111	630111	แม่ท้อ	Mae Tho	63000	2025-12-18 04:35:48.335	6301
630112	630112	ป่ามะม่วง	Pa Mamuang	63000	2025-12-18 04:35:48.337	6301
630113	630113	หนองบัวใต้	Nong Bua Tai	63000	2025-12-18 04:35:48.337	6301
630114	630114	วังประจบ	Wang Prachop	63000	2025-12-18 04:35:48.338	6301
630115	630115	ตลุกกลางทุ่ง	Taluk Klang Thung	63000	2025-12-18 04:35:48.339	6301
630201	630201	ตากออก	Tak Ok	63120	2025-12-18 04:35:48.34	6302
630202	630202	สมอโคน	Samo Khon	63120	2025-12-18 04:35:48.341	6302
630203	630203	แม่สลิด	Mae Salit	63120	2025-12-18 04:35:48.342	6302
630204	630204	ตากตก	Tak Tok	63120	2025-12-18 04:35:48.343	6302
630205	630205	เกาะตะเภา	Ko Taphao	63120	2025-12-18 04:35:48.344	6302
630206	630206	ทุ่งกระเชาะ	Thung Kracho	63120	2025-12-18 04:35:48.345	6302
630207	630207	ท้องฟ้า	Thong Fa	63120	2025-12-18 04:35:48.346	6302
630301	630301	สามเงา	Sam Ngao	63130	2025-12-18 04:35:48.347	6303
630302	630302	วังหมัน	Wang Man	63130	2025-12-18 04:35:48.348	6303
630303	630303	ยกกระบัตร	Yokkrabat	63130	2025-12-18 04:35:48.349	6303
630304	630304	ย่านรี	Yan Ri	63130	2025-12-18 04:35:48.35	6303
630305	630305	บ้านนา	Ban Na	63130	2025-12-18 04:35:48.351	6303
630306	630306	วังจันทร์	Wang Chan	63130	2025-12-18 04:35:48.352	6303
630401	630401	แม่ระมาด	Mae Ramat	63140	2025-12-18 04:35:48.353	6304
630402	630402	แม่จะเรา	Mae Charao	63140	2025-12-18 04:35:48.354	6304
630403	630403	ขะเนจื้อ	Khane Chue	63140	2025-12-18 04:35:48.355	6304
630404	630404	แม่ตื่น	Mae Tuen	63140	2025-12-18 04:35:48.356	6304
630405	630405	สามหมื่น	Sam Muen	63140	2025-12-18 04:35:48.357	6304
630406	630406	พระธาตุ	Phra That	63140	2025-12-18 04:35:48.357	6304
630501	630501	ท่าสองยาง	Tha Song Yang	63150	2025-12-18 04:35:48.358	6305
630502	630502	แม่ต้าน	Mae Tan	63150	2025-12-18 04:35:48.359	6305
630503	630503	แม่สอง	Mae Song	63150	2025-12-18 04:35:48.36	6305
630504	630504	แม่หละ	Mae La	63150	2025-12-18 04:35:48.361	6305
630505	630505	แม่วะหลวง	Mae Wa Luang	63150	2025-12-18 04:35:48.362	6305
630506	630506	แม่อุสุ	Mae Usu	63150	2025-12-18 04:35:48.363	6305
630601	630601	แม่สอด	Mae Sot	63110	2025-12-18 04:35:48.365	6306
630603	630603	พะวอ	Phawo	63110	2025-12-18 04:35:48.368	6306
630604	630604	แม่ตาว	Mae Tao	63110	2025-12-18 04:35:48.369	6306
630605	630605	แม่กาษา	Mae Kasa	63110	2025-12-18 04:35:48.37	6306
630606	630606	ท่าสายลวด	Tha Sai Luat	63110	2025-12-18 04:35:48.371	6306
630607	630607	แม่ปะ	Mae Pa	63110	2025-12-18 04:35:48.373	6306
630608	630608	มหาวัน	Mahawan	63110	2025-12-18 04:35:48.374	6306
630609	630609	ด่านแม่ละเมา	Dan Mae Lamao	63110	2025-12-18 04:35:48.376	6306
630610	630610	พระธาตุผาแดง	Phra That Pha Daeng	63110	2025-12-18 04:35:48.377	6306
630701	630701	พบพระ	Phop Phra	63160	2025-12-18 04:35:48.378	6307
630702	630702	ช่องแคบ	Chong Khaep	63160	2025-12-18 04:35:48.379	6307
630703	630703	คีรีราษฎร์	Khiri Rat	63160	2025-12-18 04:35:48.381	6307
630704	630704	วาเล่ย์	Wale	63160	2025-12-18 04:35:48.383	6307
630705	630705	รวมไทยพัฒนา	Ruam Thai Phatthana	63160	2025-12-18 04:35:48.384	6307
630801	630801	อุ้มผาง	Umphang	63170	2025-12-18 04:35:48.385	6308
630802	630802	หนองหลวง	Nong Luang	63170	2025-12-18 04:35:48.387	6308
630803	630803	โมโกร	Mokro	63170	2025-12-18 04:35:48.388	6308
630804	630804	แม่จัน	Mae Chan	63170	2025-12-18 04:35:48.39	6308
630805	630805	แม่ละมุ้ง	Mae Lamung	63170	2025-12-18 04:35:48.391	6308
630806	630806	แม่กลอง	Mae Klong	63170	2025-12-18 04:35:48.392	6308
630901	630901	เชียงทอง	Chiang Thong	63000	2025-12-18 04:35:48.394	6309
630902	630902	นาโบสถ์	Na Bot	63000	2025-12-18 04:35:48.395	6309
630903	630903	ประดาง	Pradang	63000	2025-12-18 04:35:48.396	6309
640101	640101	ธานี	Thani	64000	2025-12-18 04:35:48.398	6401
640102	640102	บ้านสวน	Ban Suan	64220	2025-12-18 04:35:48.399	6401
640103	640103	เมืองเก่า	Mueang Kao	64210	2025-12-18 04:35:48.4	6401
640104	640104	ปากแคว	Pak Khwae	64000	2025-12-18 04:35:48.402	6401
640105	640105	ยางซ้าย	Yang Sai	64000	2025-12-18 04:35:48.403	6401
640106	640106	บ้านกล้วย	Ban Kluai	64000	2025-12-18 04:35:48.404	6401
640107	640107	บ้านหลุม	Ban Lum	64000	2025-12-18 04:35:48.406	6401
640108	640108	ตาลเตี้ย	Tan Tia	64220	2025-12-18 04:35:48.407	6401
640109	640109	ปากพระ	Pak Phra	64000	2025-12-18 04:35:48.408	6401
640110	640110	วังทองแดง	Wang Thongdaeng	64210	2025-12-18 04:35:48.41	6401
640201	640201	ลานหอย	Lan Hoi	64140	2025-12-18 04:35:48.411	6402
640202	640202	บ้านด่าน	Ban Dan	64140	2025-12-18 04:35:48.412	6402
640203	640203	วังตะคร้อ	Wang Takhro	64140	2025-12-18 04:35:48.414	6402
640204	640204	วังน้ำขาว	Wang Nam Khao	64140	2025-12-18 04:35:48.415	6402
640205	640205	ตลิ่งชัน	Taling Chan	64140	2025-12-18 04:35:48.416	6402
640206	640206	หนองหญ้าปล้อง	Nong Ya Plong	64140	2025-12-18 04:35:48.418	6402
640207	640207	วังลึก	Wang Luek	64140	2025-12-18 04:35:48.419	6402
640301	640301	โตนด	Tanot	64160	2025-12-18 04:35:48.421	6403
640302	640302	ทุ่งหลวง	Thung Luang	64160	2025-12-18 04:35:48.422	6403
640303	640303	บ้านป้อม	Ban Pom	64160	2025-12-18 04:35:48.423	6403
640304	640304	สามพวง	Sam Phuang	64160	2025-12-18 04:35:48.425	6403
640305	640305	ศรีคีรีมาศ	Si Khiri Mat	64160	2025-12-18 04:35:48.426	6403
640306	640306	หนองจิก	Nong Chik	64160	2025-12-18 04:35:48.428	6403
640307	640307	นาเชิงคีรี	Na Choeng Khiri	64160	2025-12-18 04:35:48.43	6403
640308	640308	หนองกระดิ่ง	Nong Krading	64160	2025-12-18 04:35:48.431	6403
640309	640309	บ้านน้ำพุ	Ban Nam Phu	64160	2025-12-18 04:35:48.432	6403
640310	640310	ทุ่งยางเมือง	Thung Yang Mueang	64160	2025-12-18 04:35:48.434	6403
640402	640402	บ้านกร่าง	Ban Krang	64170	2025-12-18 04:35:48.436	6404
640403	640403	ไกรนอก	Krai Nok	64170	2025-12-18 04:35:48.438	6404
640404	640404	ไกรกลาง	Krai Klang	64170	2025-12-18 04:35:48.439	6404
640405	640405	ไกรใน	Krai Nai	64170	2025-12-18 04:35:48.441	6404
640406	640406	ดงเดือย	Dong Dueai	64170	2025-12-18 04:35:48.442	6404
640407	640407	ป่าแฝก	Pa Faek	64170	2025-12-18 04:35:48.443	6404
640408	640408	กกแรต	Kok Raet	64170	2025-12-18 04:35:48.445	6404
640409	640409	ท่าฉนวน	Tha Chanuan	64170	2025-12-18 04:35:48.446	6404
640410	640410	หนองตูม	Nong Tum	64170	2025-12-18 04:35:48.448	6404
640411	640411	บ้านใหม่สุขเกษม	Ban Mai Suk Kasem	64170	2025-12-18 04:35:48.449	6404
640501	640501	หาดเสี้ยว	Hat Siao	64130	2025-12-18 04:35:48.451	6405
640502	640502	ป่างิ้ว	Pa Ngio	64130	2025-12-18 04:35:48.452	6405
640503	640503	แม่สำ	Mae Sam	64130	2025-12-18 04:35:48.454	6405
640504	640504	แม่สิน	Mae Sin	64130	2025-12-18 04:35:48.455	6405
640505	640505	บ้านตึก	Ban Tuek	64130	2025-12-18 04:35:48.457	6405
640506	640506	หนองอ้อ	Nong O	64130	2025-12-18 04:35:48.458	6405
640507	640507	ท่าชัย	Tha Chai	64190	2025-12-18 04:35:48.46	6405
640508	640508	ศรีสัชนาลัย	Si Satchanalai	64190	2025-12-18 04:35:48.461	6405
640509	640509	ดงคู่	Dong Khu	64130	2025-12-18 04:35:48.463	6405
640510	640510	บ้านแก่ง	Ban Kaeng	64130	2025-12-18 04:35:48.464	6405
640511	640511	สารจิตร	San Chit	64130	2025-12-18 04:35:48.466	6405
640601	640601	คลองตาล	Khlong Tan	64120	2025-12-18 04:35:48.467	6406
640602	640602	วังลึก	Wang Luek	64120	2025-12-18 04:35:48.468	6406
640603	640603	สามเรือน	Sam Ruean	64120	2025-12-18 04:35:48.47	6406
640604	640604	บ้านนา	Ban Na	64120	2025-12-18 04:35:48.471	6406
640605	640605	วังทอง	Wang Thong	64120	2025-12-18 04:35:48.473	6406
640606	640606	นาขุนไกร	Na Khun Krai	64120	2025-12-18 04:35:48.474	6406
640607	640607	เกาะตาเลี้ยง	Ko Ta Liang	64120	2025-12-18 04:35:48.476	6406
640608	640608	วัดเกาะ	Wat Ko	64120	2025-12-18 04:35:48.477	6406
640609	640609	บ้านไร่	Ban Rai	64120	2025-12-18 04:35:48.479	6406
640610	640610	ทับผึ้ง	Thap Phueng	64120	2025-12-18 04:35:48.48	6406
640611	640611	บ้านซ่าน	Ban San	64120	2025-12-18 04:35:48.482	6406
640612	640612	วังใหญ่	Wang Yai	64120	2025-12-18 04:35:48.483	6406
640613	640613	ราวต้นจันทร์	Rao Ton Chan	64120	2025-12-18 04:35:48.485	6406
640701	640701	เมืองสวรรคโลก	Mueang Sawankhalok	64110	2025-12-18 04:35:48.486	6407
640702	640702	ในเมือง	Nai Mueang	64110	2025-12-18 04:35:48.488	6407
640703	640703	คลองกระจง	Khlong Krachong	64110	2025-12-18 04:35:48.489	6407
640704	640704	วังพิณพาทย์	Wang Phinphat	64110	2025-12-18 04:35:48.491	6407
640705	640705	วังไม้ขอน	Wang Mai Khon	64110	2025-12-18 04:35:48.493	6407
640706	640706	ย่านยาว	Yan Yao	64110	2025-12-18 04:35:48.494	6407
640707	640707	นาทุ่ง	Na Thung	64110	2025-12-18 04:35:48.496	6407
640708	640708	คลองยาง	Khlong Yao	64110	2025-12-18 04:35:48.497	6407
640709	640709	เมืองบางยม	Mueang Bang Yom	64110	2025-12-18 04:35:48.499	6407
640710	640710	ท่าทอง	Tha Thong	64110	2025-12-18 04:35:48.501	6407
640711	640711	ปากน้ำ	Pak Nam	64110	2025-12-18 04:35:48.502	6407
640712	640712	ป่ากุมเกาะ	Pa Kum Ko	64110	2025-12-18 04:35:48.504	6407
640713	640713	เมืองบางขลัง	Mueang Bang Khlang	64110	2025-12-18 04:35:48.505	6407
640714	640714	หนองกลับ	Nong Klap	64110	2025-12-18 04:35:48.507	6407
640801	640801	ศรีนคร	Si Nakhon	64180	2025-12-18 04:35:48.508	6408
640802	640802	นครเดิฐ	Nakhon Doet	64180	2025-12-18 04:35:48.51	6408
640803	640803	น้ำขุม	Nam Khum	64180	2025-12-18 04:35:48.511	6408
640804	640804	คลองมะพลับ	Khlong Maphlap	64180	2025-12-18 04:35:48.513	6408
640805	640805	หนองบัว	Nong Bua	64180	2025-12-18 04:35:48.514	6408
640901	640901	บ้านใหม่ไชยมงคล	Ban Mai Chai Mongkhon	64230	2025-12-18 04:35:48.516	6409
640902	640902	ไทยชนะศึก	Thai Chana Suek	64150	2025-12-18 04:35:48.518	6409
640903	640903	ทุ่งเสลี่ยม	Thung Saliam	64150	2025-12-18 04:35:48.519	6409
640904	640904	กลางดง	Klang Dong	64150	2025-12-18 04:35:48.521	6409
640905	640905	เขาแก้วศรีสมบูรณ์	Khaokaw Si Somboon	64230	2025-12-18 04:35:48.524	6409
650101	650101	ในเมือง	Nai Mueang	65000	2025-12-18 04:35:48.525	6501
650102	650102	วังน้ำคู้	Wang Nam Khu	65230	2025-12-18 04:35:48.527	6501
650103	650103	วัดจันทร์	Wat Chan	65000	2025-12-18 04:35:48.529	6501
650104	650104	วัดพริก	Wat Phrik	65230	2025-12-18 04:35:48.531	6501
650105	650105	ท่าทอง	Tha Thong	65000	2025-12-18 04:35:48.533	6501
650106	650106	ท่าโพธิ์	Tha Pho	65000	2025-12-18 04:35:48.534	6501
650107	650107	สมอแข	Samo Khae	65000	2025-12-18 04:35:48.536	6501
650108	650108	ดอนทอง	Don Thong	65000	2025-12-18 04:35:48.538	6501
650109	650109	บ้านป่า	Ban Pa	65000	2025-12-18 04:35:48.539	6501
650110	650110	ปากโทก	Pak Thok	65000	2025-12-18 04:35:48.542	6501
650113	650113	บ้านกร่าง	Ban Krang	65000	2025-12-18 04:35:48.548	6501
650114	650114	บ้านคลอง	Ban Khlong	65000	2025-12-18 04:35:48.55	6501
650115	650115	พลายชุมพล	Phlai Chumphon	65000	2025-12-18 04:35:48.552	6501
650116	650116	มะขามสูง	Makham Sung	65000	2025-12-18 04:35:48.554	6501
650117	650117	อรัญญิก	Aranyik	65000	2025-12-18 04:35:48.556	6501
650118	650118	บึงพระ	Bueng Phra	65000	2025-12-18 04:35:48.558	6501
650119	650119	ไผ่ขอดอน	Phai Kho Don	65000	2025-12-18 04:35:48.56	6501
650120	650120	งิ้วงาม	Ngio Ngam	65230	2025-12-18 04:35:48.561	6501
650201	650201	นครไทย	Nakhon Thai	65120	2025-12-18 04:35:48.562	6502
650202	650202	หนองกะท้าว	Nong Kathao	65120	2025-12-18 04:35:48.563	6502
650203	650203	บ้านแยง	Ban Yaeng	65120	2025-12-18 04:35:48.565	6502
650204	650204	เนินเพิ่ม	Noen Phoem	65120	2025-12-18 04:35:48.566	6502
650205	650205	นาบัว	Na Bua	65120	2025-12-18 04:35:48.567	6502
650206	650206	นครชุม	Nakhon Chum	65120	2025-12-18 04:35:48.569	6502
650207	650207	น้ำกุ่ม	Nam Kum	65120	2025-12-18 04:35:48.57	6502
650208	650208	ยางโกลน	Yang Klon	65120	2025-12-18 04:35:48.572	6502
650209	650209	บ่อโพธิ์	Bo Pho	65120	2025-12-18 04:35:48.576	6502
650210	650210	บ้านพร้าว	Ban Phrao	65120	2025-12-18 04:35:48.577	6502
650211	650211	ห้วยเฮี้ย	Huai Hia	65120	2025-12-18 04:35:48.579	6502
650301	650301	ป่าแดง	Pa Daeng	65170	2025-12-18 04:35:48.581	6503
650302	650302	ชาติตระการ	Chat Trakan	65170	2025-12-18 04:35:48.583	6503
650303	650303	สวนเมี่ยง	Suan Miang	65170	2025-12-18 04:35:48.584	6503
650304	650304	บ้านดง	Ban Dong	65170	2025-12-18 04:35:48.586	6503
650305	650305	บ่อภาค	Bo Phak	65170	2025-12-18 04:35:48.587	6503
650306	650306	ท่าสะแก	Tha Sakae	65170	2025-12-18 04:35:48.589	6503
650401	650401	บางระกำ	Bang Rakam	65140	2025-12-18 04:35:48.591	6504
650402	650402	ปลักแรด	Plak Raet	65140	2025-12-18 04:35:48.593	6504
650403	650403	พันเสา	Phan Sao	65140	2025-12-18 04:35:48.594	6504
650404	650404	วังอิทก	Wang Ithok	65140	2025-12-18 04:35:48.595	6504
650405	650405	บึงกอก	Bueng Kok	65140	2025-12-18 04:35:48.597	6504
650406	650406	หนองกุลา	Nong Kula	65140	2025-12-18 04:35:48.598	6504
650407	650407	ชุมแสงสงคราม	Chum Saeng Songkhram	65240	2025-12-18 04:35:48.6	6504
650408	650408	นิคมพัฒนา	Nikhom Phatthana	65140	2025-12-18 04:35:48.601	6504
650409	650409	บ่อทอง	Bo Thong	65140	2025-12-18 04:35:48.603	6504
650410	650410	ท่านางงาม	Tha Nang Ngam	65140	2025-12-18 04:35:48.604	6504
650411	650411	คุยม่วง	Khui Muang	65240	2025-12-18 04:35:48.606	6504
650501	650501	บางกระทุ่ม	Bang Krathum	65110	2025-12-18 04:35:48.607	6505
650502	650502	บ้านไร่	Ban Rai	65110	2025-12-18 04:35:48.609	6505
650503	650503	โคกสลุด	Khok Salut	65110	2025-12-18 04:35:48.611	6505
650504	650504	สนามคลี	Sanam Khli	65110	2025-12-18 04:35:48.613	6505
650505	650505	ท่าตาล	Tha Tan	65110	2025-12-18 04:35:48.614	6505
650506	650506	ไผ่ล้อม	Phai Lom	65110	2025-12-18 04:35:48.616	6505
650507	650507	นครป่าหมาก	Nakhon Pa Mak	65110	2025-12-18 04:35:48.618	6505
650508	650508	เนินกุ่ม	Noen Kum	65210	2025-12-18 04:35:48.62	6505
650509	650509	วัดตายม	Wat Ta Yom	65210	2025-12-18 04:35:48.622	6505
650601	650601	พรหมพิราม	Phrom Phiram	65150	2025-12-18 04:35:48.623	6506
650602	650602	ท่าช้าง	Tha Chang	65150	2025-12-18 04:35:48.625	6506
650603	650603	วงฆ้อง	Wong Khong	65180	2025-12-18 04:35:48.626	6506
650604	650604	มะตูม	Matum	65150	2025-12-18 04:35:48.627	6506
650605	650605	หอกลอง	Ho Klong	65150	2025-12-18 04:35:48.629	6506
650606	650606	ศรีภิรมย์	Si Phirom	65180	2025-12-18 04:35:48.63	6506
650607	650607	ตลุกเทียม	Taluk Thiam	65180	2025-12-18 04:35:48.631	6506
650608	650608	วังวน	Wang Won	65150	2025-12-18 04:35:48.633	6506
650609	650609	หนองแขม	Nong Khaem	65150	2025-12-18 04:35:48.635	6506
650610	650610	มะต้อง	Matong	65180	2025-12-18 04:35:48.636	6506
650611	650611	ทับยายเชียง	Thap Yai Chiang	65150	2025-12-18 04:35:48.637	6506
650612	650612	ดงประคำ	Dong Prakham	65180	2025-12-18 04:35:48.638	6506
650701	650701	วัดโบสถ์	Wat Bot	65160	2025-12-18 04:35:48.639	6507
650702	650702	ท่างาม	Tha Ngam	65160	2025-12-18 04:35:48.641	6507
650703	650703	ท้อแท้	Thothae	65160	2025-12-18 04:35:48.643	6507
650704	650704	บ้านยาง	Ban Yang	65160	2025-12-18 04:35:48.644	6507
650705	650705	หินลาด	Hin Lat	65160	2025-12-18 04:35:48.646	6507
650801	650801	วังทอง	Wang Thong	65130	2025-12-18 04:35:48.649	6508
650802	650802	พันชาลี	Phan Chali	65130	2025-12-18 04:35:48.651	6508
650803	650803	แม่ระกา	Mae Raka	65130	2025-12-18 04:35:48.652	6508
650804	650804	บ้านกลาง	Ban Klang	65220	2025-12-18 04:35:48.654	6508
650805	650805	วังพิกุล	Wang Phikun	65130	2025-12-18 04:35:48.655	6508
650806	650806	แก่งโสภา	Kaeng Sopha	65220	2025-12-18 04:35:48.657	6508
650807	650807	ท่าหมื่นราม	Tha Muen Ram	65130	2025-12-18 04:35:48.659	6508
650808	650808	วังนกแอ่น	Wang Nok Aen	65130	2025-12-18 04:35:48.661	6508
650809	650809	หนองพระ	Nong Phra	65130	2025-12-18 04:35:48.663	6508
650810	650810	ชัยนาม	Chaiyanam	65130	2025-12-18 04:35:48.664	6508
650811	650811	ดินทอง	Din Thong	65130	2025-12-18 04:35:48.666	6508
650901	650901	ชมพู	Chomphu	65190	2025-12-18 04:35:48.667	6509
650902	650902	บ้านมุง	Ban Mung	65190	2025-12-18 04:35:48.668	6509
650903	650903	ไทรย้อย	Sai Yoi	65190	2025-12-18 04:35:48.67	6509
650904	650904	วังโพรง	Wang Phrong	65190	2025-12-18 04:35:48.671	6509
660507	660507	วังกรด	Wang Krot	66120	2025-12-18 04:35:48.778	6605
650905	650905	บ้านน้อยซุ้มขี้เหล็ก	Ban Noi Sum Khilek	65190	2025-12-18 04:35:48.673	6509
650906	650906	เนินมะปราง	Noen Maprang	65190	2025-12-18 04:35:48.674	6509
650907	650907	วังยาง	Wang Yang	65190	2025-12-18 04:35:48.676	6509
650908	650908	โคกแหลม	Khok Laem	65190	2025-12-18 04:35:48.678	6509
660101	660101	ในเมือง	Nai Mueang	66000	2025-12-18 04:35:48.681	6601
660102	660102	ไผ่ขวาง	Phai Khwang	66000	2025-12-18 04:35:48.684	6601
660103	660103	ย่านยาว	Yan Yao	66000	2025-12-18 04:35:48.688	6601
660104	660104	ท่าฬ่อ	Tha Lo	66000	2025-12-18 04:35:48.69	6601
660105	660105	ปากทาง	Pak Thang	66000	2025-12-18 04:35:48.692	6601
660106	660106	คลองคะเชนทร์	Khlong Khachen	66000	2025-12-18 04:35:48.694	6601
660107	660107	โรงช้าง	Rong Chang	66000	2025-12-18 04:35:48.696	6601
660108	660108	เมืองเก่า	Mueang Kao	66000	2025-12-18 04:35:48.698	6601
660109	660109	ท่าหลวง	Tha Luang	66000	2025-12-18 04:35:48.7	6601
660110	660110	บ้านบุ่ง	Ban Bung	66000	2025-12-18 04:35:48.702	6601
660111	660111	ฆะมัง	Khamang	66000	2025-12-18 04:35:48.704	6601
660112	660112	ดงป่าคำ	Dong Pa Kham	66170	2025-12-18 04:35:48.706	6601
660113	660113	หัวดง	Hua Dong	66170	2025-12-18 04:35:48.708	6601
660115	660115	ป่ามะคาบ	Pa Makhap	66000	2025-12-18 04:35:48.71	6601
660119	660119	สายคำโห้	Sai Kham Ho	66000	2025-12-18 04:35:48.712	6601
660120	660120	ดงกลาง	Dong Klang	66170	2025-12-18 04:35:48.714	6601
660201	660201	วังทรายพูน	Wang Sai Phun	66180	2025-12-18 04:35:48.716	6602
660202	660202	หนองปลาไหล	Nong Pla Lai	66180	2025-12-18 04:35:48.718	6602
660203	660203	หนองพระ	Nong Phra	66180	2025-12-18 04:35:48.72	6602
660204	660204	หนองปล้อง	Nong Plong	66180	2025-12-18 04:35:48.723	6602
660301	660301	โพธิ์ประทับช้าง	Pho Prathap Chang	66190	2025-12-18 04:35:48.725	6603
660302	660302	ไผ่ท่าโพ	Phai Tha Pho	66190	2025-12-18 04:35:48.727	6603
660303	660303	วังจิก	Wang Chik	66190	2025-12-18 04:35:48.729	6603
660304	660304	ไผ่รอบ	Phai Rop	66190	2025-12-18 04:35:48.731	6603
660305	660305	ดงเสือเหลือง	Dong Suea Lueang	66190	2025-12-18 04:35:48.733	6603
660306	660306	เนินสว่าง	Noen Sawang	66190	2025-12-18 04:35:48.735	6603
660307	660307	ทุ่งใหญ่	Thung Yai	66190	2025-12-18 04:35:48.737	6603
660401	660401	ตะพานหิน	Taphan Hin	66110	2025-12-18 04:35:48.739	6604
660402	660402	งิ้วราย	Ngio Rai	66110	2025-12-18 04:35:48.741	6604
660403	660403	ห้วยเกตุ	Huai Ket	66110	2025-12-18 04:35:48.743	6604
660404	660404	ไทรโรงโขน	Sai Rong Khon	66110	2025-12-18 04:35:48.745	6604
660405	660405	หนองพยอม	Nong Phayom	66110	2025-12-18 04:35:48.747	6604
660406	660406	ทุ่งโพธิ์	Tung Pho	66150	2025-12-18 04:35:48.749	6604
660407	660407	ดงตะขบ	Dong Takhop	66110	2025-12-18 04:35:48.751	6604
660408	660408	คลองคูณ	Khlong Khun	66110	2025-12-18 04:35:48.753	6604
660409	660409	วังสำโรง	Wang Samrong	66110	2025-12-18 04:35:48.755	6604
660410	660410	วังหว้า	Wang Wa	66110	2025-12-18 04:35:48.757	6604
660411	660411	วังหลุม	Wang Lum	66150	2025-12-18 04:35:48.759	6604
660412	660412	ทับหมัน	Thap Man	66110	2025-12-18 04:35:48.761	6604
660413	660413	ไผ่หลวง	Phai Luang	66110	2025-12-18 04:35:48.763	6604
660501	660501	บางมูลนาก	Bang Mun Nak	66120	2025-12-18 04:35:48.765	6605
660502	660502	บางไผ่	Bang Phai	66120	2025-12-18 04:35:48.767	6605
660503	660503	หอไกร	Ho Krai	66120	2025-12-18 04:35:48.769	6605
660504	660504	เนินมะกอก	Noen Makok	66120	2025-12-18 04:35:48.772	6605
660505	660505	วังสำโรง	Wang Samrong	66120	2025-12-18 04:35:48.774	6605
660506	660506	ภูมิ	Phum	66120	2025-12-18 04:35:48.776	6605
660508	660508	ห้วยเขน	Huai Khen	66120	2025-12-18 04:35:48.78	6605
660509	660509	วังตะกู	Wang Taku	66210	2025-12-18 04:35:48.782	6605
660514	660514	ลำประดา	Lam Prad	66120	2025-12-18 04:35:48.784	6605
660601	660601	โพทะเล	Pho Thale	66130	2025-12-18 04:35:48.786	6606
660602	660602	ท้ายน้ำ	Thai Nam	66130	2025-12-18 04:35:48.788	6606
660603	660603	ทะนง	Thanong	66130	2025-12-18 04:35:48.79	6606
660604	660604	ท่าบัว	Tha Bua	66130	2025-12-18 04:35:48.792	6606
660605	660605	ทุ่งน้อย	Thung Noi	66130	2025-12-18 04:35:48.795	6606
660606	660606	ท่าขมิ้น	Tha Khamin	66130	2025-12-18 04:35:48.797	6606
660607	660607	ท่าเสา	Tha Sao	66130	2025-12-18 04:35:48.799	6606
660608	660608	บางคลาน	Bang Khlan	66130	2025-12-18 04:35:48.801	6606
660611	660611	ท่านั่ง	Tha Nang	66130	2025-12-18 04:35:48.803	6606
660612	660612	บ้านน้อย	Ban Noi	66130	2025-12-18 04:35:48.805	6606
660613	660613	วัดขวาง	Wat Khwang	66130	2025-12-18 04:35:48.807	6606
660701	660701	สามง่าม	Sam Ngam	66140	2025-12-18 04:35:48.809	6607
660702	660702	กำแพงดิน	Kamphaeng Din	66140	2025-12-18 04:35:48.81	6607
660703	660703	รังนก	Rang Nok	66140	2025-12-18 04:35:48.813	6607
660706	660706	เนินปอ	Noen Po	66140	2025-12-18 04:35:48.815	6607
660707	660707	หนองโสน	Nong Sano	66140	2025-12-18 04:35:48.817	6607
660801	660801	ทับคล้อ	Thap Khlo	66150	2025-12-18 04:35:48.819	6608
660802	660802	เขาทราย	Khao Sai	66230	2025-12-18 04:35:48.822	6608
660803	660803	เขาเจ็ดลูก	Khao Chet Luk	66230	2025-12-18 04:35:48.824	6608
660804	660804	ท้ายทุ่ง	Tai Toong	66150	2025-12-18 04:35:48.825	6608
660901	660901	สากเหล็ก	Sak Lek	66160	2025-12-18 04:35:48.827	6609
660902	660902	ท่าเยี่ยม	Tha Yiam	66160	2025-12-18 04:35:48.829	6609
660903	660903	คลองทราย	Khlong Sai	66160	2025-12-18 04:35:48.831	6609
660904	660904	หนองหญ้าไทร	Nong Ya Sai	66160	2025-12-18 04:35:48.833	6609
660905	660905	วังทับไทร	Wang Thap Sai	66160	2025-12-18 04:35:48.834	6609
661001	661001	ห้วยแก้ว	Huai Kaeo	66130	2025-12-18 04:35:48.836	6610
661002	661002	โพธิ์ไทรงาม	Pho Sai Ngam	66130	2025-12-18 04:35:48.837	6610
661003	661003	แหลมรัง	Laem Rang	66130	2025-12-18 04:35:48.839	6610
661004	661004	บางลาย	Bang Lai	66130	2025-12-18 04:35:48.84	6610
661005	661005	บึงนาราง	Bueng Na Rang	66130	2025-12-18 04:35:48.842	6610
661101	661101	วังงิ้วใต้	Wang Ngio Tai	66210	2025-12-18 04:35:48.844	6611
661102	661102	วังงิ้ว	Wang Ngio	66210	2025-12-18 04:35:48.845	6611
661103	661103	ห้วยร่วม	Huai Ruam	66210	2025-12-18 04:35:48.847	6611
661104	661104	ห้วยพุก	Huai Phuk	66210	2025-12-18 04:35:48.848	6611
661105	661105	สำนักขุนเณร	Samnak Khun Nen	66210	2025-12-18 04:35:48.85	6611
661201	661201	บ้านนา	Ban Na	66140	2025-12-18 04:35:48.851	6612
661202	661202	บึงบัว	Bueng Bua	66140	2025-12-18 04:35:48.853	6612
661203	661203	วังโมกข์	Wang Mok	66140	2025-12-18 04:35:48.855	6612
661204	661204	หนองหลุม	Nong Lum	66220	2025-12-18 04:35:48.856	6612
670101	670101	ในเมือง	Nai Mueang	67000	2025-12-18 04:35:48.858	6701
670102	670102	ตะเบาะ	Tabo	67000	2025-12-18 04:35:48.859	6701
670103	670103	บ้านโตก	Ban Tok	67000	2025-12-18 04:35:48.861	6701
670104	670104	สะเดียง	Sadiang	67000	2025-12-18 04:35:48.863	6701
670105	670105	ป่าเลา	Pa Lao	67000	2025-12-18 04:35:48.864	6701
670106	670106	นางั่ว	Na Ngua	67000	2025-12-18 04:35:48.867	6701
670107	670107	ท่าพล	Tha Phon	67250	2025-12-18 04:35:48.868	6701
670108	670108	ดงมูลเหล็ก	Dong Mun Lek	67000	2025-12-18 04:35:48.869	6701
670109	670109	บ้านโคก	Ban Khok	67000	2025-12-18 04:35:48.871	6701
670110	670110	ชอนไพร	Chon Phrai	67000	2025-12-18 04:35:48.872	6701
670111	670111	นาป่า	Na Pa	67000	2025-12-18 04:35:48.873	6701
670112	670112	นายม	Na Yom	67210	2025-12-18 04:35:48.874	6701
670113	670113	วังชมภู	Wang Chomphu	67210	2025-12-18 04:35:48.876	6701
670114	670114	น้ำร้อน	Nam Ron	67000	2025-12-18 04:35:48.877	6701
670115	670115	ห้วยสะแก	Huai Sakae	67210	2025-12-18 04:35:48.878	6701
670116	670116	ห้วยใหญ่	Huai Yai	67000	2025-12-18 04:35:48.879	6701
670117	670117	ระวิง	Rawing	67210	2025-12-18 04:35:48.88	6701
670201	670201	ชนแดน	Chon Daen	67150	2025-12-18 04:35:48.882	6702
670202	670202	ดงขุย	Dong Khui	67190	2025-12-18 04:35:48.883	6702
670203	670203	ท่าข้าม	Tha Kham	67150	2025-12-18 04:35:48.884	6702
670204	670204	พุทธบาท	Phutthabat	67150	2025-12-18 04:35:48.885	6702
670205	670205	ลาดแค	Lat Khae	67150	2025-12-18 04:35:48.886	6702
670206	670206	บ้านกล้วย	Ban Kluai	67190	2025-12-18 04:35:48.887	6702
670208	670208	ซับพุทรา	Sap Phutsa	67150	2025-12-18 04:35:48.888	6702
670209	670209	ตะกุดไร	Takut Rai	67190	2025-12-18 04:35:48.889	6702
670210	670210	ศาลาลาย	Sala Lai	67150	2025-12-18 04:35:48.891	6702
670301	670301	หล่มสัก	Lom Sak	67110	2025-12-18 04:35:48.892	6703
670302	670302	วัดป่า	Wat Pa	67110	2025-12-18 04:35:48.893	6703
670303	670303	ตาลเดี่ยว	Tan Diao	67110	2025-12-18 04:35:48.894	6703
670304	670304	ฝายนาแซง	Fai Na Saeng	67110	2025-12-18 04:35:48.895	6703
670305	670305	หนองสว่าง	Nong Sawang	67110	2025-12-18 04:35:48.896	6703
670306	670306	น้ำเฮี้ย	Nam Hia	67110	2025-12-18 04:35:48.897	6703
670307	670307	สักหลง	Sak Long	67110	2025-12-18 04:35:48.898	6703
670308	670308	ท่าอิบุญ	Tha Ibun	67110	2025-12-18 04:35:48.9	6703
670309	670309	บ้านโสก	Ban Sok	67110	2025-12-18 04:35:48.901	6703
670310	670310	บ้านติ้ว	Ban Tio	67110	2025-12-18 04:35:48.902	6703
670311	670311	ห้วยไร่	Huai Rai	67110	2025-12-18 04:35:48.903	6703
670312	670312	น้ำก้อ	Nam Ko	67110	2025-12-18 04:35:48.904	6703
670313	670313	ปากช่อง	Pak Chong	67110	2025-12-18 04:35:48.905	6703
670314	670314	น้ำชุน	Nam Chun	67110	2025-12-18 04:35:48.906	6703
670315	670315	หนองไขว่	Nong Khwai	67110	2025-12-18 04:35:48.907	6703
670316	670316	ลานบ่า	Lan Ba	67110	2025-12-18 04:35:48.908	6703
670317	670317	บุ่งคล้า	Bung Khla	67110	2025-12-18 04:35:48.909	6703
670318	670318	บุ่งน้ำเต้า	Bung Namtao	67110	2025-12-18 04:35:48.91	6703
670319	670319	บ้านกลาง	Ban Klang	67110	2025-12-18 04:35:48.911	6703
670320	670320	ช้างตะลูด	Chang Talut	67110	2025-12-18 04:35:48.912	6703
670321	670321	บ้านไร่	Ban Rai	67110	2025-12-18 04:35:48.914	6703
670322	670322	ปากดุก	Pak Duk	67110	2025-12-18 04:35:48.915	6703
670323	670323	บ้านหวาย	Ban Wai	67110	2025-12-18 04:35:48.916	6703
670401	670401	หล่มเก่า	Lom Kao	67120	2025-12-18 04:35:48.917	6704
670402	670402	นาซำ	Na Sam	67120	2025-12-18 04:35:48.918	6704
670403	670403	หินฮาว	Hin Hao	67120	2025-12-18 04:35:48.919	6704
670404	670404	บ้านเนิน	Ban Noen	67120	2025-12-18 04:35:48.92	6704
670405	670405	ศิลา	Sila	67120	2025-12-18 04:35:48.921	6704
670406	670406	นาแซง	Na Saeng	67120	2025-12-18 04:35:48.922	6704
670407	670407	วังบาล	Wang Ban	67120	2025-12-18 04:35:48.924	6704
670408	670408	นาเกาะ	Na Ko	67120	2025-12-18 04:35:48.925	6704
670409	670409	ตาดกลอย	Tat Kloi	67120	2025-12-18 04:35:48.927	6704
670501	670501	ท่าโรง	Tha Rong	67130	2025-12-18 04:35:48.928	6705
670502	670502	สระประดู่	Sa Pradu	67130	2025-12-18 04:35:48.93	6705
670503	670503	สามแยก	Sam Yaek	67130	2025-12-18 04:35:48.931	6705
670504	670504	โคกปรง	Khok Prong	67130	2025-12-18 04:35:48.932	6705
670505	670505	น้ำร้อน	Nam Ron	67130	2025-12-18 04:35:48.934	6705
670506	670506	บ่อรัง	Bo Rang	67130	2025-12-18 04:35:48.935	6705
670507	670507	พุเตย	Phu Toei	67180	2025-12-18 04:35:48.936	6705
670508	670508	พุขาม	Phu Kham	67180	2025-12-18 04:35:48.938	6705
670509	670509	ภูน้ำหยด	Phu Nam Yot	67180	2025-12-18 04:35:48.939	6705
670510	670510	ซับสมบูรณ์	Sap Sombun	67180	2025-12-18 04:35:48.94	6705
670511	670511	บึงกระจับ	Bueng Krachap	67130	2025-12-18 04:35:48.942	6705
670512	670512	วังใหญ่	Wang Yai	67180	2025-12-18 04:35:48.943	6705
670513	670513	ยางสาว	Yang Sao	67130	2025-12-18 04:35:48.945	6705
670514	670514	ซับน้อย	Sap Noi	67180	2025-12-18 04:35:48.946	6705
670601	670601	ศรีเทพ	Si Thep	67170	2025-12-18 04:35:48.948	6706
670602	670602	สระกรวด	Sa Kruat	67170	2025-12-18 04:35:48.949	6706
670603	670603	คลองกระจัง	Khlong Krachang	67170	2025-12-18 04:35:48.951	6706
670604	670604	นาสนุ่น	Na Sanun	67170	2025-12-18 04:35:48.952	6706
670605	670605	โคกสะอาด	Khok Sa-at	67170	2025-12-18 04:35:48.954	6706
670606	670606	หนองย่างทอย	Nong Yang Thoi	67170	2025-12-18 04:35:48.955	6706
670607	670607	ประดู่งาม	Pradu Ngam	67170	2025-12-18 04:35:48.957	6706
670701	670701	กองทูล	Kong Thun	67140	2025-12-18 04:35:48.958	6707
670702	670702	นาเฉลียง	Na Chaliang	67220	2025-12-18 04:35:48.96	6707
670703	670703	บ้านโภชน์	Ban Phot	67140	2025-12-18 04:35:48.961	6707
670704	670704	ท่าแดง	Tha Daeng	67140	2025-12-18 04:35:48.963	6707
670705	670705	เพชรละคร	Phet Lakhon	67140	2025-12-18 04:35:48.964	6707
670706	670706	บ่อไทย	Bo Thai	67140	2025-12-18 04:35:48.966	6707
670707	670707	ห้วยโป่ง	Huai Pong	67220	2025-12-18 04:35:48.967	6707
670708	670708	วังท่าดี	Wang Tha Di	67140	2025-12-18 04:35:48.969	6707
670709	670709	บัววัฒนา	Bua Watthana	67140	2025-12-18 04:35:48.97	6707
670710	670710	หนองไผ่	Nong Phai	67140	2025-12-18 04:35:48.972	6707
670711	670711	วังโบสถ์	Wang Bot	67140	2025-12-18 04:35:48.973	6707
670712	670712	ยางงาม	Yang Ngam	67220	2025-12-18 04:35:48.975	6707
670713	670713	ท่าด้วง	Tha Duang	67140	2025-12-18 04:35:48.977	6707
670801	670801	ซับสมอทอด	Sap Samo Thot	67160	2025-12-18 04:35:48.978	6708
670802	670802	ซับไม้แดง	Sap Mai Daeng	67160	2025-12-18 04:35:48.98	6708
670803	670803	หนองแจง	Nong Chaeng	67160	2025-12-18 04:35:48.981	6708
670804	670804	กันจุ	Kan Chu	67160	2025-12-18 04:35:48.983	6708
670805	670805	วังพิกุล	Wang Phikun	67230	2025-12-18 04:35:48.985	6708
670806	670806	พญาวัง	Phaya Wang	67160	2025-12-18 04:35:48.986	6708
670807	670807	ศรีมงคล	Si Mongkhon	67160	2025-12-18 04:35:48.988	6708
670808	670808	สระแก้ว	Sa Kaeo	67160	2025-12-18 04:35:48.99	6708
670809	670809	บึงสามพัน	Bueng Sam Phan	67160	2025-12-18 04:35:48.991	6708
670901	670901	น้ำหนาว	Nam Nao	67260	2025-12-18 04:35:48.993	6709
670902	670902	หลักด่าน	Lak Dan	67260	2025-12-18 04:35:48.995	6709
670903	670903	วังกวาง	Wang Kwang	67260	2025-12-18 04:35:48.996	6709
670904	670904	โคกมน	Khok Mon	67260	2025-12-18 04:35:48.998	6709
671001	671001	วังโป่ง	Wang Pong	67240	2025-12-18 04:35:49	6710
671002	671002	ท้ายดง	Thai Dong	67240	2025-12-18 04:35:49.001	6710
671003	671003	ซับเปิบ	Sap Poep	67240	2025-12-18 04:35:49.003	6710
671004	671004	วังหิน	Wang Hin	67240	2025-12-18 04:35:49.005	6710
671005	671005	วังศาล	Wang San	67240	2025-12-18 04:35:49.006	6710
671101	671101	ทุ่งสมอ	Khao Kho	67270	2025-12-18 04:35:49.008	6711
671102	671102	แคมป์สน	Khaem Son	67280	2025-12-18 04:35:49.01	6711
671103	671103	เขาค้อ	Thung Samo	67270	2025-12-18 04:35:49.012	6711
671104	671104	ริมสีม่วง	Rim Si Muang	67270	2025-12-18 04:35:49.013	6711
671105	671105	สะเดาะพง	Sado Phong	67270	2025-12-18 04:35:49.015	6711
671106	671106	หนองแม่นา	Nong Mae Na	67270	2025-12-18 04:35:49.017	6711
671107	671107	เข็กน้อย	Khek Noi	67280	2025-12-18 04:35:49.018	6711
700101	700101	หน้าเมือง	Na Mueang	70000	2025-12-18 04:35:49.02	7001
700102	700102	เจดีย์หัก	Chedi Hak	70000	2025-12-18 04:35:49.022	7001
700103	700103	ดอนตะโก	Don Tako	70000	2025-12-18 04:35:49.023	7001
700104	700104	หนองกลางนา	Nong Klang Na	70000	2025-12-18 04:35:49.026	7001
700105	700105	ห้วยไผ่	Huai Phai	70000	2025-12-18 04:35:49.028	7001
700106	700106	คุ้งน้ำวน	Khung Nam Won	70000	2025-12-18 04:35:49.03	7001
700107	700107	คุ้งกระถิน	Khung Krathin	70000	2025-12-18 04:35:49.031	7001
700108	700108	อ่างทอง	Ang Thong	70000	2025-12-18 04:35:49.033	7001
700109	700109	โคกหม้อ	Khok Mo	70000	2025-12-18 04:35:49.035	7001
700110	700110	สามเรือน	Sam Ruean	70000	2025-12-18 04:35:49.036	7001
700111	700111	พิกุลทอง	Phikun Thong	70000	2025-12-18 04:35:49.038	7001
700112	700112	น้ำพุ	Nam Phu	70000	2025-12-18 04:35:49.04	7001
700113	700113	ดอนแร่	Don Rae	70000	2025-12-18 04:35:49.042	7001
700114	700114	หินกอง	Hin Kong	70000	2025-12-18 04:35:49.044	7001
700115	700115	เขาแร้ง	Khao Raeng	70000	2025-12-18 04:35:49.045	7001
700116	700116	เกาะพลับพลา	Ko Phlapphla	70000	2025-12-18 04:35:49.047	7001
700117	700117	หลุมดิน	Lum Din	70000	2025-12-18 04:35:49.049	7001
700118	700118	บางป่า	Bang Pa	70000	2025-12-18 04:35:49.051	7001
700119	700119	พงสวาย	Phong Sawai	70000	2025-12-18 04:35:49.053	7001
700120	700120	คูบัว	Khu Bua	70000	2025-12-18 04:35:49.055	7001
700121	700121	ท่าราบ	Tha Rap	70000	2025-12-18 04:35:49.058	7001
700122	700122	บ้านไร่	Ban Rai	70000	2025-12-18 04:35:49.06	7001
700201	700201	จอมบึง	Chom Bueng	70150	2025-12-18 04:35:49.062	7002
700202	700202	ปากช่อง	Pak Chong	70150	2025-12-18 04:35:49.065	7002
700203	700203	เบิกไพร	Boek Phrai	70150	2025-12-18 04:35:49.067	7002
700204	700204	ด่านทับตะโก	Dan Thap Tako	70150	2025-12-18 04:35:49.069	7002
700205	700205	แก้มอ้น	Kaem On	70150	2025-12-18 04:35:49.072	7002
700206	700206	รางบัว	Rang Bua	70150	2025-12-18 04:35:49.074	7002
700301	700301	สวนผึ้ง	Suan Phueng	70180	2025-12-18 04:35:49.076	7003
700302	700302	ป่าหวาย	Pa Wai	70180	2025-12-18 04:35:49.078	7003
700304	700304	ท่าเคย	Tha Khoei	70180	2025-12-18 04:35:49.08	7003
700307	700307	ตะนาวศรี	Tanao Si	70180	2025-12-18 04:35:49.082	7003
700401	700401	ดำเนินสะดวก	Damnoen Saduak	70130	2025-12-18 04:35:49.084	7004
700402	700402	ประสาทสิทธิ์	Prasat Sit	70210	2025-12-18 04:35:49.086	7004
700403	700403	ศรีสุราษฎร์	Si Surat	70130	2025-12-18 04:35:49.088	7004
700404	700404	ตาหลวง	Ta Luang	70130	2025-12-18 04:35:49.091	7004
700405	700405	ดอนกรวย	Don Kruai	70130	2025-12-18 04:35:49.093	7004
700406	700406	ดอนคลัง	Don Khlang	70130	2025-12-18 04:35:49.096	7004
700407	700407	บัวงาม	Bua Ngam	70210	2025-12-18 04:35:49.098	7004
700408	700408	บ้านไร่	Ban Rai	70130	2025-12-18 04:35:49.101	7004
700409	700409	แพงพวย	Phaengphuai	70130	2025-12-18 04:35:49.109	7004
700410	700410	สี่หมื่น	Si Muen	70130	2025-12-18 04:35:49.113	7004
700411	700411	ท่านัด	Tha Nat	70130	2025-12-18 04:35:49.118	7004
700412	700412	ขุนพิทักษ์	Khun Phithak	70130	2025-12-18 04:35:49.122	7004
700413	700413	ดอนไผ่	Don Phai	70130	2025-12-18 04:35:49.124	7004
700501	700501	บ้านโป่ง	Ban Pong	70110	2025-12-18 04:35:49.126	7005
700502	700502	ท่าผา	Tha Pha	70110	2025-12-18 04:35:49.128	7005
700503	700503	กรับใหญ่	Krap Yai	70190	2025-12-18 04:35:49.13	7005
700504	700504	ปากแรต	Pak Raet	70110	2025-12-18 04:35:49.131	7005
700505	700505	หนองกบ	Nong Kop	70110	2025-12-18 04:35:49.133	7005
700506	700506	หนองอ้อ	Nong O	70110	2025-12-18 04:35:49.134	7005
700507	700507	ดอนกระเบื้อง	Don Krabueang	70110	2025-12-18 04:35:49.136	7005
700508	700508	สวนกล้วย	Suan Kluai	70110	2025-12-18 04:35:49.137	7005
700509	700509	นครชุมน์	Nakhon Chum	70110	2025-12-18 04:35:49.139	7005
700510	700510	บ้านม่วง	Ban Muang	70110	2025-12-18 04:35:49.14	7005
700511	700511	คุ้งพยอม	Khung Phayom	70110	2025-12-18 04:35:49.142	7005
700512	700512	หนองปลาหมอ	Nong Pla Mo	70110	2025-12-18 04:35:49.143	7005
700513	700513	เขาขลุง	Khao Khlung	70110	2025-12-18 04:35:49.145	7005
700514	700514	เบิกไพร	Boek Phrai	70110	2025-12-18 04:35:49.146	7005
700515	700515	ลาดบัวขาว	Lat Bua Khao	70110	2025-12-18 04:35:49.148	7005
700601	700601	บางแพ	Bang Phae	70160	2025-12-18 04:35:49.149	7006
700602	700602	วังเย็น	Wang Yen	70160	2025-12-18 04:35:49.151	7006
700603	700603	หัวโพ	Hua Pho	70160	2025-12-18 04:35:49.152	7006
700604	700604	วัดแก้ว	Wat Kaeo	70160	2025-12-18 04:35:49.154	7006
700605	700605	ดอนใหญ่	Don Yai	70160	2025-12-18 04:35:49.155	7006
700606	700606	ดอนคา	Don Kha	70160	2025-12-18 04:35:49.157	7006
700607	700607	โพหัก	Pho Hak	70160	2025-12-18 04:35:49.158	7006
700701	700701	โพธาราม	Photharam	70120	2025-12-18 04:35:49.16	7007
700702	700702	ดอนกระเบื้อง	Don Krabueang	70120	2025-12-18 04:35:49.161	7007
700703	700703	หนองโพ	Nong Pho	70120	2025-12-18 04:35:49.162	7007
700704	700704	บ้านเลือก	Ban Lueak	70120	2025-12-18 04:35:49.164	7007
700705	700705	คลองตาคต	Khlong Ta Khot	70120	2025-12-18 04:35:49.165	7007
700706	700706	บ้านฆ้อง	Ban Khong	70120	2025-12-18 04:35:49.167	7007
700707	700707	บ้านสิงห์	Ban Sing	70120	2025-12-18 04:35:49.168	7007
700708	700708	ดอนทราย	Don Sai	70120	2025-12-18 04:35:49.17	7007
700709	700709	เจ็ดเสมียน	Chet Samian	70120	2025-12-18 04:35:49.171	7007
700710	700710	คลองข่อย	Khlong Khoi	70120	2025-12-18 04:35:49.173	7007
700711	700711	ชำแระ	Chamrae	70120	2025-12-18 04:35:49.174	7007
700712	700712	สร้อยฟ้า	Soi Fa	70120	2025-12-18 04:35:49.175	7007
700713	700713	ท่าชุมพล	Tha Chumphon	70120	2025-12-18 04:35:49.177	7007
700714	700714	บางโตนด	Bang Tanot	70120	2025-12-18 04:35:49.178	7007
700715	700715	เตาปูน	Tao Pun	70120	2025-12-18 04:35:49.179	7007
700716	700716	นางแก้ว	Nang Kaeo	70120	2025-12-18 04:35:49.181	7007
700717	700717	ธรรมเสน	Thammasen	70120	2025-12-18 04:35:49.182	7007
700718	700718	เขาชะงุ้ม	Khao Cha-ngum	70120	2025-12-18 04:35:49.183	7007
700719	700719	หนองกวาง	Nong Kwang	70120	2025-12-18 04:35:49.184	7007
700801	700801	ทุ่งหลวง	Thung Luang	70140	2025-12-18 04:35:49.186	7008
700802	700802	วังมะนาว	Wang Manao	70140	2025-12-18 04:35:49.187	7008
700803	700803	ดอนทราย	Don Sai	70140	2025-12-18 04:35:49.188	7008
700804	700804	หนองกระทุ่ม	Nong Krathum	70140	2025-12-18 04:35:49.19	7008
700805	700805	ปากท่อ	Pak Tho	70140	2025-12-18 04:35:49.191	7008
700806	700806	ป่าไก่	Pa Kai	70140	2025-12-18 04:35:49.193	7008
700807	700807	วัดยางงาม	Wat Yang Ngam	70140	2025-12-18 04:35:49.194	7008
700808	700808	อ่างหิน	Ang Hin	70140	2025-12-18 04:35:49.195	7008
700809	700809	บ่อกระดาน	Bo Kradan	70140	2025-12-18 04:35:49.196	7008
700810	700810	ยางหัก	Yang Hak	70140	2025-12-18 04:35:49.198	7008
700811	700811	วันดาว	Wan Dao	70140	2025-12-18 04:35:49.199	7008
700812	700812	ห้วยยางโทน	Huai Yang Thon	70140	2025-12-18 04:35:49.2	7008
700901	700901	เกาะศาลพระ	Ko San Phra	70170	2025-12-18 04:35:49.202	7009
700902	700902	จอมประทัด	Chom Prathat	70170	2025-12-18 04:35:49.203	7009
700903	700903	วัดเพลง	Wat Pleng	70170	2025-12-18 04:35:49.204	7009
701001	701001	บ้านคา	Ban Kha	70180	2025-12-18 04:35:49.206	7010
701002	701002	บ้านบึง	Ban Bueng	70180	2025-12-18 04:35:49.207	7010
701003	701003	หนองพันจันทร์	Nong Phan Chan	70180	2025-12-18 04:35:49.208	7010
710101	710101	บ้านเหนือ	Ban Nuea	71000	2025-12-18 04:35:49.21	7101
710102	710102	บ้านใต้	Ban Tai	71000	2025-12-18 04:35:49.211	7101
710103	710103	ปากแพรก	Pak Phraek	71000	2025-12-18 04:35:49.212	7101
710104	710104	ท่ามะขาม	Tha Makham	71000	2025-12-18 04:35:49.214	7101
710105	710105	แก่งเสี้ยน	Kaeng Sian	71000	2025-12-18 04:35:49.215	7101
710106	710106	หนองบัว	Nong Bua	71190	2025-12-18 04:35:49.217	7101
710107	710107	ลาดหญ้า	Lat Ya	71190	2025-12-18 04:35:49.218	7101
710108	710108	วังด้ง	Wang Dong	71190	2025-12-18 04:35:49.219	7101
710109	710109	ช่องสะเดา	Chong Sadao	71190	2025-12-18 04:35:49.221	7101
710110	710110	หนองหญ้า	Nong Ya	71000	2025-12-18 04:35:49.222	7101
710111	710111	เกาะสำโรง	Ko Samrong	71000	2025-12-18 04:35:49.224	7101
710113	710113	บ้านเก่า	Ban Kao	71000	2025-12-18 04:35:49.225	7101
710116	710116	วังเย็น	Wang Yen	71000	2025-12-18 04:35:49.227	7101
710201	710201	ลุ่มสุ่ม	Lum Sum	71150	2025-12-18 04:35:49.228	7102
710202	710202	ท่าเสา	Tha Sao	71150	2025-12-18 04:35:49.229	7102
710203	710203	สิงห์	Sing	71150	2025-12-18 04:35:49.231	7102
710204	710204	ไทรโยค	Sai Yok	71150	2025-12-18 04:35:49.232	7102
710205	710205	วังกระแจะ	Wang Krachae	71150	2025-12-18 04:35:49.234	7102
710206	710206	ศรีมงคล	Si Mongkhon	71150	2025-12-18 04:35:49.235	7102
710207	710207	บ้องตี้	Bongti	71150	2025-12-18 04:35:49.237	7102
710301	710301	บ่อพลอย	Bo Phloi	71160	2025-12-18 04:35:49.238	7103
710302	710302	หนองกุ่ม	Nong Kum	71160	2025-12-18 04:35:49.239	7103
710303	710303	หนองรี	Nong Ri	71220	2025-12-18 04:35:49.241	7103
710305	710305	หลุมรัง	Lum Rang	71160	2025-12-18 04:35:49.242	7103
710308	710308	ช่องด่าน	Chong Dan	71160	2025-12-18 04:35:49.244	7103
710309	710309	หนองกร่าง	Nong Krang	71220	2025-12-18 04:35:49.245	7103
710401	710401	นาสวน	Na Suan	71250	2025-12-18 04:35:49.247	7104
710402	710402	ด่านแม่แฉลบ	Dan Mae Chalaep	71250	2025-12-18 04:35:49.248	7104
710403	710403	หนองเป็ด	Nong Pet	71250	2025-12-18 04:35:49.249	7104
710404	710404	ท่ากระดาน	Tha Kradan	71250	2025-12-18 04:35:49.251	7104
710405	710405	เขาโจด	Khao Chot	71220	2025-12-18 04:35:49.252	7104
710406	710406	แม่กระบุง	Mae Krabung	71250	2025-12-18 04:35:49.253	7104
710501	710501	พงตึก	Phong Tuek	71120	2025-12-18 04:35:49.255	7105
710502	710502	ยางม่วง	Yang Muang	71120	2025-12-18 04:35:49.256	7105
710503	710503	ดอนชะเอม	Don Cha-em	71130	2025-12-18 04:35:49.257	7105
710504	710504	ท่าไม้	Tha Mai	71120	2025-12-18 04:35:49.259	7105
710505	710505	ตะคร้ำเอน	Takhram En	71130	2025-12-18 04:35:49.26	7105
710506	710506	ท่ามะกา	Tha Maka	71120	2025-12-18 04:35:49.261	7105
710507	710507	ท่าเรือ	Tha Ruea	71130	2025-12-18 04:35:49.262	7105
710508	710508	โคกตะบอง	Khok Tabong	71120	2025-12-18 04:35:49.264	7105
710509	710509	ดอนขมิ้น	Don Khamin	71120	2025-12-18 04:35:49.265	7105
710510	710510	อุโลกสี่หมื่น	Ulok Si Muen	71130	2025-12-18 04:35:49.266	7105
710511	710511	เขาสามสิบหาบ	Khao Samsip Hap	71120	2025-12-18 04:35:49.268	7105
710513	710513	หวายเหนียว	Wai Niao	71120	2025-12-18 04:35:49.271	7105
710514	710514	แสนตอ	Saen To	71130	2025-12-18 04:35:49.272	7105
710515	710515	สนามแย้	Sanam Yae	70190	2025-12-18 04:35:49.273	7105
710516	710516	ท่าเสา	Tha Sao	71120	2025-12-18 04:35:49.275	7105
710517	710517	หนองลาน	Nong Lan	71130	2025-12-18 04:35:49.276	7105
710601	710601	ท่าม่วง	Tha Muang	71110	2025-12-18 04:35:49.277	7106
710602	710602	วังขนาย	Wang Khanai	71110	2025-12-18 04:35:49.279	7106
710604	710604	ท่าล้อ	Tha Lo	71110	2025-12-18 04:35:49.281	7106
710605	710605	หนองขาว	Nong Khao	71110	2025-12-18 04:35:49.283	7106
710606	710606	ทุ่งทอง	Thung Thong	71110	2025-12-18 04:35:49.284	7106
710607	710607	เขาน้อย	Khao Noi	71110	2025-12-18 04:35:49.285	7106
710608	710608	ม่วงชุม	Muang Chum	71110	2025-12-18 04:35:49.287	7106
710609	710609	บ้านใหม่	Ban Mai	71110	2025-12-18 04:35:49.288	7106
710610	710610	พังตรุ	Phang Tru	71110	2025-12-18 04:35:49.289	7106
710611	710611	ท่าตะคร้อ	Tha Takhro	71130	2025-12-18 04:35:49.291	7106
710612	710612	รางสาลี่	Rang Sali	71110	2025-12-18 04:35:49.292	7106
710613	710613	หนองตากยา	Nong Tak Ya	71110	2025-12-18 04:35:49.293	7106
710701	710701	ท่าขนุน	Tha Khanun	71180	2025-12-18 04:35:49.295	7107
710702	710702	ปิล๊อก	Pilok	71180	2025-12-18 04:35:49.296	7107
710703	710703	หินดาด	Hin Dat	71180	2025-12-18 04:35:49.297	7107
710704	710704	ลิ่นถิ่น	Linthin	71180	2025-12-18 04:35:49.299	7107
710705	710705	ชะแล	Chalae	71180	2025-12-18 04:35:49.3	7107
710706	710706	ห้วยเขย่ง	Huai Khayeng	71180	2025-12-18 04:35:49.301	7107
710707	710707	สหกรณ์นิคม	Sahakon Nikhom	71180	2025-12-18 04:35:49.303	7107
710801	710801	หนองลู	Nong Lu	71240	2025-12-18 04:35:49.304	7108
710802	710802	ปรังเผล	Prangphle	71240	2025-12-18 04:35:49.305	7108
710803	710803	ไล่โว่	Lai Wo	71240	2025-12-18 04:35:49.307	7108
710901	710901	พนมทวน	Phanom Thuan	71140	2025-12-18 04:35:49.308	7109
710902	710902	หนองโรง	Nong Rong	71140	2025-12-18 04:35:49.309	7109
710903	710903	ทุ่งสมอ	Thung Samo	71140	2025-12-18 04:35:49.31	7109
710904	710904	ดอนเจดีย์	Don Chedi	71140	2025-12-18 04:35:49.312	7109
710905	710905	พังตรุ	Phang Tru	71140	2025-12-18 04:35:49.313	7109
710906	710906	รางหวาย	Rang Wai	71170	2025-12-18 04:35:49.314	7109
710911	710911	หนองสาหร่าย	Nong Sarai	71140	2025-12-18 04:35:49.316	7109
710912	710912	ดอนตาเพชร	Don Ta Phet	71140	2025-12-18 04:35:49.317	7109
711001	711001	เลาขวัญ	Lao Khwan	71210	2025-12-18 04:35:49.318	7110
711002	711002	หนองโสน	Nong Sano	71210	2025-12-18 04:35:49.32	7110
711003	711003	หนองประดู่	Nong Pradu	71210	2025-12-18 04:35:49.321	7110
711004	711004	หนองปลิง	Nong Pling	71210	2025-12-18 04:35:49.323	7110
711005	711005	หนองนกแก้ว	Nong Nok Kaeo	71210	2025-12-18 04:35:49.325	7110
711006	711006	ทุ่งกระบ่ำ	Thung Krabam	71210	2025-12-18 04:35:49.326	7110
711007	711007	หนองฝ้าย	Nong Fai	71210	2025-12-18 04:35:49.328	7110
450405	450405	น้ำใส	Nam Sai	45180	2025-12-18 04:35:45.36	4504
711101	711101	ด่านมะขามเตี้ย	Dan Makham Tia	71260	2025-12-18 04:35:49.329	7111
711102	711102	กลอนโด	Klondo	71260	2025-12-18 04:35:49.33	7111
711103	711103	จรเข้เผือก	Chorakhe Phueak	71260	2025-12-18 04:35:49.332	7111
711104	711104	หนองไผ่	Nong Phai	71260	2025-12-18 04:35:49.333	7111
711201	711201	หนองปรือ	Nong Prue	71220	2025-12-18 04:35:49.334	7112
711202	711202	หนองปลาไหล	Nong Pla Lai	71220	2025-12-18 04:35:49.336	7112
711203	711203	สมเด็จเจริญ	Somdet Charoen	71220	2025-12-18 04:35:49.337	7112
711301	711301	ห้วยกระเจา	Huai Krachao	71170	2025-12-18 04:35:49.338	7113
711302	711302	วังไผ่	Wang Phai	71170	2025-12-18 04:35:49.34	7113
711303	711303	ดอนแสลบ	Don Salaep	71170	2025-12-18 04:35:49.341	7113
711304	711304	สระลงเรือ	Sa Long Ruea	71170	2025-12-18 04:35:49.342	7113
720101	720101	ท่าพี่เลี้ยง	Tha Phi Liang	72000	2025-12-18 04:35:49.344	7201
720102	720102	รั้วใหญ่	Rua Yai	72000	2025-12-18 04:35:49.345	7201
720103	720103	ทับตีเหล็ก	Thap Ti Lek	72000	2025-12-18 04:35:49.346	7201
720104	720104	ท่าระหัด	Tha Rahat	72000	2025-12-18 04:35:49.348	7201
720105	720105	ไผ่ขวาง	Phai Kwang	72000	2025-12-18 04:35:49.349	7201
720106	720106	โคกโคเฒ่า	Khok Kho Thao	72000	2025-12-18 04:35:49.35	7201
720107	720107	ดอนตาล	Don Tan	72000	2025-12-18 04:35:49.351	7201
720108	720108	ดอนมะสังข์	Don Masang	72000	2025-12-18 04:35:49.353	7201
720109	720109	พิหารแดง	Phihan Daeng	72000	2025-12-18 04:35:49.354	7201
720110	720110	ดอนกำยาน	Don Kamyan	72000	2025-12-18 04:35:49.356	7201
720111	720111	ดอนโพธิ์ทอง	Don Pho Thong	72000	2025-12-18 04:35:49.357	7201
720112	720112	บ้านโพธิ์	Ban Pho	72000	2025-12-18 04:35:49.358	7201
720113	720113	สระแก้ว	Sa Kaeo	72230	2025-12-18 04:35:49.359	7201
720114	720114	ตลิ่งชัน	Taling Chan	72230	2025-12-18 04:35:49.362	7201
720115	720115	บางกุ้ง	Bang Kung	72210	2025-12-18 04:35:49.364	7201
720116	720116	ศาลาขาว	Sala Khao	72210	2025-12-18 04:35:49.366	7201
720117	720117	สวนแตง	Suan Taeng	72210	2025-12-18 04:35:49.367	7201
720118	720118	สนามชัย	Sanam Chai	72000	2025-12-18 04:35:49.369	7201
720119	720119	โพธิ์พระยา	Pho Phraya	72000	2025-12-18 04:35:49.37	7201
720120	720120	สนามคลี	Sanam Klee	72230	2025-12-18 04:35:49.372	7201
720201	720201	เขาพระ	Khao Phra	72120	2025-12-18 04:35:49.374	7202
720202	720202	เดิมบาง	Doem Bang	72120	2025-12-18 04:35:49.375	7202
720203	720203	นางบวช	Nang Buat	72120	2025-12-18 04:35:49.377	7202
720204	720204	เขาดิน	Khao Din	72120	2025-12-18 04:35:49.378	7202
720205	720205	ปากน้ำ	Pak Nam	72120	2025-12-18 04:35:49.38	7202
720206	720206	ทุ่งคลี	Thung Khli	72120	2025-12-18 04:35:49.382	7202
720207	720207	โคกช้าง	Khok Chang	72120	2025-12-18 04:35:49.383	7202
720208	720208	หัวเขา	Hua Khao	72120	2025-12-18 04:35:49.385	7202
720210	720210	บ่อกรุ	Bo Kru	72120	2025-12-18 04:35:49.388	7202
720211	720211	วังศรีราช	Wang Si Rat	72120	2025-12-18 04:35:49.39	7202
720212	720212	ป่าสะแก	Pa Sakae	72120	2025-12-18 04:35:49.391	7202
720213	720213	ยางนอน	Yang Non	72120	2025-12-18 04:35:49.393	7202
720214	720214	หนองกระทุ่ม	Nong Krathum	72120	2025-12-18 04:35:49.395	7202
720301	720301	หนองมะค่าโมง	Nong Makha Mong	72180	2025-12-18 04:35:49.397	7203
720302	720302	ด่านช้าง	Dan Chang	72180	2025-12-18 04:35:49.399	7203
720303	720303	ห้วยขมิ้น	Huai Khamin	72180	2025-12-18 04:35:49.4	7203
720304	720304	องค์พระ	Ong Phra	72180	2025-12-18 04:35:49.402	7203
720305	720305	วังคัน	Wang Khan	72180	2025-12-18 04:35:49.403	7203
720306	720306	นิคมกระเสียว	Nikhom Krasiao	72180	2025-12-18 04:35:49.405	7203
720307	720307	วังยาว	Wang Yao	72180	2025-12-18 04:35:49.406	7203
720401	720401	โคกคราม	Khok Khram	72150	2025-12-18 04:35:49.409	7204
720402	720402	บางปลาม้า	Bang Pla Ma	72150	2025-12-18 04:35:49.411	7204
720403	720403	ตะค่า	Takha	72150	2025-12-18 04:35:49.413	7204
720404	720404	บางใหญ่	Bang Yai	72150	2025-12-18 04:35:49.415	7204
720405	720405	กฤษณา	Kritsana	72150	2025-12-18 04:35:49.416	7204
720406	720406	สาลี	Sali	72150	2025-12-18 04:35:49.418	7204
720407	720407	ไผ่กองดิน	Phai Kong Din	72150	2025-12-18 04:35:49.42	7204
720408	720408	องครักษ์	Ongkharak	72150	2025-12-18 04:35:49.421	7204
720409	720409	จรเข้ใหญ่	Chorakhe Yai	72150	2025-12-18 04:35:49.423	7204
720410	720410	บ้านแหลม	Ban Laem	72150	2025-12-18 04:35:49.425	7204
720411	720411	มะขามล้ม	Makham Lom	72150	2025-12-18 04:35:49.427	7204
720412	720412	วังน้ำเย็น	Wang Nam Yen	72150	2025-12-18 04:35:49.428	7204
720413	720413	วัดโบสถ์	Wat Bot	72150	2025-12-18 04:35:49.43	7204
720414	720414	วัดดาว	Wad Daw	72150	2025-12-18 04:35:49.432	7204
720501	720501	ศรีประจันต์	Si Prachan	72140	2025-12-18 04:35:49.434	7205
720502	720502	บ้านกร่าง	Ban Krang	72140	2025-12-18 04:35:49.436	7205
720503	720503	มดแดง	Mot Daeng	72140	2025-12-18 04:35:49.437	7205
720504	720504	บางงาม	Bang Ngam	72140	2025-12-18 04:35:49.439	7205
720505	720505	ดอนปรู	Don Pru	72140	2025-12-18 04:35:49.441	7205
720506	720506	ปลายนา	Plai Na	72140	2025-12-18 04:35:49.443	7205
720507	720507	วังหว้า	Wang Wa	72140	2025-12-18 04:35:49.444	7205
720508	720508	วังน้ำซับ	Wang Nam Sap	72140	2025-12-18 04:35:49.446	7205
720509	720509	วังยาง	Wang Yang	72140	2025-12-18 04:35:49.448	7205
720601	720601	ดอนเจดีย์	Don Chedi	72170	2025-12-18 04:35:49.45	7206
720602	720602	หนองสาหร่าย	Nong Sarai	72170	2025-12-18 04:35:49.452	7206
720603	720603	ไร่รถ	Rai Rot	72170	2025-12-18 04:35:49.454	7206
720604	720604	สระกระโจม	Sa Krachom	72250	2025-12-18 04:35:49.456	7206
720605	720605	ทะเลบก	Talae Bok	72250	2025-12-18 04:35:49.458	7206
720701	720701	สองพี่น้อง	Song Phi Nong	72110	2025-12-18 04:35:49.459	7207
720702	720702	บางเลน	Bang Len	72110	2025-12-18 04:35:49.461	7207
720703	720703	บางตาเถร	Bang Ta Then	72110	2025-12-18 04:35:49.463	7207
720704	720704	บางตะเคียน	Bang Takhian	72110	2025-12-18 04:35:49.466	7207
720705	720705	บ้านกุ่ม	Ban Kum	72110	2025-12-18 04:35:49.468	7207
720706	720706	หัวโพธิ์	Hua Pho	72110	2025-12-18 04:35:49.471	7207
720707	720707	บางพลับ	Bang Phlap	72110	2025-12-18 04:35:49.473	7207
720708	720708	เนินพระปรางค์	Noen Phra Prang	72110	2025-12-18 04:35:49.476	7207
720709	720709	บ้านช้าง	Ban Chang	72110	2025-12-18 04:35:49.479	7207
720710	720710	ต้นตาล	Ton Tan	72110	2025-12-18 04:35:49.481	7207
720711	720711	ศรีสำราญ	Si Samran	72110	2025-12-18 04:35:49.483	7207
720712	720712	ทุ่งคอก	Thung Khok	72190	2025-12-18 04:35:49.485	7207
720713	720713	หนองบ่อ	Nong Bo	72110	2025-12-18 04:35:49.488	7207
720714	720714	บ่อสุพรรณ	Bo Suphan	72190	2025-12-18 04:35:49.491	7207
720715	720715	ดอนมะนาว	Don Manao	72110	2025-12-18 04:35:49.492	7207
720801	720801	ย่านยาว	Yan Yao	72130	2025-12-18 04:35:49.495	7208
720802	720802	วังลึก	Wang Luek	72130	2025-12-18 04:35:49.497	7208
720803	720803	สามชุก	Sam Chuk	72130	2025-12-18 04:35:49.5	7208
720804	720804	หนองผักนาก	Nong Phak Nak	72130	2025-12-18 04:35:49.502	7208
720805	720805	บ้านสระ	Ban Sa	72130	2025-12-18 04:35:49.505	7208
720806	720806	หนองสะเดา	Nong Sadao	72130	2025-12-18 04:35:49.508	7208
720807	720807	กระเสียว	Krasiao	72130	2025-12-18 04:35:49.51	7208
720901	720901	อู่ทอง	U Thong	72160	2025-12-18 04:35:49.513	7209
720902	720902	สระยายโสม	Sa Yai Som	72220	2025-12-18 04:35:49.515	7209
720903	720903	จรเข้สามพัน	Chorakhe Sam Phan	72160	2025-12-18 04:35:49.518	7209
720904	720904	บ้านดอน	Ban Don	72160	2025-12-18 04:35:49.521	7209
720905	720905	ยุ้งทะลาย	Yung Thalai	72160	2025-12-18 04:35:49.525	7209
720906	720906	ดอนมะเกลือ	Don Makluea	72220	2025-12-18 04:35:49.527	7209
720907	720907	หนองโอ่ง	Nong Ong	72160	2025-12-18 04:35:49.531	7209
720908	720908	ดอนคา	Don Kha	72160	2025-12-18 04:35:49.533	7209
720909	720909	พลับพลาไชย	Phlapphla Chai	72160	2025-12-18 04:35:49.535	7209
720910	720910	บ้านโข้ง	Ban Khong	72160	2025-12-18 04:35:49.537	7209
720911	720911	เจดีย์	Chedi	72160	2025-12-18 04:35:49.54	7209
720912	720912	สระพังลาน	Sa Phang Lan	72220	2025-12-18 04:35:49.543	7209
720913	720913	กระจัน	Krachan	72160	2025-12-18 04:35:49.545	7209
721001	721001	หนองหญ้าไซ	Nong Ya Sai	72240	2025-12-18 04:35:49.547	7210
721002	721002	หนองราชวัตร	Nong Ratchawat	72240	2025-12-18 04:35:49.549	7210
721003	721003	หนองโพธิ์	Nong Pho	72240	2025-12-18 04:35:49.551	7210
721004	721004	แจงงาม	Chaeng Ngam	72240	2025-12-18 04:35:49.554	7210
721005	721005	หนองขาม	Nong Kham	72240	2025-12-18 04:35:49.556	7210
721006	721006	ทัพหลวง	Thap Luang	72240	2025-12-18 04:35:49.559	7210
730101	730101	พระปฐมเจดีย์	Phra Pathom Chedi	73000	2025-12-18 04:35:49.561	7301
730102	730102	บางแขม	Bang Khaem	73000	2025-12-18 04:35:49.563	7301
730103	730103	พระประโทน	Phra Prathon	73000	2025-12-18 04:35:49.564	7301
730104	730104	ธรรมศาลา	Thammasala	73000	2025-12-18 04:35:49.566	7301
730105	730105	ตาก้อง	Ta Kong	73000	2025-12-18 04:35:49.568	7301
730106	730106	มาบแค	Map Khae	73000	2025-12-18 04:35:49.57	7301
730107	730107	สนามจันทร์	Sanam Chan	73000	2025-12-18 04:35:49.572	7301
730108	730108	ดอนยายหอม	Don Yai Hom	73000	2025-12-18 04:35:49.574	7301
730109	730109	ถนนขาด	Thanon Khat	73000	2025-12-18 04:35:49.576	7301
730110	730110	บ่อพลับ	Bo Phlap	73000	2025-12-18 04:35:49.577	7301
730111	730111	นครปฐม	Nakhon Pathom	73000	2025-12-18 04:35:49.579	7301
730112	730112	วังตะกู	Wang Taku	73000	2025-12-18 04:35:49.58	7301
730113	730113	หนองปากโลง	Nong Pak Long	73000	2025-12-18 04:35:49.582	7301
730114	730114	สามควายเผือก	Sam Khwai Phueak	73000	2025-12-18 04:35:49.585	7301
730115	730115	ทุ่งน้อย	Thung Noi	73000	2025-12-18 04:35:49.586	7301
730116	730116	หนองดินแดง	Nong Din Daeng	73000	2025-12-18 04:35:49.589	7301
730117	730117	วังเย็น	Wang Yen	73000	2025-12-18 04:35:49.59	7301
730118	730118	โพรงมะเดื่อ	Phrong Maduea	73000	2025-12-18 04:35:49.592	7301
730119	730119	ลำพยา	Lam Phaya	73000	2025-12-18 04:35:49.593	7301
730120	730120	สระกะเทียม	Sa Kathiam	73000	2025-12-18 04:35:49.596	7301
730121	730121	สวนป่าน	Suan Pan	73000	2025-12-18 04:35:49.598	7301
730122	730122	ห้วยจรเข้	Huai Chorakhe	73000	2025-12-18 04:35:49.6	7301
730123	730123	ทัพหลวง	Thap Luang	73000	2025-12-18 04:35:49.602	7301
730124	730124	หนองงูเหลือม	Nong Ngulueam	73000	2025-12-18 04:35:49.604	7301
730125	730125	บ้านยาง	Ban Yang	73000	2025-12-18 04:35:49.605	7301
730201	730201	ทุ่งกระพังโหม	Thung Kraphanghom	73140	2025-12-18 04:35:49.607	7302
730202	730202	กระตีบ	Kratip	73180	2025-12-18 04:35:49.609	7302
730203	730203	ทุ่งลูกนก	Thung Luk Nok	73140	2025-12-18 04:35:49.611	7302
730204	730204	ห้วยขวาง	Huai Khwang	73140	2025-12-18 04:35:49.613	7302
730205	730205	ทุ่งขวาง	Thung Khwang	73140	2025-12-18 04:35:49.614	7302
730206	730206	สระสี่มุม	Sa Si Mum	73140	2025-12-18 04:35:49.616	7302
730207	730207	ทุ่งบัว	Thung Bua	73140	2025-12-18 04:35:49.618	7302
730209	730209	สระพัฒนา	Sa Phatthana	73180	2025-12-18 04:35:49.621	7302
730210	730210	ห้วยหมอนทอง	Huai Mon Thong	73140	2025-12-18 04:35:49.622	7302
730211	730211	ห้วยม่วง	Huai Muang	73180	2025-12-18 04:35:49.624	7302
730212	730212	กำแพงแสน	Kamphaeng Saen	73140	2025-12-18 04:35:49.625	7302
730213	730213	รางพิกุล	Rang Phikun	73140	2025-12-18 04:35:49.627	7302
730214	730214	หนองกระทุ่ม	Nong Krathum	73140	2025-12-18 04:35:49.628	7302
730215	730215	วังน้ำเขียว	Wang Nam Khiao	73140	2025-12-18 04:35:49.63	7302
730301	730301	นครชัยศรี	Nakhon Chai Si	73120	2025-12-18 04:35:49.632	7303
730302	730302	บางกระเบา	Bang Krabao	73120	2025-12-18 04:35:49.633	7303
730303	730303	วัดแค	Wat Khae	73120	2025-12-18 04:35:49.634	7303
730304	730304	ท่าตำหนัก	Tha Tamnak	73120	2025-12-18 04:35:49.636	7303
730305	730305	บางแก้ว	Bang Kaeo	73120	2025-12-18 04:35:49.637	7303
730306	730306	ท่ากระชับ	Tha Krachap	73120	2025-12-18 04:35:49.638	7303
730307	730307	ขุนแก้ว	Khun Kaeo	73120	2025-12-18 04:35:49.639	7303
730308	730308	ท่าพระยา	Tha Phraya	73120	2025-12-18 04:35:49.641	7303
730309	730309	พะเนียด	Phaniat	73120	2025-12-18 04:35:49.642	7303
730310	730310	บางระกำ	Bang Rakam	73120	2025-12-18 04:35:49.643	7303
730311	730311	โคกพระเจดีย์	Khok Phra Chedi	73120	2025-12-18 04:35:49.644	7303
730312	730312	ศรีษะทอง	Sisa Thong	73120	2025-12-18 04:35:49.646	7303
730313	730313	แหลมบัว	Laem Bua	73120	2025-12-18 04:35:49.647	7303
730314	730314	ศรีมหาโพธิ์	Si Maha Pho	73120	2025-12-18 04:35:49.648	7303
730315	730315	สัมปทวน	Sampathuan	73120	2025-12-18 04:35:49.649	7303
730316	730316	วัดสำโรง	Wat Samrong	73120	2025-12-18 04:35:49.652	7303
730317	730317	ดอนแฝก	Don Faek	73120	2025-12-18 04:35:49.653	7303
730318	730318	ห้วยพลู	Huai Phlu	73120	2025-12-18 04:35:49.655	7303
730319	730319	วัดละมุด	Wat Lamut	73120	2025-12-18 04:35:49.656	7303
730320	730320	บางพระ	Bang Phra	73120	2025-12-18 04:35:49.658	7303
730321	730321	บางแก้วฟ้า	Bang Kaeo Fa	73120	2025-12-18 04:35:49.659	7303
730322	730322	ลานตากฟ้า	Lan Tak Fa	73120	2025-12-18 04:35:49.661	7303
730323	730323	งิ้วราย	Ngio Rai	73120	2025-12-18 04:35:49.662	7303
730324	730324	ไทยาวาส	Thaiyawat	73120	2025-12-18 04:35:49.663	7303
730401	730401	สามง่าม	Sam Ngam	73150	2025-12-18 04:35:49.664	7304
730402	730402	ห้วยพระ	Huai Phra	73150	2025-12-18 04:35:49.666	7304
730403	730403	ลำเหย	Lam Hoei	73150	2025-12-18 04:35:49.667	7304
730404	730404	ดอนพุทรา	Don Phutsa	73150	2025-12-18 04:35:49.669	7304
730405	730405	บ้านหลวง	Ban Luang	73150	2025-12-18 04:35:49.67	7304
730406	730406	ดอนรวก	Don Ruak	73150	2025-12-18 04:35:49.672	7304
730407	730407	ห้วยด้วน	Huai Duan	73150	2025-12-18 04:35:49.674	7304
730408	730408	ลำลูกบัว	Lam Luk Bua	73150	2025-12-18 04:35:49.676	7304
730501	730501	บางเลน	Bang Len	73130	2025-12-18 04:35:49.677	7305
730502	730502	บางปลา	Bang Pla	73130	2025-12-18 04:35:49.679	7305
730503	730503	บางหลวง	Bang Luang	73190	2025-12-18 04:35:49.681	7305
730504	730504	บางภาษี	Bang Phasi	73130	2025-12-18 04:35:49.682	7305
730505	730505	บางระกำ	Bang Rakam	73130	2025-12-18 04:35:49.683	7305
730506	730506	บางไทรป่า	Bang Sai Pa	73130	2025-12-18 04:35:49.685	7305
730507	730507	หินมูล	Hin Mun	73190	2025-12-18 04:35:49.688	7305
730508	730508	ไทรงาม	Sai Ngam	73130	2025-12-18 04:35:49.691	7305
730509	730509	ดอนตูม	Don Tum	73130	2025-12-18 04:35:49.694	7305
730510	730510	นิลเพชร	Ninlaphet	73130	2025-12-18 04:35:49.697	7305
730511	730511	บัวปากท่า	Bua Pak Tha	73130	2025-12-18 04:35:49.699	7305
730512	730512	คลองนกกระทุง	Khlong Nok Krathung	73130	2025-12-18 04:35:49.701	7305
730513	730513	นราภิรมย์	Naraphirom	73130	2025-12-18 04:35:49.703	7305
730514	730514	ลำพญา	Lam Phaya	73130	2025-12-18 04:35:49.705	7305
730515	730515	ไผ่หูช้าง	Phai Hu Chang	73130	2025-12-18 04:35:49.707	7305
730601	730601	ท่าข้าม	Tha Kham	73110	2025-12-18 04:35:49.709	7306
730602	730602	ทรงคนอง	Song Khanong	73210	2025-12-18 04:35:49.711	7306
730603	730603	หอมเกร็ด	Hom Kret	73110	2025-12-18 04:35:49.713	7306
730604	730604	บางกระทึก	Bang Krathuek	73210	2025-12-18 04:35:49.715	7306
730605	730605	บางเตย	Bang Toei	73210	2025-12-18 04:35:49.717	7306
730606	730606	สามพราน	Sam Phran	73110	2025-12-18 04:35:49.719	7306
730607	730607	บางช้าง	Bang Chang	73110	2025-12-18 04:35:49.721	7306
730608	730608	ไร่ขิง	Rai Khing	73210	2025-12-18 04:35:49.722	7306
730609	730609	ท่าตลาด	Tha Talat	73110	2025-12-18 04:35:49.724	7306
730610	730610	กระทุ่มล้ม	Krathum Lom	73220	2025-12-18 04:35:49.726	7306
730611	730611	คลองใหม่	Khlong Mai	73110	2025-12-18 04:35:49.729	7306
730612	730612	ตลาดจินดา	Talat Chinda	73110	2025-12-18 04:35:49.73	7306
730613	730613	คลองจินดา	Khlong Chinda	73110	2025-12-18 04:35:49.733	7306
730614	730614	ยายชา	Yai Cha	73110	2025-12-18 04:35:49.735	7306
730615	730615	บ้านใหม่	Ban Mai	73110	2025-12-18 04:35:49.737	7306
730616	730616	อ้อมใหญ่	Om Yai	73160	2025-12-18 04:35:49.739	7306
730701	730701	ศาลายา	Sala Ya	73170	2025-12-18 04:35:49.741	7307
730702	730702	คลองโยง	Khlong Yong	73170	2025-12-18 04:35:49.744	7307
730703	730703	มหาสวัสดิ์	Maha Sawat	73170	2025-12-18 04:35:49.746	7307
740101	740101	มหาชัย	Maha Chai	74000	2025-12-18 04:35:49.748	7401
740102	740102	ท่าฉลอม	Tha Chalom	74000	2025-12-18 04:35:49.75	7401
740103	740103	โกรกกราก	Krok Krak	74000	2025-12-18 04:35:49.752	7401
740104	740104	บ้านบ่อ	Ban Bo	74000	2025-12-18 04:35:49.754	7401
740105	740105	บางโทรัด	Bang Tho Rat	74000	2025-12-18 04:35:49.756	7401
740106	740106	กาหลง	Ka Long	74000	2025-12-18 04:35:49.758	7401
740107	740107	นาโคก	Na Khok	74000	2025-12-18 04:35:49.76	7401
740108	740108	ท่าจีน	Tha Chin	74000	2025-12-18 04:35:49.762	7401
740109	740109	นาดี	Na Di	74000	2025-12-18 04:35:49.764	7401
740110	740110	ท่าทราย	Tha Sai	74000	2025-12-18 04:35:49.766	7401
740111	740111	คอกกระบือ	Khok Krabue	74000	2025-12-18 04:35:49.768	7401
740112	740112	บางน้ำจืด	Bang Nam Chuet	74000	2025-12-18 04:35:49.77	7401
740113	740113	พันท้ายนรสิงห์	Phan Thai Norasing	74000	2025-12-18 04:35:49.772	7401
740114	740114	โคกขาม	Khok Kham	74000	2025-12-18 04:35:49.775	7401
740115	740115	บ้านเกาะ	Ban Ko	74000	2025-12-18 04:35:49.777	7401
740116	740116	บางกระเจ้า	Bang Krachao	74000	2025-12-18 04:35:49.779	7401
740117	740117	บางหญ้าแพรก	Bang Ya Phraek	74000	2025-12-18 04:35:49.781	7401
740118	740118	ชัยมงคล	Chai Mongkon	74000	2025-12-18 04:35:49.783	7401
740201	740201	ตลาดกระทุ่มแบน	Talat Krathum Baen	74110	2025-12-18 04:35:49.785	7402
740202	740202	อ้อมน้อย	Om Noi	74130	2025-12-18 04:35:49.787	7402
740203	740203	ท่าไม้	Tha Mai	74110	2025-12-18 04:35:49.789	7402
740204	740204	สวนหลวง	Suan Luang	74110	2025-12-18 04:35:49.791	7402
740205	740205	บางยาง	Bang Yang	74110	2025-12-18 04:35:49.792	7402
740206	740206	คลองมะเดื่อ	Khlong Maduea	74110	2025-12-18 04:35:49.794	7402
740207	740207	หนองนกไข่	Nong Nok Khai	74110	2025-12-18 04:35:49.796	7402
740208	740208	ดอนไก่ดี	Don Kai Di	74110	2025-12-18 04:35:49.797	7402
740209	740209	แคราย	Khae Rai	74110	2025-12-18 04:35:49.799	7402
740210	740210	ท่าเสา	Tha Sao	74110	2025-12-18 04:35:49.801	7402
740301	740301	บ้านแพ้ว	Ban Phaeo	74120	2025-12-18 04:35:49.804	7403
740302	740302	หลักสาม	Lak Sam	74120	2025-12-18 04:35:49.806	7403
740303	740303	ยกกระบัตร	Yokkrabat	74120	2025-12-18 04:35:49.808	7403
740304	740304	โรงเข้	Rong Khe	74120	2025-12-18 04:35:49.81	7403
740305	740305	หนองสองห้อง	Nong Song Hong	74120	2025-12-18 04:35:49.812	7403
740306	740306	หนองบัว	Nong Bua	74120	2025-12-18 04:35:49.814	7403
740307	740307	หลักสอง	Lak Song	74120	2025-12-18 04:35:49.816	7403
740308	740308	เจ็ดริ้ว	Chet Rio	74120	2025-12-18 04:35:49.818	7403
740309	740309	คลองตัน	Khlong Tan	74120	2025-12-18 04:35:49.82	7403
740310	740310	อำแพง	Amphaeng	74120	2025-12-18 04:35:49.822	7403
740311	740311	สวนส้ม	Suan Som	74120	2025-12-18 04:35:49.825	7403
740312	740312	เกษตรพัฒนา	Kaset Phatthana	74120	2025-12-18 04:35:49.827	7403
750101	750101	แม่กลอง	Mae Klong	75000	2025-12-18 04:35:49.829	7501
750102	750102	บางขันแตก	Bang Khan Taek	75000	2025-12-18 04:35:49.831	7501
750103	750103	ลาดใหญ่	Lat Yai	75000	2025-12-18 04:35:49.833	7501
750104	750104	บ้านปรก	Ban Prok	75000	2025-12-18 04:35:49.835	7501
750105	750105	บางแก้ว	Bang Kaeo	75000	2025-12-18 04:35:49.837	7501
750106	750106	ท้ายหาด	Thai Hat	75000	2025-12-18 04:35:49.84	7501
750107	750107	แหลมใหญ่	Laem Yai	75000	2025-12-18 04:35:49.842	7501
750108	750108	คลองเขิน	Khlong Khoen	75000	2025-12-18 04:35:49.844	7501
750109	750109	คลองโคน	Khlong Khon	75000	2025-12-18 04:35:49.846	7501
750110	750110	นางตะเคียน	Nang Takhian	75000	2025-12-18 04:35:49.848	7501
750111	750111	บางจะเกร็ง	Bang Chakreng	75000	2025-12-18 04:35:49.85	7501
750201	750201	กระดังงา	Kradangnga	75120	2025-12-18 04:35:49.854	7502
750202	750202	บางสะแก	Bang Sakae	75120	2025-12-18 04:35:49.856	7502
750203	750203	บางยี่รงค์	Bang Yi Rong	75120	2025-12-18 04:35:49.858	7502
750204	750204	โรงหีบ	Rong Hip	75120	2025-12-18 04:35:49.861	7502
750205	750205	บางคนที	Bang Khonthi	75120	2025-12-18 04:35:49.863	7502
750206	750206	ดอนมะโนรา	Don Manora	75120	2025-12-18 04:35:49.865	7502
750207	750207	บางพรม	Bang Phrom	75120	2025-12-18 04:35:49.867	7502
750208	750208	บางกุ้ง	Bang Kung	75120	2025-12-18 04:35:49.87	7502
750209	750209	จอมปลวก	Chom Pluak	75120	2025-12-18 04:35:49.872	7502
750210	750210	บางนกแขวก	Bang Nok Khwaek	75120	2025-12-18 04:35:49.874	7502
750211	750211	ยายแพง	Yai Phaeng	75120	2025-12-18 04:35:49.876	7502
750212	750212	บางกระบือ	Bang Krabue	75120	2025-12-18 04:35:49.878	7502
750213	750213	บ้านปราโมทย์	Ban Pramot	75120	2025-12-18 04:35:49.88	7502
750301	750301	อัมพวา	Amphawa	75110	2025-12-18 04:35:49.883	7503
750302	750302	สวนหลวง	Suan Luang	75110	2025-12-18 04:35:49.885	7503
750303	750303	ท่าคา	Tha Kha	75110	2025-12-18 04:35:49.886	7503
750304	750304	วัดประดู่	Wat Pradu	75110	2025-12-18 04:35:49.888	7503
750305	750305	เหมืองใหม่	Mueang Mai	75110	2025-12-18 04:35:49.891	7503
750306	750306	บางช้าง	Bang Chang	75110	2025-12-18 04:35:49.892	7503
750307	750307	แควอ้อม	Khwae Om	75110	2025-12-18 04:35:49.894	7503
750308	750308	ปลายโพงพาง	Plai Phongphang	75110	2025-12-18 04:35:49.896	7503
750309	750309	บางแค	Bang Khae	75110	2025-12-18 04:35:49.898	7503
750310	750310	แพรกหนามแดง	Phraek Nam Daeng	75110	2025-12-18 04:35:49.899	7503
750311	750311	ยี่สาร	Yi San	75110	2025-12-18 04:35:49.901	7503
750312	750312	บางนางลี่	Bang Nang Lee	75110	2025-12-18 04:35:49.903	7503
760101	760101	ท่าราบ	Tha Rap	76000	2025-12-18 04:35:49.905	7601
760102	760102	คลองกระแชง	Khlong Krachaeng	76000	2025-12-18 04:35:49.908	7601
760103	760103	บางจาน	Bang Chan	76000	2025-12-18 04:35:49.909	7601
760104	760104	นาพันสาม	Na Phan Sam	76000	2025-12-18 04:35:49.911	7601
760105	760105	ธงชัย	Thong Chai	76000	2025-12-18 04:35:49.913	7601
760106	760106	บ้านกุ่ม	Ban Kum	76000	2025-12-18 04:35:49.915	7601
760107	760107	หนองโสน	Nong Sano	76000	2025-12-18 04:35:49.917	7601
760108	760108	ไร่ส้ม	Rai Som	76000	2025-12-18 04:35:49.918	7601
760109	760109	เวียงคอย	Wiang Khoi	76000	2025-12-18 04:35:49.92	7601
760110	760110	บางจาก	Bang Chak	76000	2025-12-18 04:35:49.921	7601
760111	760111	บ้านหม้อ	Ban Mo	76000	2025-12-18 04:35:49.923	7601
760112	760112	ต้นมะม่วง	Ton Mamuang	76000	2025-12-18 04:35:49.924	7601
760113	760113	ช่องสะแก	Chong Sakae	76000	2025-12-18 04:35:49.926	7601
760114	760114	นาวุ้ง	Na Wung	76000	2025-12-18 04:35:49.927	7601
760115	760115	สำมะโรง	Sam Marong	76000	2025-12-18 04:35:49.93	7601
760116	760116	โพพระ	Pho Phra	76000	2025-12-18 04:35:49.932	7601
760117	760117	หาดเจ้าสำราญ	Hat Chao Samran	76100	2025-12-18 04:35:49.933	7601
760118	760118	หัวสะพาน	Hua Saphan	76000	2025-12-18 04:35:49.934	7601
760119	760119	ต้นมะพร้าว	Ton Maphrao	76000	2025-12-18 04:35:49.936	7601
760120	760120	วังตะโก	Wang Tako	76000	2025-12-18 04:35:49.937	7601
760121	760121	โพไร่หวาน	Pho Rai Wan	76000	2025-12-18 04:35:49.938	7601
760122	760122	ดอนยาง	Don Yang	76000	2025-12-18 04:35:49.94	7601
760123	760123	หนองขนาน	Nong Khanan	76000	2025-12-18 04:35:49.941	7601
760124	760124	หนองพลับ	Nong Phlap	76000	2025-12-18 04:35:49.942	7601
760201	760201	เขาย้อย	Khao Yoi	76140	2025-12-18 04:35:49.943	7602
760202	760202	สระพัง	Sa Phang	76140	2025-12-18 04:35:49.945	7602
760203	760203	บางเค็ม	Bang Khem	76140	2025-12-18 04:35:49.946	7602
760204	760204	ทับคาง	Thap Khang	76140	2025-12-18 04:35:49.947	7602
760205	760205	หนองปลาไหล	Nong Pla Lai	76140	2025-12-18 04:35:49.949	7602
760206	760206	หนองปรง	Nong Prong	76140	2025-12-18 04:35:49.952	7602
760207	760207	หนองชุมพล	Nong Chumphon	76140	2025-12-18 04:35:49.953	7602
760208	760208	ห้วยโรง	Huai Rong	76140	2025-12-18 04:35:49.954	7602
760209	760209	ห้วยท่าช้าง	Huai Tha Chang	76140	2025-12-18 04:35:49.956	7602
760210	760210	หนองชุมพลเหนือ	Nong Chumphon Nuea	76140	2025-12-18 04:35:49.957	7602
760301	760301	หนองหญ้าปล้อง	Nong Ya Plong	76160	2025-12-18 04:35:49.958	7603
760302	760302	ยางน้ำกลัดเหนือ	Yang Nam Klat Nuea	76160	2025-12-18 04:35:49.959	7603
760303	760303	ยางน้ำกลัดใต้	Yang Nam Klat Tai	76160	2025-12-18 04:35:49.961	7603
760304	760304	ท่าตะคร้อ	Tha Takror	76160	2025-12-18 04:35:49.962	7603
760402	760402	บางเก่า	Bang Kao	76120	2025-12-18 04:35:49.964	7604
760403	760403	นายาง	Na Yang	76120	2025-12-18 04:35:49.966	7604
760404	760404	เขาใหญ่	Khao Yai	76120	2025-12-18 04:35:49.967	7604
760405	760405	หนองศาลา	Nong Sala	76120	2025-12-18 04:35:49.968	7604
760406	760406	ห้วยทรายเหนือ	Huai Sai Nuea	76120	2025-12-18 04:35:49.969	7604
760407	760407	ไร่ใหม่พัฒนา	Rai Mai Phatthana	76120	2025-12-18 04:35:49.97	7604
760408	760408	สามพระยา	Sam Phraya	76120	2025-12-18 04:35:49.972	7604
760409	760409	ดอนขุนห้วย	Don Khun Huai	76120	2025-12-18 04:35:49.973	7604
760501	760501	ท่ายาง	Tha Yang	76130	2025-12-18 04:35:49.974	7605
760502	760502	ท่าคอย	Tha Khoi	76130	2025-12-18 04:35:49.975	7605
760503	760503	ยางหย่อง	Yang Yong	76130	2025-12-18 04:35:49.976	7605
760504	760504	หนองจอก	Nong Chok	76130	2025-12-18 04:35:49.978	7605
760505	760505	มาบปลาเค้า	Map Pla Khao	76130	2025-12-18 04:35:49.979	7605
760506	760506	ท่าไม้รวก	Tha Mai Ruak	76130	2025-12-18 04:35:49.98	7605
760507	760507	วังไคร้	Wang Khrai	76130	2025-12-18 04:35:49.981	7605
760511	760511	กลัดหลวง	Klat Luang	76130	2025-12-18 04:35:49.983	7605
760512	760512	ปึกเตียน	Puek Tian	76130	2025-12-18 04:35:49.984	7605
760513	760513	เขากระปุก	Khao Krapuk	76130	2025-12-18 04:35:49.985	7605
760514	760514	ท่าแลง	Tha Laeng	76130	2025-12-18 04:35:49.986	7605
760515	760515	บ้านในดง	Ban Nai Dong	76130	2025-12-18 04:35:49.988	7605
760601	760601	บ้านลาด	Ban Lat	76150	2025-12-18 04:35:49.989	7606
760602	760602	บ้านหาด	Ban Hat	76150	2025-12-18 04:35:49.99	7606
760603	760603	บ้านทาน	Ban Than	76150	2025-12-18 04:35:49.991	7606
760604	760604	ตำหรุ	Tamru	76150	2025-12-18 04:35:49.993	7606
760605	760605	สมอพลือ	Samo Phlue	76150	2025-12-18 04:35:49.994	7606
760606	760606	ไร่มะขาม	Rai Makham	76150	2025-12-18 04:35:49.995	7606
760607	760607	ท่าเสน	Tha Sen	76150	2025-12-18 04:35:49.996	7606
760608	760608	หนองกระเจ็ด	Nong Krachet	76150	2025-12-18 04:35:49.998	7606
760609	760609	หนองกะปุ	Nong Kapu	76150	2025-12-18 04:35:49.999	7606
760610	760610	ลาดโพธิ์	Lat Pho	76150	2025-12-18 04:35:50	7606
760611	760611	สะพานไกร	Saphan Krai	76150	2025-12-18 04:35:50.001	7606
760612	760612	ไร่โคก	Rai Khok	76150	2025-12-18 04:35:50.002	7606
760613	760613	โรงเข้	Rong Khe	76150	2025-12-18 04:35:50.004	7606
760614	760614	ไร่สะท้อน	Rai Sathon	76150	2025-12-18 04:35:50.005	7606
760615	760615	ห้วยข้อง	Huai Khong	76150	2025-12-18 04:35:50.006	7606
760616	760616	ท่าช้าง	Tha Chang	76150	2025-12-18 04:35:50.007	7606
760617	760617	ถ้ำรงค์	Tham Rong	76150	2025-12-18 04:35:50.008	7606
760618	760618	ห้วยลึก	Huay Lueg	76150	2025-12-18 04:35:50.01	7606
760701	760701	บ้านแหลม	Ban Laem	76110	2025-12-18 04:35:50.011	7607
760702	760702	บางขุนไทร	Bang Khun Sai	76110	2025-12-18 04:35:50.012	7607
760703	760703	ปากทะเล	Pak Thale	76110	2025-12-18 04:35:50.013	7607
760704	760704	บางแก้ว	Bang Kaeo	76110	2025-12-18 04:35:50.014	7607
760705	760705	แหลมผักเบี้ย	Laem Phak Bia	76100	2025-12-18 04:35:50.016	7607
760706	760706	บางตะบูน	Bang Tabun	76110	2025-12-18 04:35:50.017	7607
760707	760707	บางตะบูนออก	Bang Tabun Ok	76110	2025-12-18 04:35:50.018	7607
760708	760708	บางครก	Bang Khrok	76110	2025-12-18 04:35:50.019	7607
760709	760709	ท่าแร้ง	Tha Raeng	76110	2025-12-18 04:35:50.02	7607
760710	760710	ท่าแร้งออก	Tha Raeng Ok	76110	2025-12-18 04:35:50.022	7607
760801	760801	แก่งกระจาน	Kaeng Krachan	76170	2025-12-18 04:35:50.023	7608
760802	760802	สองพี่น้อง	Song Phi Nong	76170	2025-12-18 04:35:50.024	7608
760803	760803	วังจันทร์	Wang Chan	76170	2025-12-18 04:35:50.025	7608
760804	760804	ป่าเด็ง	Pa Deng	76170	2025-12-18 04:35:50.026	7608
760805	760805	พุสวรรค์	Phu Sawan	76170	2025-12-18 04:35:50.027	7608
760806	760806	ห้วยแม่เพรียง	Huai Mae Phriang	76170	2025-12-18 04:35:50.029	7608
770101	770101	ประจวบคีรีขันธ์	Prachuap Khiri Khan	77000	2025-12-18 04:35:50.03	7701
770102	770102	เกาะหลัก	Ko Lak	77000	2025-12-18 04:35:50.031	7701
770103	770103	คลองวาฬ	Khlong Wan	77000	2025-12-18 04:35:50.032	7701
770104	770104	ห้วยทราย	Huai Sai	77000	2025-12-18 04:35:50.033	7701
770105	770105	อ่าวน้อย	Ao Noi	77000	2025-12-18 04:35:50.034	7701
770106	770106	บ่อนอก	Bo Nok	77210	2025-12-18 04:35:50.035	7701
770202	770202	กุยเหนือ	Kui Nuea	77150	2025-12-18 04:35:50.038	7702
770204	770204	ดอนยายหนู	Don Yai Nu	77150	2025-12-18 04:35:50.04	7702
770206	770206	สามกระทาย	Sam Krathai	77150	2025-12-18 04:35:50.041	7702
770207	770207	หาดขาม	Hat Kham	77150	2025-12-18 04:35:50.042	7702
770301	770301	ทับสะแก	Thap Sakae	77130	2025-12-18 04:35:50.043	7703
770302	770302	อ่างทอง	Ang Thong	77130	2025-12-18 04:35:50.044	7703
770303	770303	นาหูกวาง	Na Hukwang	77130	2025-12-18 04:35:50.046	7703
770304	770304	เขาล้าน	Khao Lan	77130	2025-12-18 04:35:50.047	7703
770305	770305	ห้วยยาง	Huai Yang	77130	2025-12-18 04:35:50.048	7703
770306	770306	แสงอรุณ	Saeng Arun	77130	2025-12-18 04:35:50.049	7703
770401	770401	กำเนิดนพคุณ	Kamnoet Nopphakhun	77140	2025-12-18 04:35:50.05	7704
770402	770402	พงศ์ประศาสน์	Phong Prasat	77140	2025-12-18 04:35:50.051	7704
770403	770403	ร่อนทอง	Ron Thong	77230	2025-12-18 04:35:50.052	7704
770404	770404	ธงชัย	Thong Chai	77190	2025-12-18 04:35:50.053	7704
770405	770405	ชัยเกษม	Chai Kasem	77190	2025-12-18 04:35:50.055	7704
770406	770406	ทองมงคล	Thong Mongkhon	77230	2025-12-18 04:35:50.056	7704
770407	770407	แม่รำพึง	Mae Ramphueng	77140	2025-12-18 04:35:50.057	7704
770501	770501	ปากแพรก	Pak Phraek	77170	2025-12-18 04:35:50.058	7705
770502	770502	บางสะพาน	Bang Saphan	77170	2025-12-18 04:35:50.059	7705
770503	770503	ทรายทอง	Sai Thong	77170	2025-12-18 04:35:50.06	7705
770504	770504	ช้างแรก	Chang Raek	77170	2025-12-18 04:35:50.061	7705
770505	770505	ไชยราช	Chaiyarat	77170	2025-12-18 04:35:50.062	7705
770601	770601	ปราณบุรี	Pran Buri	77120	2025-12-18 04:35:50.063	7706
770602	770602	เขาน้อย	Khao Noi	77120	2025-12-18 04:35:50.065	7706
770604	770604	ปากน้ำปราณ	Pak Nam Pran	77220	2025-12-18 04:35:50.066	7706
770607	770607	หนองตาแต้ม	Nong Ta Taem	77120	2025-12-18 04:35:50.067	7706
770608	770608	วังก์พง	Wang Phong	77120	2025-12-18 04:35:50.068	7706
770609	770609	เขาจ้าว	Khao Chao	77120	2025-12-18 04:35:50.069	7706
770701	770701	หัวหิน	Hua Hin	77110	2025-12-18 04:35:50.07	7707
770702	770702	หนองแก	Nong Kae	77110	2025-12-18 04:35:50.071	7707
770703	770703	หินเหล็กไฟ	Hin Lek Fai	77110	2025-12-18 04:35:50.073	7707
770704	770704	หนองพลับ	Nong Phlap	77110	2025-12-18 04:35:50.074	7707
770705	770705	ทับใต้	Thap Tai	77110	2025-12-18 04:35:50.075	7707
770706	770706	ห้วยสัตว์ใหญ่	Huai Sat Yai	77110	2025-12-18 04:35:50.076	7707
770707	770707	บึงนคร	Bueng Nakhon	77110	2025-12-18 04:35:50.077	7707
770801	770801	สามร้อยยอด	Sam Roi Yot	77120	2025-12-18 04:35:50.078	7708
770802	770802	ศิลาลอย	Sila Loi	77180	2025-12-18 04:35:50.079	7708
770803	770803	ไร่เก่า	Rai Kao	77180	2025-12-18 04:35:50.08	7708
770804	770804	ศาลาลัย	Salalai	77180	2025-12-18 04:35:50.082	7708
770805	770805	ไร่ใหม่	Rai Mai	77180	2025-12-18 04:35:50.083	7708
800101	800101	ในเมือง	Nai Mueang	80000	2025-12-18 04:35:50.084	8001
800102	800102	ท่าวัง	Tha Wang	80000	2025-12-18 04:35:50.085	8001
800103	800103	คลัง	Khlang	80000	2025-12-18 04:35:50.086	8001
800106	800106	ท่าไร่	Tha Rai	80000	2025-12-18 04:35:50.087	8001
800107	800107	ปากนคร	Pak Nakhon	80000	2025-12-18 04:35:50.088	8001
800108	800108	นาทราย	Na Sai	80280	2025-12-18 04:35:50.09	8001
800112	800112	กำแพงเซา	Kamphaeng Sao	80280	2025-12-18 04:35:50.091	8001
800113	800113	ไชยมนตรี	Chai Montri	80000	2025-12-18 04:35:50.092	8001
800114	800114	มะม่วงสองต้น	Mamuang Song Ton	80000	2025-12-18 04:35:50.093	8001
800115	800115	นาเคียน	Na Khian	80000	2025-12-18 04:35:50.094	8001
800116	800116	ท่างิ้ว	Tha Ngio	80280	2025-12-18 04:35:50.095	8001
800118	800118	โพธิ์เสด็จ	Pho Sadet	80000	2025-12-18 04:35:50.096	8001
800119	800119	บางจาก	Bang Chak	80330	2025-12-18 04:35:50.097	8001
800120	800120	ปากพูน	Pak Phun	80000	2025-12-18 04:35:50.099	8001
800121	800121	ท่าซัก	Tha Sak	80000	2025-12-18 04:35:50.1	8001
800122	800122	ท่าเรือ	Tha Ruea	80290	2025-12-18 04:35:50.101	8001
800201	800201	พรหมโลก	Phrommalok	80320	2025-12-18 04:35:50.102	8002
800202	800202	บ้านเกาะ	Ban Ko	80320	2025-12-18 04:35:50.103	8002
800203	800203	อินคีรี	In Khiri	80320	2025-12-18 04:35:50.104	8002
800204	800204	ทอนหงส์	Thon Hong	80320	2025-12-18 04:35:50.105	8002
800205	800205	นาเรียง	Na Reang	80320	2025-12-18 04:35:50.107	8002
800301	800301	เขาแก้ว	Khao Kaeo	80230	2025-12-18 04:35:50.108	8003
800302	800302	ลานสกา	Lan Saka	80230	2025-12-18 04:35:50.109	8003
800304	800304	กำโลน	Kamlon	80230	2025-12-18 04:35:50.111	8003
800305	800305	ขุนทะเล	Khun Thale	80230	2025-12-18 04:35:50.112	8003
800401	800401	ฉวาง	Chawang	80150	2025-12-18 04:35:50.113	8004
800403	800403	ละอาย	La-ai	80250	2025-12-18 04:35:50.114	8004
800404	800404	นาแว	Na Wae	80260	2025-12-18 04:35:50.116	8004
800405	800405	ไม้เรียง	Mai Riang	80150	2025-12-18 04:35:50.117	8004
800406	800406	กะเปียด	Kapiat	80260	2025-12-18 04:35:50.118	8004
800407	800407	นากะชะ	Na Kacha	80150	2025-12-18 04:35:50.119	8004
800409	800409	ห้วยปริก	Huai Prik	80260	2025-12-18 04:35:50.12	8004
800410	800410	ไสหร้า	Saira	80150	2025-12-18 04:35:50.121	8004
800415	800415	นาเขลียง	Na Khliang	80260	2025-12-18 04:35:50.123	8004
800416	800416	จันดี	Chan Di	80250	2025-12-18 04:35:50.125	8004
800501	800501	พิปูน	Phipun	80270	2025-12-18 04:35:50.127	8005
800502	800502	กะทูน	Kathun	80270	2025-12-18 04:35:50.129	8005
800503	800503	เขาพระ	Khao Phra	80270	2025-12-18 04:35:50.13	8005
800504	800504	ยางค้อม	Yang Khom	80270	2025-12-18 04:35:50.131	8005
800505	800505	ควนกลาง	Khuan Klang	80270	2025-12-18 04:35:50.132	8005
800601	800601	เชียรใหญ่	Chian Yai	80190	2025-12-18 04:35:50.133	8006
800603	800603	ท่าขนาน	Tha Khanan	80190	2025-12-18 04:35:50.135	8006
800604	800604	บ้านกลาง	Ban Klang	80190	2025-12-18 04:35:50.136	8006
800605	800605	บ้านเนิน	Ban Noen	80190	2025-12-18 04:35:50.137	8006
800606	800606	ไสหมาก	Sai Mak	80190	2025-12-18 04:35:50.138	8006
800607	800607	ท้องลำเจียก	Thong Lamchiak	80190	2025-12-18 04:35:50.139	8006
800610	800610	เสือหึง	Suea Hueng	80190	2025-12-18 04:35:50.14	8006
110403	110403	บางจาก	Bang Chak	10130	2025-12-18 04:35:38.835	1104
800611	800611	การะเกด	Karaket	80190	2025-12-18 04:35:50.141	8006
800612	800612	เขาพระบาท	Khao Phra Bat	80190	2025-12-18 04:35:50.143	8006
800613	800613	แม่เจ้าอยู่หัว	Mae Chao Yu Hua	80190	2025-12-18 04:35:50.144	8006
800701	800701	ชะอวด	Cha-uat	80180	2025-12-18 04:35:50.145	8007
800702	800702	ท่าเสม็ด	Tha Samet	80180	2025-12-18 04:35:50.146	8007
800703	800703	ท่าประจะ	Tha Pracha	80180	2025-12-18 04:35:50.147	8007
800704	800704	เคร็ง	Khreng	80180	2025-12-18 04:35:50.148	8007
800705	800705	วังอ่าง	Wang Ang	80180	2025-12-18 04:35:50.149	8007
800706	800706	บ้านตูล	Ban Tun	80180	2025-12-18 04:35:50.15	8007
800707	800707	ขอนหาด	Khon Hat	80180	2025-12-18 04:35:50.152	8007
800708	800708	เกาะขันธ์	Khuan Nong Hong	80180	2025-12-18 04:35:50.153	8007
800709	800709	ควนหนองหงษ์	Khao Phra Thong	80180	2025-12-18 04:35:50.154	8007
800710	800710	เขาพระทอง	Nang Long	80180	2025-12-18 04:35:50.155	8007
800711	800711	นางหลง	Nang Long	80180	2025-12-18 04:35:50.156	8007
800801	800801	ท่าศาลา	Tha Sala	80160	2025-12-18 04:35:50.157	8008
800802	800802	กลาย	Klai	80160	2025-12-18 04:35:50.158	8008
800803	800803	ท่าขึ้น	Tha Khuen	80160	2025-12-18 04:35:50.16	8008
800804	800804	หัวตะพาน	Hua Taphan	80160	2025-12-18 04:35:50.161	8008
800806	800806	สระแก้ว	Sa Kaeo	80160	2025-12-18 04:35:50.162	8008
800807	800807	โมคลาน	Mokkhalan	80160	2025-12-18 04:35:50.163	8008
800809	800809	ไทยบุรี	Thai buri	80160	2025-12-18 04:35:50.164	8008
800810	800810	ดอนตะโก	Don tako	80160	2025-12-18 04:35:50.166	8008
800811	800811	ตลิ่งชัน	Taling Chan	80160	2025-12-18 04:35:50.167	8008
800813	800813	โพธิ์ทอง	Pho Thong	80160	2025-12-18 04:35:50.168	8008
800901	800901	ปากแพรก	Pak Phraek	80110	2025-12-18 04:35:50.169	8009
800902	800902	ชะมาย	Chamai	80110	2025-12-18 04:35:50.17	8009
800903	800903	หนองหงส์	Nong Hong	80110	2025-12-18 04:35:50.171	8009
800904	800904	ควนกรด	Khuan Krot	80110	2025-12-18 04:35:50.172	8009
800905	800905	นาไม้ไผ่	Na Mai Phai	80110	2025-12-18 04:35:50.174	8009
800906	800906	นาหลวงเสน	Na Luang Sen	80110	2025-12-18 04:35:50.175	8009
800907	800907	เขาโร	Khao Ro	80110	2025-12-18 04:35:50.176	8009
800908	800908	กะปาง	Kapang	80310	2025-12-18 04:35:50.177	8009
800909	800909	ที่วัง	Thi Wang	80110	2025-12-18 04:35:50.178	8009
800910	800910	น้ำตก	Namtok	80110	2025-12-18 04:35:50.179	8009
800911	800911	ถ้ำใหญ่	Tham Yai	80110	2025-12-18 04:35:50.18	8009
800912	800912	นาโพธิ์	Na Pho	80110	2025-12-18 04:35:50.182	8009
800913	800913	เขาขาว	Khao Khao	80110	2025-12-18 04:35:50.183	8009
801001	801001	นาบอน	Na Bon	80220	2025-12-18 04:35:50.184	8010
801002	801002	ทุ่งสง	Thung Song	80220	2025-12-18 04:35:50.185	8010
801003	801003	แก้วแสน	Kaeo Saen	80220	2025-12-18 04:35:50.186	8010
801102	801102	ทุ่งสัง	Thung Sang	80240	2025-12-18 04:35:50.188	8011
801103	801103	ทุ่งใหญ่	Thung Yai	80240	2025-12-18 04:35:50.19	8011
801104	801104	กุแหระ	Kurae	80240	2025-12-18 04:35:50.191	8011
801105	801105	ปริก	Prik	80240	2025-12-18 04:35:50.192	8011
801106	801106	บางรูป	Bang Rup	80240	2025-12-18 04:35:50.193	8011
801107	801107	กรุงหยัน	Krung Yan	80240	2025-12-18 04:35:50.194	8011
801201	801201	ปากพนัง	Pak Phanang	80140	2025-12-18 04:35:50.195	8012
801202	801202	คลองน้อย	Khlong Noi	80330	2025-12-18 04:35:50.196	8012
801203	801203	ป่าระกำ	Pa Rakam	80140	2025-12-18 04:35:50.197	8012
801204	801204	ชะเมา	Chamao	80330	2025-12-18 04:35:50.199	8012
801205	801205	คลองกระบือ	Khlong Krabue	80140	2025-12-18 04:35:50.2	8012
801206	801206	เกาะทวด	Ko Thuat	80330	2025-12-18 04:35:50.201	8012
801207	801207	บ้านใหม่	Ban Mai	80140	2025-12-18 04:35:50.202	8012
801208	801208	หูล่อง	Hu Long	80140	2025-12-18 04:35:50.203	8012
801209	801209	แหลมตะลุมพุก	Laem Talumphuk	80140	2025-12-18 04:35:50.204	8012
801210	801210	ปากพนังฝั่งตะวันตก	Pak Phanang Fang Tawantok	80140	2025-12-18 04:35:50.205	8012
801211	801211	บางศาลา	Bang Sala	80140	2025-12-18 04:35:50.206	8012
801212	801212	บางพระ	Bang Phra	80140	2025-12-18 04:35:50.208	8012
801213	801213	บางตะพง	Bang Taphong	80140	2025-12-18 04:35:50.209	8012
801214	801214	ปากพนังฝั่งตะวันออก	Pak Phanang Fang Tawan-ok	80140	2025-12-18 04:35:50.21	8012
801215	801215	บ้านเพิง	Ban Phoeng	80140	2025-12-18 04:35:50.211	8012
801216	801216	ท่าพยา	Tha Phaya	80140	2025-12-18 04:35:50.212	8012
801217	801217	ปากแพรก	Pak Phraek	80140	2025-12-18 04:35:50.213	8012
801218	801218	ขนาบนาก	Khanap Nak	80140	2025-12-18 04:35:50.214	8012
801301	801301	ร่อนพิบูลย์	Ron Phibun	80130	2025-12-18 04:35:50.215	8013
801303	801303	เสาธง	Sao Thong	80350	2025-12-18 04:35:50.218	8013
801304	801304	ควนเกย	Khuan Koei	80130	2025-12-18 04:35:50.219	8013
801305	801305	ควนพัง	Khuan Phang	80130	2025-12-18 04:35:50.22	8013
801306	801306	ควนชุม	Khuan Chum	80130	2025-12-18 04:35:50.221	8013
801401	801401	สิชล	Sichon	80120	2025-12-18 04:35:50.223	8014
801402	801402	ทุ่งปรัง	Thung Prang	80120	2025-12-18 04:35:50.225	8014
801403	801403	ฉลอง	Chalong	80120	2025-12-18 04:35:50.226	8014
801404	801404	เสาเภา	Sao Phao	80340	2025-12-18 04:35:50.227	8014
801405	801405	เปลี่ยน	Plian	80120	2025-12-18 04:35:50.229	8014
801406	801406	สี่ขีด	Si Khit	80120	2025-12-18 04:35:50.23	8014
801407	801407	เทพราช	Theppharat	80340	2025-12-18 04:35:50.231	8014
801408	801408	เขาน้อย	Khao Noi	80120	2025-12-18 04:35:50.233	8014
801409	801409	ทุ่งใส	Thung Sai	80120	2025-12-18 04:35:50.234	8014
801501	801501	ขนอม	Khanom	80210	2025-12-18 04:35:50.236	8015
801502	801502	ควนทอง	Khuan Thong	80210	2025-12-18 04:35:50.237	8015
801503	801503	ท้องเนียน	Thong Nian	80210	2025-12-18 04:35:50.239	8015
801601	801601	หัวไทร	Hua Sai	80170	2025-12-18 04:35:50.24	8016
470904	470904	แพด	Phaet	47250	2025-12-18 04:35:46.397	4709
801602	801602	หน้าสตน	Na Saton	80170	2025-12-18 04:35:50.242	8016
801603	801603	ทรายขาว	Sai Khao	80170	2025-12-18 04:35:50.243	8016
801604	801604	แหลม	Laem	80170	2025-12-18 04:35:50.244	8016
801605	801605	เขาพังไกร	Khao Phang Krai	80170	2025-12-18 04:35:50.246	8016
801606	801606	บ้านราม	Ban Ram	80170	2025-12-18 04:35:50.247	8016
801607	801607	บางนบ	Bang Nop	80170	2025-12-18 04:35:50.249	8016
801608	801608	ท่าซอม	Tha Som	80170	2025-12-18 04:35:50.25	8016
801609	801609	ควนชะลิก	Khuan Chalik	80170	2025-12-18 04:35:50.252	8016
801610	801610	รามแก้ว	Ram Kaeo	80170	2025-12-18 04:35:50.253	8016
801611	801611	เกาะเพชร	Ko Phet	80170	2025-12-18 04:35:50.255	8016
801701	801701	บางขัน	Bang Khan	80360	2025-12-18 04:35:50.256	8017
801702	801702	บ้านลำนาว	Ban Lamnao	80360	2025-12-18 04:35:50.258	8017
801703	801703	วังหิน	Wang Hin	80360	2025-12-18 04:35:50.259	8017
801704	801704	บ้านนิคม	Ban Nikhom	80360	2025-12-18 04:35:50.26	8017
801801	801801	ถ้ำพรรณรา	Tham Phannara	80260	2025-12-18 04:35:50.262	8018
801802	801802	คลองเส	Khlong Se	80260	2025-12-18 04:35:50.263	8018
801803	801803	ดุสิต	Dusit	80260	2025-12-18 04:35:50.265	8018
801901	801901	บ้านควนมุด	Ban Khuan Mut	80180	2025-12-18 04:35:50.266	8019
801902	801902	บ้านชะอวด	Ban Cha-uat	80180	2025-12-18 04:35:50.268	8019
801903	801903	ควนหนองคว้า	Khuan Nong Khwa	80130	2025-12-18 04:35:50.27	8019
801904	801904	ทุ่งโพธิ์	Thung Pho	80130	2025-12-18 04:35:50.271	8019
801905	801905	นาหมอบุญ	Na Mo Bun	80130	2025-12-18 04:35:50.273	8019
801906	801906	สามตำบล	Sam Tambon	80130	2025-12-18 04:35:50.274	8019
802001	802001	นาพรุ	Na Phru	80000	2025-12-18 04:35:50.276	8020
802002	802002	นาสาร	Na San	80000	2025-12-18 04:35:50.277	8020
802003	802003	ท้ายสำเภา	Thai Samphao	80000	2025-12-18 04:35:50.279	8020
802004	802004	ช้างซ้าย	Chang Sai	80000	2025-12-18 04:35:50.281	8020
802101	802101	นบพิตำ	Nopphitam	80160	2025-12-18 04:35:50.282	8021
802102	802102	กรุงชิง	Krung Ching	80160	2025-12-18 04:35:50.284	8021
802103	802103	กะหรอ	Karo	80160	2025-12-18 04:35:50.286	8021
802104	802104	นาเหรง	Na Reng	80160	2025-12-18 04:35:50.288	8021
802201	802201	ช้างกลาง	Chang Klang	80250	2025-12-18 04:35:50.289	8022
802202	802202	หลักช้าง	Lak Chang	80250	2025-12-18 04:35:50.291	8022
802203	802203	สวนขัน	Suan Kan	80250	2025-12-18 04:35:50.292	8022
802301	802301	เชียรเขา	Chian Khao	80190	2025-12-18 04:35:50.294	8023
802302	802302	ดอนตรอ	Don Tro	80290	2025-12-18 04:35:50.296	8023
802303	802303	สวนหลวง	Suan Luang	80190	2025-12-18 04:35:50.297	8023
802304	802304	ทางพูน	Thang Phun	80190	2025-12-18 04:35:50.299	8023
810101	810101	ปากน้ำ	Pak Nam	81000	2025-12-18 04:35:50.3	8101
810102	810102	กระบี่ใหญ่	Krabi Yai	81000	2025-12-18 04:35:50.302	8101
810103	810103	กระบี่น้อย	Krabi Noi	81000	2025-12-18 04:35:50.303	8101
810105	810105	เขาคราม	Khao Khram	81000	2025-12-18 04:35:50.305	8101
810106	810106	เขาทอง	Khao Thong	81000	2025-12-18 04:35:50.306	8101
810111	810111	ทับปริก	Thap Prik	81000	2025-12-18 04:35:50.308	8101
810115	810115	ไสไทย	Sai Thai	81000	2025-12-18 04:35:50.31	8101
810116	810116	อ่าวนาง	Ao Nang	81000	2025-12-18 04:35:50.311	8101
810117	810117	หนองทะเล	Nong Thale	81000	2025-12-18 04:35:50.313	8101
810118	810118	คลองประสงค์	Khlong Prasong	81000	2025-12-18 04:35:50.315	8101
810201	810201	เขาพนม	Khao Phanom	81140	2025-12-18 04:35:50.316	8102
810202	810202	เขาดิน	Khao Din	81140	2025-12-18 04:35:50.318	8102
810203	810203	สินปุน	Sin Pun	80240	2025-12-18 04:35:50.32	8102
810204	810204	พรุเตียว	Phru Tiao	81140	2025-12-18 04:35:50.321	8102
810205	810205	หน้าเขา	Na Khao	81140	2025-12-18 04:35:50.323	8102
810206	810206	โคกหาร	Khok Han	80240	2025-12-18 04:35:50.325	8102
810301	810301	เกาะลันตาใหญ่	Ko Lanta Yai	81150	2025-12-18 04:35:50.327	8103
810302	810302	เกาะลันตาน้อย	Ko Lanta Noi	81150	2025-12-18 04:35:50.329	8103
810303	810303	เกาะกลาง	Ko Klang	81120	2025-12-18 04:35:50.331	8103
810304	810304	คลองยาง	Khlong Yang	81120	2025-12-18 04:35:50.333	8103
810305	810305	ศาลาด่าน	Sala Dan	81150	2025-12-18 04:35:50.335	8103
810401	810401	คลองท่อมใต้	Khlong Thom Tai	81120	2025-12-18 04:35:50.337	8104
810402	810402	คลองท่อมเหนือ	Khlong Thom Nuea	81120	2025-12-18 04:35:50.339	8104
810403	810403	คลองพน	Khlong Phon	81170	2025-12-18 04:35:50.342	8104
810404	810404	ทรายขาว	Sai Khao	81170	2025-12-18 04:35:50.344	8104
810405	810405	ห้วยน้ำขาว	Huai Nam Khao	81120	2025-12-18 04:35:50.346	8104
810406	810406	พรุดินนา	Phru Din Na	81120	2025-12-18 04:35:50.348	8104
810407	810407	เพหลา	Phela	81120	2025-12-18 04:35:50.35	8104
810501	810501	อ่าวลึกใต้	Ao Luek Tai	81110	2025-12-18 04:35:50.353	8105
810502	810502	แหลมสัก	Laem Sak	81110	2025-12-18 04:35:50.355	8105
810503	810503	นาเหนือ	Na Nuea	81110	2025-12-18 04:35:50.357	8105
810504	810504	คลองหิน	Khlong Hin	81110	2025-12-18 04:35:50.36	8105
810505	810505	อ่าวลึกน้อย	Ao Luek Noi	81110	2025-12-18 04:35:50.362	8105
810506	810506	อ่าวลึกเหนือ	Ao Luek Nuea	81110	2025-12-18 04:35:50.364	8105
810507	810507	เขาใหญ่	Khao Yai	81110	2025-12-18 04:35:50.367	8105
810508	810508	คลองยา	Khlong Ya	81110	2025-12-18 04:35:50.369	8105
810509	810509	บ้านกลาง	Ban Klang	81110	2025-12-18 04:35:50.371	8105
810601	810601	ปลายพระยา	Plai Phraya	81160	2025-12-18 04:35:50.373	8106
810602	810602	เขาเขน	Khao Khen	81160	2025-12-18 04:35:50.375	8106
810603	810603	เขาต่อ	Khao To	81160	2025-12-18 04:35:50.378	8106
810604	810604	คีรีวง	Khiri Wong	81160	2025-12-18 04:35:50.38	8106
810701	810701	ลำทับ	Lam Thap	81120	2025-12-18 04:35:50.383	8107
810702	810702	ดินอุดม	Din Udom	81120	2025-12-18 04:35:50.386	8107
810703	810703	ทุ่งไทรทอง	Thung Sai Thong	81120	2025-12-18 04:35:50.388	8107
810704	810704	ดินแดง	Din Daeng	81120	2025-12-18 04:35:50.391	8107
810801	810801	เหนือคลอง	Nuea Khlong	81130	2025-12-18 04:35:50.393	8108
810802	810802	เกาะศรีบอยา	Ko Si Boya	81130	2025-12-18 04:35:50.395	8108
810803	810803	คลองขนาน	Khlong Khanan	81130	2025-12-18 04:35:50.398	8108
810804	810804	คลองเขม้า	Khlong Khamao	81130	2025-12-18 04:35:50.4	8108
810806	810806	ตลิ่งชัน	Taling Chan	81130	2025-12-18 04:35:50.405	8108
810807	810807	ปกาสัย	Pakasai	81130	2025-12-18 04:35:50.407	8108
810808	810808	ห้วยยูง	Huai Yung	81130	2025-12-18 04:35:50.41	8108
820101	820101	ท้ายช้าง	Thai Chang	82000	2025-12-18 04:35:50.412	8201
820102	820102	นบปริง	Nop Pring	82000	2025-12-18 04:35:50.415	8201
820103	820103	ถ้ำน้ำผุด	Tham Nam Phut	82000	2025-12-18 04:35:50.417	8201
820104	820104	บางเตย	Bang Toei	82000	2025-12-18 04:35:50.42	8201
820105	820105	ตากแดด	Tak Daet	82000	2025-12-18 04:35:50.422	8201
820106	820106	สองแพรก	Song Phraek	82000	2025-12-18 04:35:50.425	8201
820107	820107	ทุ่งคาโงก	Thung Kha Ngok	82000	2025-12-18 04:35:50.428	8201
820108	820108	เกาะปันหยี	Ko Panyi	82000	2025-12-18 04:35:50.43	8201
820109	820109	ป่ากอ	Pa Ko	82000	2025-12-18 04:35:50.432	8201
820201	820201	เกาะยาวน้อย	Ko Yao Noi	82160	2025-12-18 04:35:50.435	8202
820202	820202	เกาะยาวใหญ่	Ko Yao Yai	82160	2025-12-18 04:35:50.438	8202
820203	820203	พรุใน	Pru Nai	83000	2025-12-18 04:35:50.44	8202
820301	820301	กะปง	Kapong	82170	2025-12-18 04:35:50.443	8203
820302	820302	ท่านา	Tha Na	82170	2025-12-18 04:35:50.445	8203
820303	820303	เหมาะ	Mo	82170	2025-12-18 04:35:50.448	8203
820304	820304	เหล	Le	82170	2025-12-18 04:35:50.45	8203
820305	820305	รมณีย์	Rommani	82170	2025-12-18 04:35:50.453	8203
820401	820401	ถ้ำ	Tham	82130	2025-12-18 04:35:50.455	8204
820402	820402	กระโสม	Krasom	82130	2025-12-18 04:35:50.458	8204
820403	820403	กะไหล	Kalai	82130	2025-12-18 04:35:50.461	8204
820404	820404	ท่าอยู่	Tha Yu	82130	2025-12-18 04:35:50.464	8204
820405	820405	หล่อยูง	Lo Yung	82140	2025-12-18 04:35:50.466	8204
820406	820406	โคกกลอย	Khok Kloi	82140	2025-12-18 04:35:50.469	8204
820407	820407	คลองเคียน	Khlong Khian	82130	2025-12-18 04:35:50.472	8204
820501	820501	ตะกั่วป่า	Takua Pa	82110	2025-12-18 04:35:50.475	8205
820502	820502	บางนายสี	Bang Nai Si	82110	2025-12-18 04:35:50.478	8205
820503	820503	บางไทร	Bang Sai	82110	2025-12-18 04:35:50.481	8205
820504	820504	บางม่วง	Bang Muang	82110	2025-12-18 04:35:50.484	8205
820505	820505	ตำตัว	Tam Tua	82110	2025-12-18 04:35:50.487	8205
820506	820506	โคกเคียน	Khok Khian	82110	2025-12-18 04:35:50.489	8205
820507	820507	คึกคัก	Khuekkhak	82190	2025-12-18 04:35:50.492	8205
820508	820508	เกาะคอเขา	Ko Kho Khao	82190	2025-12-18 04:35:50.495	8205
820601	820601	คุระ	Khura	82150	2025-12-18 04:35:50.497	8206
820602	820602	บางวัน	Bang Wan	82150	2025-12-18 04:35:50.5	8206
820603	820603	เกาะพระทอง	Ko Phra Thong	82150	2025-12-18 04:35:50.503	8206
820605	820605	แม่นางขาว	Mae Nang Khao	82150	2025-12-18 04:35:50.506	8206
820701	820701	ทับปุด	Thap Put	82180	2025-12-18 04:35:50.509	8207
820702	820702	มะรุ่ย	Marui	82180	2025-12-18 04:35:50.512	8207
820703	820703	บ่อแสน	Bo Saen	82180	2025-12-18 04:35:50.515	8207
820704	820704	ถ้ำทองหลาง	Tham Thonglang	82180	2025-12-18 04:35:50.518	8207
820705	820705	โคกเจริญ	Khok Charoen	82180	2025-12-18 04:35:50.521	8207
820706	820706	บางเหรียง	Bang Riang	82180	2025-12-18 04:35:50.532	8207
820801	820801	ท้ายเหมือง	Thai Mueang	82120	2025-12-18 04:35:50.535	8208
820802	820802	นาเตย	Na Toei	82120	2025-12-18 04:35:50.538	8208
820803	820803	บางทอง	Bang Thong	82120	2025-12-18 04:35:50.541	8208
820804	820804	ทุ่งมะพร้าว	Thung Maphrao	82120	2025-12-18 04:35:50.544	8208
820805	820805	ลำภี	Lam Phi	82120	2025-12-18 04:35:50.547	8208
820806	820806	ลำแก่น	Lam Kaen	82120	2025-12-18 04:35:50.55	8208
830101	830101	ตลาดใหญ่	Talat Yai	83000	2025-12-18 04:35:50.553	8301
830102	830102	ตลาดเหนือ	Talat Nuea	83000	2025-12-18 04:35:50.556	8301
830103	830103	เกาะแก้ว	Ko Kaeo	83000	2025-12-18 04:35:50.559	8301
830104	830104	รัษฎา	Ratsada	83000	2025-12-18 04:35:50.562	8301
830105	830105	วิชิต	Wichit	83000	2025-12-18 04:35:50.566	8301
830106	830106	ฉลอง	Chalong	83130	2025-12-18 04:35:50.569	8301
830107	830107	ราไวย์	Rawai	83130	2025-12-18 04:35:50.573	8301
830108	830108	กะรน	Karon	83100	2025-12-18 04:35:50.576	8301
830201	830201	กะทู้	Kathu	83120	2025-12-18 04:35:50.579	8302
830202	830202	ป่าตอง	Pa Tong	83150	2025-12-18 04:35:50.582	8302
830203	830203	กมลา	Kamala	83150	2025-12-18 04:35:50.584	8302
830301	830301	เทพกระษัตรี	Thep Krasattri	83110	2025-12-18 04:35:50.587	8303
830302	830302	ศรีสุนทร	Si Sunthon	83110	2025-12-18 04:35:50.592	8303
830303	830303	เชิงทะเล	Choeng Thale	83110	2025-12-18 04:35:50.595	8303
830304	830304	ป่าคลอก	Pa Khlok	83110	2025-12-18 04:35:50.598	8303
830305	830305	ไม้ขาว	Mai Khao	83110	2025-12-18 04:35:50.601	8303
830306	830306	สาคู	Sakhu	83110	2025-12-18 04:35:50.605	8303
840101	840101	ตลาด	Talat	84000	2025-12-18 04:35:50.609	8401
840102	840102	มะขามเตี้ย	Makham Tia	84000	2025-12-18 04:35:50.612	8401
840103	840103	วัดประดู่	Wat Pradu	84000	2025-12-18 04:35:50.615	8401
840104	840104	ขุนทะเล	Khun Thale	84100	2025-12-18 04:35:50.618	8401
840105	840105	บางใบไม้	Bang Bai Mai	84000	2025-12-18 04:35:50.621	8401
840106	840106	บางชนะ	Bang Chana	84000	2025-12-18 04:35:50.624	8401
840107	840107	คลองน้อย	Khlong Noi	84000	2025-12-18 04:35:50.627	8401
840108	840108	บางไทร	Bang Sai	84000	2025-12-18 04:35:50.63	8401
840109	840109	บางโพธิ์	Bang Pho	84000	2025-12-18 04:35:50.634	8401
840110	840110	บางกุ้ง	Bang Kung	84000	2025-12-18 04:35:50.637	8401
840111	840111	คลองฉนาก	Khlong Chanak	84000	2025-12-18 04:35:50.64	8401
840201	840201	ท่าทองใหม่	Tha Thong	84290	2025-12-18 04:35:50.644	8402
840202	840202	ท่าทอง	Tha Thong Mai	84160	2025-12-18 04:35:50.646	8402
840203	840203	กะแดะ	Kadae	84160	2025-12-18 04:35:50.649	8402
840204	840204	ทุ่งกง	Thung Kong	84290	2025-12-18 04:35:50.652	8402
840205	840205	กรูด	Krut	84160	2025-12-18 04:35:50.657	8402
840206	840206	ช้างซ้าย	Chang Sai	84160	2025-12-18 04:35:50.66	8402
840207	840207	พลายวาส	Phlai Wat	84160	2025-12-18 04:35:50.663	8402
840208	840208	ป่าร่อน	Pa Ron	84160	2025-12-18 04:35:50.666	8402
840209	840209	ตะเคียนทอง	Takhian Thong	84160	2025-12-18 04:35:50.669	8402
840210	840210	ช้างขวา	Chang Khwa	84160	2025-12-18 04:35:50.671	8402
840211	840211	ท่าอุแท	Tha Uthae	84160	2025-12-18 04:35:50.674	8402
840212	840212	ทุ่งรัง	Thung Rung	84290	2025-12-18 04:35:50.677	8402
840213	840213	คลองสระ	Khlong Sa	84160	2025-12-18 04:35:50.681	8402
840301	840301	ดอนสัก	Don Sak	84220	2025-12-18 04:35:50.685	8403
840302	840302	ชลคราม	Chonlakhram	84160	2025-12-18 04:35:50.689	8403
840303	840303	ไชยคราม	Chaiyakhram	84220	2025-12-18 04:35:50.692	8403
840304	840304	ปากแพรก	Pak Phraek	84340	2025-12-18 04:35:50.695	8403
840401	840401	อ่างทอง	Ang Thong	84140	2025-12-18 04:35:50.697	8404
840402	840402	ลิปะน้อย	Lipa Noi	84140	2025-12-18 04:35:50.7	8404
840403	840403	ตลิ่งงาม	Taling Ngam	84140	2025-12-18 04:35:50.703	8404
840404	840404	หน้าเมือง	Na Mueang	84140	2025-12-18 04:35:50.706	8404
840405	840405	มะเร็ต	Maret	84310	2025-12-18 04:35:50.708	8404
840406	840406	บ่อผุด	Bo Phut	84320	2025-12-18 04:35:50.711	8404
840407	840407	แม่น้ำ	Mae Nam	84330	2025-12-18 04:35:50.714	8404
840501	840501	เกาะพะงัน	Ko Pha-ngan	84280	2025-12-18 04:35:50.717	8405
840502	840502	บ้านใต้	Ban Tai	84280	2025-12-18 04:35:50.72	8405
840503	840503	เกาะเต่า	Koh Tao	84280	2025-12-18 04:35:50.723	8405
840601	840601	ตลาดไชยา	Talat Chaiya	84110	2025-12-18 04:35:50.725	8406
840602	840602	พุมเรียง	Phumriang	84110	2025-12-18 04:35:50.728	8406
840603	840603	เลม็ด	Lamet	84110	2025-12-18 04:35:50.731	8406
840604	840604	เวียง	Wiang	84110	2025-12-18 04:35:50.734	8406
840605	840605	ทุ่ง	Thung	84110	2025-12-18 04:35:50.737	8406
840606	840606	ป่าเว	Pa We	84110	2025-12-18 04:35:50.74	8406
840607	840607	ตะกรบ	Takrop	84110	2025-12-18 04:35:50.743	8406
840608	840608	โมถ่าย	Mo Thai	84110	2025-12-18 04:35:50.747	8406
840609	840609	ปากหมาก	Pak Mak	84110	2025-12-18 04:35:50.75	8406
840701	840701	ท่าชนะ	Tha Chana	84170	2025-12-18 04:35:50.753	8407
840702	840702	สมอทอง	Samo Thong	84170	2025-12-18 04:35:50.757	8407
840703	840703	ประสงค์	Prasong	84170	2025-12-18 04:35:50.76	8407
840704	840704	คันธุลี	Khan Thuli	84170	2025-12-18 04:35:50.763	8407
840705	840705	วัง	Wang	84170	2025-12-18 04:35:50.766	8407
840706	840706	คลองพา	Khlong Pha	84170	2025-12-18 04:35:50.769	8407
840801	840801	ท่าขนอน	Tha Khanon	84180	2025-12-18 04:35:50.772	8408
840802	840802	บ้านยาง	Ban Yang	84180	2025-12-18 04:35:50.775	8408
840803	840803	น้ำหัก	Nam Hak	84180	2025-12-18 04:35:50.778	8408
840806	840806	กะเปา	Kapao	84180	2025-12-18 04:35:50.782	8408
840807	840807	ท่ากระดาน	Tha Kradan	84180	2025-12-18 04:35:50.785	8408
840808	840808	ย่านยาว	Yan Yao	84180	2025-12-18 04:35:50.788	8408
840809	840809	ถ้ำสิงขร	Tham Singkhon	84180	2025-12-18 04:35:50.791	8408
840810	840810	บ้านทำเนียบ	Ban Thamniap	84180	2025-12-18 04:35:50.794	8408
840901	840901	เขาวง	Khao Wong	84230	2025-12-18 04:35:50.797	8409
840902	840902	พระแสง	Phasaeng	84230	2025-12-18 04:35:50.8	8409
840903	840903	พรุไทย	Phru Thai	84230	2025-12-18 04:35:50.803	8409
840904	840904	เขาพัง	Khao Phang	84230	2025-12-18 04:35:50.806	8409
841001	841001	พนม	Phanom	84250	2025-12-18 04:35:50.809	8410
841002	841002	ต้นยวน	Ton Yuan	84250	2025-12-18 04:35:50.812	8410
841003	841003	คลองศก	Khlong Sok	84250	2025-12-18 04:35:50.815	8410
841004	841004	พลูเถื่อน	Phlu Thuean	84250	2025-12-18 04:35:50.818	8410
841005	841005	พังกาญจน์	Phang Kan	84250	2025-12-18 04:35:50.821	8410
841006	841006	คลองชะอุ่น	Khlong Cha-un	84250	2025-12-18 04:35:50.823	8410
841101	841101	ท่าฉาง	Tha Chang	84150	2025-12-18 04:35:50.826	8411
841102	841102	ท่าเคย	Tha Khoei	84150	2025-12-18 04:35:50.829	8411
841103	841103	คลองไทร	Khlong Sai	84150	2025-12-18 04:35:50.832	8411
841104	841104	เขาถ่าน	Khao Than	84150	2025-12-18 04:35:50.835	8411
841105	841105	เสวียด	Sawiat	84150	2025-12-18 04:35:50.837	8411
841106	841106	ปากฉลุย	Pak Chalui	84150	2025-12-18 04:35:50.84	8411
841201	841201	นาสาร	Na San	84120	2025-12-18 04:35:50.843	8412
841202	841202	พรุพี	Phru Phi	84270	2025-12-18 04:35:50.846	8412
841203	841203	ทุ่งเตา	Thung Tao	84120	2025-12-18 04:35:50.849	8412
841204	841204	ลำพูน	Lamphun	84120	2025-12-18 04:35:50.852	8412
841205	841205	ท่าชี	Tha Chi	84120	2025-12-18 04:35:50.854	8412
841206	841206	ควนศรี	Khuan Si	84270	2025-12-18 04:35:50.858	8412
841207	841207	ควนสุบรรณ	Khuan Suban	84120	2025-12-18 04:35:50.861	8412
841208	841208	คลองปราบ	Khlong Prap	84120	2025-12-18 04:35:50.864	8412
841209	841209	น้ำพุ	Nam Phu	84120	2025-12-18 04:35:50.867	8412
841210	841210	ทุ่งเตาใหม่	Thung Tao Mai	84120	2025-12-18 04:35:50.869	8412
841211	841211	เพิ่มพูนทรัพย์	Phoem Phun Sap	84120	2025-12-18 04:35:50.872	8412
841301	841301	บ้านนา	Ban Na	84240	2025-12-18 04:35:50.874	8413
841302	841302	ท่าเรือ	Tha Ruea	84240	2025-12-18 04:35:50.877	8413
841303	841303	ทรัพย์ทวี	Sap Thawi	84240	2025-12-18 04:35:50.88	8413
841304	841304	นาใต้	Na Tai	84240	2025-12-18 04:35:50.883	8413
841401	841401	เคียนซา	Khian Sa	84260	2025-12-18 04:35:50.886	8414
841402	841402	พ่วงพรมคร	Phuang Phromkhon	84210	2025-12-18 04:35:50.889	8414
841403	841403	เขาตอก	Khao Tok	84260	2025-12-18 04:35:50.892	8414
110404	110404	บางครุ	Bang Khru	10130	2025-12-18 04:35:38.836	1104
841404	841404	อรัญคามวารี	Aranyakham Wari	84260	2025-12-18 04:35:50.895	8414
841405	841405	บ้านเสด็จ	Ban Sadet	84260	2025-12-18 04:35:50.897	8414
841501	841501	เวียงสระ	Wiang Sa	84190	2025-12-18 04:35:50.9	8415
841502	841502	บ้านส้อง	Ban Song	84190	2025-12-18 04:35:50.903	8415
841503	841503	คลองฉนวน	Khlong Chanuan	84190	2025-12-18 04:35:50.905	8415
841504	841504	ทุ่งหลวง	Thung Luang	84190	2025-12-18 04:35:50.908	8415
841505	841505	เขานิพันธ์	*Khao Niphan	84190	2025-12-18 04:35:50.911	8415
841601	841601	อิปัน	Ipan	84210	2025-12-18 04:35:50.914	8416
841602	841602	สินปุน	Sin Pun	84210	2025-12-18 04:35:50.917	8416
841603	841603	บางสวรรค์	Bang Sawan	84210	2025-12-18 04:35:50.92	8416
841604	841604	ไทรขึง	Sai Khueng	84210	2025-12-18 04:35:50.922	8416
841605	841605	สินเจริญ	Sin Charoen	84210	2025-12-18 04:35:50.925	8416
841606	841606	ไทรโสภา	Sai Sopha	84210	2025-12-18 04:35:50.928	8416
841607	841607	สาคู	Sakhu	84210	2025-12-18 04:35:50.931	8416
841701	841701	ท่าข้าม	Tha Kham	84130	2025-12-18 04:35:50.934	8417
841702	841702	ท่าสะท้อน	Tha Sathon	84130	2025-12-18 04:35:50.937	8417
841703	841703	ลีเล็ด	Lilet	84130	2025-12-18 04:35:50.94	8417
841704	841704	บางมะเดื่อ	Bang Maduea	84130	2025-12-18 04:35:50.943	8417
841705	841705	บางเดือน	Bang Duean	84130	2025-12-18 04:35:50.946	8417
841706	841706	ท่าโรงช้าง	Tha Rong Chang	84130	2025-12-18 04:35:50.948	8417
841707	841707	กรูด	Krut	84130	2025-12-18 04:35:50.951	8417
841708	841708	พุนพิน	Phunphin	84130	2025-12-18 04:35:50.954	8417
841709	841709	บางงอน	Bang Ngon	84130	2025-12-18 04:35:50.957	8417
841710	841710	ศรีวิชัย	Si Wichai	84130	2025-12-18 04:35:50.96	8417
841711	841711	น้ำรอบ	Nam Rop	84130	2025-12-18 04:35:50.963	8417
841713	841713	หัวเตย	Hua Toei	84130	2025-12-18 04:35:50.97	8417
841714	841714	หนองไทร	Nong Sai	84130	2025-12-18 04:35:50.972	8417
841715	841715	เขาหัวควาย	Khao Hua Khwai	84130	2025-12-18 04:35:50.975	8417
841716	841716	ตะปาน	Tapan	84130	2025-12-18 04:35:50.978	8417
841801	841801	สองแพรก	Song Phraek	84350	2025-12-18 04:35:50.981	8418
841802	841802	ชัยบุรี	Chai Buri	84350	2025-12-18 04:35:50.984	8418
841803	841803	คลองน้อย	Khlong Noi	84350	2025-12-18 04:35:50.987	8418
841804	841804	ไทรทอง	Sai Thong	84350	2025-12-18 04:35:50.99	8418
841901	841901	ตะกุกใต้	Takuk Tai	84180	2025-12-18 04:35:50.992	8419
841902	841902	ตะกุกเหนือ	Takuk Nuea	84180	2025-12-18 04:35:50.996	8419
850101	850101	เขานิเวศน์	Khao Niwet	85000	2025-12-18 04:35:50.999	8501
850102	850102	ราชกรูด	Ratchakrut	85000	2025-12-18 04:35:51.002	8501
850103	850103	หงาว	Ngao	85000	2025-12-18 04:35:51.005	8501
850104	850104	บางริ้น	Bang Rin	85000	2025-12-18 04:35:51.007	8501
850105	850105	ปากน้ำ	Pak Nam	85000	2025-12-18 04:35:51.01	8501
850106	850106	บางนอน	Bang Non	85000	2025-12-18 04:35:51.012	8501
850107	850107	หาดส้มแป้น	Hat Som Paen	85000	2025-12-18 04:35:51.015	8501
850108	850108	ทรายแดง	Sai Daeng	85130	2025-12-18 04:35:51.018	8501
850109	850109	เกาะพยาม	Ko Phayam	85000	2025-12-18 04:35:51.021	8501
850201	850201	ละอุ่นใต้	La-un Tai	85130	2025-12-18 04:35:51.024	8502
850202	850202	ละอุ่นเหนือ	La-un Nuea	85130	2025-12-18 04:35:51.027	8502
850203	850203	บางพระใต้	Bang Phra Tai	85130	2025-12-18 04:35:51.029	8502
850204	850204	บางพระเหนือ	Bang Phra Nuea	85130	2025-12-18 04:35:51.032	8502
850205	850205	บางแก้ว	Bang Kaeo	85130	2025-12-18 04:35:51.035	8502
850206	850206	ในวงเหนือ	Nai Wong Nuea	85130	2025-12-18 04:35:51.038	8502
850207	850207	ในวงใต้	Nai Wong Tai	85130	2025-12-18 04:35:51.041	8502
850301	850301	ม่วงกลวง	Muang Kluang	85120	2025-12-18 04:35:51.044	8503
850302	850302	กะเปอร์	Kapoe	85120	2025-12-18 04:35:51.047	8503
850303	850303	เชี่ยวเหลียง	Chiao Liang	85120	2025-12-18 04:35:51.05	8503
850304	850304	บ้านนา	Ban Na	85120	2025-12-18 04:35:51.054	8503
850305	850305	บางหิน	Bang Hin	85120	2025-12-18 04:35:51.057	8503
850401	850401	น้ำจืด	Nam Chuet	85110	2025-12-18 04:35:51.059	8504
850402	850402	น้ำจืดน้อย	Nam Chuet Noi	85110	2025-12-18 04:35:51.063	8504
850403	850403	มะมุ	Mamu	85110	2025-12-18 04:35:51.066	8504
850404	850404	ปากจั่น	Pak Chan	85110	2025-12-18 04:35:51.069	8504
850405	850405	ลำเลียง	Lamliang	85110	2025-12-18 04:35:51.072	8504
850406	850406	จ.ป.ร.	Choporo	85110	2025-12-18 04:35:51.075	8504
850407	850407	บางใหญ่	Bang Yai	85110	2025-12-18 04:35:51.078	8504
850501	850501	นาคา	Nakha	85120	2025-12-18 04:35:51.081	8505
850502	850502	กำพวน	Kamphuan	85120	2025-12-18 04:35:51.085	8505
860101	860101	ท่าตะเภา	Tha Taphao	86000	2025-12-18 04:35:51.088	8601
860102	860102	ปากน้ำ	Pak Nam	86120	2025-12-18 04:35:51.091	8601
860103	860103	ท่ายาง	Tha Yang	86000	2025-12-18 04:35:51.094	8601
860104	860104	บางหมาก	Bang Mak	86000	2025-12-18 04:35:51.097	8601
860105	860105	นาทุ่ง	Na Thung	86000	2025-12-18 04:35:51.099	8601
860106	860106	นาชะอัง	Na Cha-ang	86000	2025-12-18 04:35:51.102	8601
860107	860107	ตากแดด	Tak Daet	86000	2025-12-18 04:35:51.104	8601
860108	860108	บางลึก	Bang Luek	86000	2025-12-18 04:35:51.107	8601
860109	860109	หาดพันไกร	Hat Phan Krai	86000	2025-12-18 04:35:51.11	8601
860110	860110	วังไผ่	Wang Phai	86000	2025-12-18 04:35:51.113	8601
860111	860111	วังใหม่	Wang Mai	86190	2025-12-18 04:35:51.116	8601
860112	860112	บ้านนา	Ban Na	86190	2025-12-18 04:35:51.119	8601
860113	860113	ขุนกระทิง	Khun Krathing	86000	2025-12-18 04:35:51.121	8601
860114	860114	ทุ่งคา	Thung Kha	86100	2025-12-18 04:35:51.124	8601
860115	860115	วิสัยเหนือ	Wisai Nuea	86100	2025-12-18 04:35:51.127	8601
860116	860116	หาดทรายรี	Hat Sai Ri	86120	2025-12-18 04:35:51.13	8601
860117	860117	ถ้ำสิงห์	Tham Sing	86100	2025-12-18 04:35:51.133	8601
860201	860201	ท่าแซะ	Tha Sae	86140	2025-12-18 04:35:51.14	8602
860202	860202	คุริง	Khuring	86140	2025-12-18 04:35:51.145	8602
860204	860204	นากระตาม	Na Kratam	86140	2025-12-18 04:35:51.156	8602
860205	860205	รับร่อ	Rap Ro	86190	2025-12-18 04:35:51.159	8602
860206	860206	ท่าข้าม	Tha Kham	86140	2025-12-18 04:35:51.161	8602
860208	860208	หินแก้ว	Hin Kaeo	86190	2025-12-18 04:35:51.165	8602
860209	860209	ทรัพย์อนันต์	Sap Anan	86140	2025-12-18 04:35:51.167	8602
860210	860210	สองพี่น้อง	Song Phi Nong	86140	2025-12-18 04:35:51.169	8602
860301	860301	บางสน	Bang Song	86160	2025-12-18 04:35:51.171	8603
860302	860302	ทะเลทรัพย์	Thale Sap	86160	2025-12-18 04:35:51.173	8603
860303	860303	สะพลี	Saphli	86230	2025-12-18 04:35:51.175	8603
860304	860304	ชุมโค	Chum Kho	86160	2025-12-18 04:35:51.177	8603
860305	860305	ดอนยาง	Don Yang	86210	2025-12-18 04:35:51.179	8603
860306	860306	ปากคลอง	Pak Khlong	86210	2025-12-18 04:35:51.181	8603
860307	860307	เขาไชยราช	Khao Chai Rat	86210	2025-12-18 04:35:51.183	8603
860401	860401	หลังสวน	Lang Suan	86110	2025-12-18 04:35:51.185	8604
860402	860402	ขันเงิน	Khan Ngoen	86110	2025-12-18 04:35:51.187	8604
860403	860403	ท่ามะพลา	Tha Maphla	86110	2025-12-18 04:35:51.189	8604
860404	860404	นาขา	Na Kha	86110	2025-12-18 04:35:51.191	8604
860405	860405	นาพญา	Na Phaya	86110	2025-12-18 04:35:51.193	8604
860406	860406	บ้านควน	Ban Khuan	86110	2025-12-18 04:35:51.195	8604
860407	860407	บางมะพร้าว	Bang Maphrao	86110	2025-12-18 04:35:51.197	8604
860408	860408	บางน้ำจืด	Bang Nam Chuet	86150	2025-12-18 04:35:51.199	8604
860409	860409	ปากน้ำ	Pak Nam	86150	2025-12-18 04:35:51.202	8604
860410	860410	พ้อแดง	Pho Daeng	86110	2025-12-18 04:35:51.204	8604
860411	860411	แหลมทราย	Laem Sai	86110	2025-12-18 04:35:51.206	8604
860412	860412	วังตะกอ	Wang Tako	86110	2025-12-18 04:35:51.208	8604
860413	860413	หาดยาย	Hat Yai	86110	2025-12-18 04:35:51.21	8604
860501	860501	ละแม	Lamae	86170	2025-12-18 04:35:51.212	8605
860502	860502	ทุ่งหลวง	Thung Luang	86170	2025-12-18 04:35:51.215	8605
860503	860503	สวนแตง	Suan Taeng	86170	2025-12-18 04:35:51.217	8605
860504	860504	ทุ่งคาวัด	Thung Kha Wat	86170	2025-12-18 04:35:51.219	8605
860601	860601	พะโต๊ะ	Phato	86180	2025-12-18 04:35:51.222	8606
860602	860602	ปากทรง	Pak Song	86180	2025-12-18 04:35:51.224	8606
860603	860603	ปังหวาน	Pang Wan	86180	2025-12-18 04:35:51.226	8606
860604	860604	พระรักษ์	Phra Rak	86180	2025-12-18 04:35:51.229	8606
860701	860701	นาโพธิ์	Na Pho	86130	2025-12-18 04:35:51.231	8607
860702	860702	สวี	Sawi	86130	2025-12-18 04:35:51.233	8607
860703	860703	ทุ่งระยะ	Thung Raya	86130	2025-12-18 04:35:51.235	8607
860704	860704	ท่าหิน	Tha Hin	86130	2025-12-18 04:35:51.237	8607
860705	860705	ปากแพรก	Pak Phraek	86130	2025-12-18 04:35:51.239	8607
860706	860706	ด่านสวี	Dan Sawi	86130	2025-12-18 04:35:51.241	8607
860707	860707	ครน	Khron	86130	2025-12-18 04:35:51.244	8607
860708	860708	วิสัยใต้	Wisai Tai	86130	2025-12-18 04:35:51.246	8607
860709	860709	นาสัก	Na Sak	86130	2025-12-18 04:35:51.248	8607
860710	860710	เขาทะลุ	Khao Thalu	86130	2025-12-18 04:35:51.25	8607
860711	860711	เขาค่าย	Khao Khai	86130	2025-12-18 04:35:51.252	8607
860801	860801	ปากตะโก	Pak Tako	86220	2025-12-18 04:35:51.255	8608
860802	860802	ทุ่งตะไคร	Thung Takhrai	86220	2025-12-18 04:35:51.257	8608
860803	860803	ตะโก	Tako	86220	2025-12-18 04:35:51.259	8608
860804	860804	ช่องไม้แก้ว	Chong Mai Kaeo	86220	2025-12-18 04:35:51.261	8608
900101	900101	บ่อยาง	Bo Yang	90000	2025-12-18 04:35:51.263	9001
900102	900102	เขารูปช้าง	Khao Rup Chang	90000	2025-12-18 04:35:51.265	9001
900103	900103	เกาะแต้ว	Ko Taeo	90000	2025-12-18 04:35:51.267	9001
900104	900104	พะวง	Phawong	90100	2025-12-18 04:35:51.269	9001
900105	900105	ทุ่งหวัง	Thung Wang	90000	2025-12-18 04:35:51.272	9001
900106	900106	เกาะยอ	Ko Yo	90100	2025-12-18 04:35:51.274	9001
900201	900201	จะทิ้งพระ	Chathing Phra	90190	2025-12-18 04:35:51.276	9002
900202	900202	กระดังงา	Kradangnga	90190	2025-12-18 04:35:51.278	9002
900203	900203	สนามชัย	Sanam Chai	90190	2025-12-18 04:35:51.281	9002
900204	900204	ดีหลวง	Di Luang	90190	2025-12-18 04:35:51.283	9002
900205	900205	ชุมพล	Chumphon	90190	2025-12-18 04:35:51.286	9002
900206	900206	คลองรี	Khlong Ri	90190	2025-12-18 04:35:51.288	9002
900207	900207	คูขุด	Khu Khut	90190	2025-12-18 04:35:51.29	9002
900208	900208	ท่าหิน	Tha Hin	90190	2025-12-18 04:35:51.292	9002
900209	900209	วัดจันทร์	Wat Chan	90190	2025-12-18 04:35:51.295	9002
900210	900210	บ่อแดง	Bo Daeng	90190	2025-12-18 04:35:51.297	9002
900211	900211	บ่อดาน	Bor Dan	90190	2025-12-18 04:35:51.3	9002
900301	900301	บ้านนา	Ban Na	90130	2025-12-18 04:35:51.302	9003
900302	900302	ป่าชิง	Pa Ching	90130	2025-12-18 04:35:51.305	9003
900303	900303	สะพานไม้แก่น	Saphan Mai Kaen	90130	2025-12-18 04:35:51.308	9003
900304	900304	สะกอม	Sakom	90130	2025-12-18 04:35:51.311	9003
900305	900305	นาหว้า	Na Wa	90130	2025-12-18 04:35:51.314	9003
900306	900306	นาทับ	Na Thap	90130	2025-12-18 04:35:51.317	9003
900307	900307	น้ำขาว	Nam Khao	90130	2025-12-18 04:35:51.32	9003
900308	900308	ขุนตัดหวาย	Khun Tat Wai	90130	2025-12-18 04:35:51.323	9003
900309	900309	ท่าหมอไทร	Tha Mo Sai	90130	2025-12-18 04:35:51.326	9003
900310	900310	จะโหนง	Chanong	90130	2025-12-18 04:35:51.329	9003
900311	900311	คู	Khu	90130	2025-12-18 04:35:51.332	9003
900312	900312	แค	Khae	90130	2025-12-18 04:35:51.335	9003
900313	900313	คลองเปียะ	Khlong Pia	90130	2025-12-18 04:35:51.337	9003
900314	900314	ตลิ่งชัน	Taling Chan	90130	2025-12-18 04:35:51.34	9003
900401	900401	นาทวี	Na Thawi	90160	2025-12-18 04:35:51.343	9004
900402	900402	ฉาง	Chang	90160	2025-12-18 04:35:51.346	9004
900403	900403	นาหมอศรี	Na Mo Si	90160	2025-12-18 04:35:51.349	9004
900404	900404	คลองทราย	Khlong Sai	90160	2025-12-18 04:35:51.352	9004
900405	900405	ปลักหนู	Plak Nu	90160	2025-12-18 04:35:51.355	9004
900406	900406	ท่าประดู่	Tha Pradu	90160	2025-12-18 04:35:51.357	9004
900407	900407	สะท้อน	Sathon	90160	2025-12-18 04:35:51.362	9004
900408	900408	ทับช้าง	Thap Chang	90160	2025-12-18 04:35:51.365	9004
900409	900409	ประกอบ	Prakop	90160	2025-12-18 04:35:51.368	9004
900410	900410	คลองกวาง	Khlong Kwang	90160	2025-12-18 04:35:51.371	9004
900501	900501	เทพา	Thepha	90150	2025-12-18 04:35:51.374	9005
900502	900502	ปากบาง	Pak Bang	90150	2025-12-18 04:35:51.377	9005
900503	900503	เกาะสะบ้า	Ko Saba	90150	2025-12-18 04:35:51.379	9005
900504	900504	ลำไพล	Lam Phlai	90260	2025-12-18 04:35:51.382	9005
900505	900505	ท่าม่วง	Tha Muang	90260	2025-12-18 04:35:51.385	9005
900506	900506	วังใหญ่	Wang Yai	90260	2025-12-18 04:35:51.388	9005
900507	900507	สะกอม	Sakom	90150	2025-12-18 04:35:51.39	9005
900601	900601	สะบ้าย้อย	Saba Yoi	90210	2025-12-18 04:35:51.393	9006
900602	900602	ทุ่งพอ	Thung Pho	90210	2025-12-18 04:35:51.396	9006
900603	900603	เปียน	Pian	90210	2025-12-18 04:35:51.399	9006
900604	900604	บ้านโหนด	Ban Not	90210	2025-12-18 04:35:51.401	9006
900605	900605	จะแหน	Chanae	90210	2025-12-18 04:35:51.404	9006
900606	900606	คูหา	Khuha	90210	2025-12-18 04:35:51.406	9006
900607	900607	เขาแดง	Khao Daeng	90210	2025-12-18 04:35:51.409	9006
900608	900608	บาโหย	Ba Hoi	90210	2025-12-18 04:35:51.412	9006
900609	900609	ธารคีรี	Than Khiri	90210	2025-12-18 04:35:51.415	9006
900701	900701	ระโนด	Ranot	90140	2025-12-18 04:35:51.418	9007
900702	900702	คลองแดน	Khlong Daen	90140	2025-12-18 04:35:51.421	9007
900703	900703	ตะเครียะ	Takhria	90140	2025-12-18 04:35:51.423	9007
900704	900704	ท่าบอน	Tha Bon	90140	2025-12-18 04:35:51.426	9007
900705	900705	บ้านใหม่	Ban Mai	90140	2025-12-18 04:35:51.429	9007
900706	900706	บ่อตรุ	Bo Tru	90140	2025-12-18 04:35:51.431	9007
900707	900707	ปากแตระ	Pak Trae	90140	2025-12-18 04:35:51.434	9007
900708	900708	พังยาง	Phang Yang	90140	2025-12-18 04:35:51.437	9007
900709	900709	ระวะ	Rawa	90140	2025-12-18 04:35:51.439	9007
900710	900710	วัดสน	Wat Son	90140	2025-12-18 04:35:51.442	9007
900711	900711	บ้านขาว	Ban Khao	90140	2025-12-18 04:35:51.445	9007
900712	900712	แดนสงวน	Daen Sa-nguan	90140	2025-12-18 04:35:51.447	9007
900801	900801	เกาะใหญ่	Ko Yai	90270	2025-12-18 04:35:51.45	9008
900802	900802	โรง	Rong	90270	2025-12-18 04:35:51.453	9008
900803	900803	เชิงแส	Choeng Sae	90270	2025-12-18 04:35:51.456	9008
900804	900804	กระแสสินธุ์	Krasae Sin	90270	2025-12-18 04:35:51.458	9008
900901	900901	กำแพงเพชร	Kamphaeng Phet	90180	2025-12-18 04:35:51.461	9009
900902	900902	ท่าชะมวง	Tha Chamuang	90180	2025-12-18 04:35:51.464	9009
900903	900903	คูหาใต้	Khuha Tai	90180	2025-12-18 04:35:51.467	9009
900904	900904	ควนรู	Khuan Ru	90180	2025-12-18 04:35:51.469	9009
900909	900909	เขาพระ	Khao Phra	90180	2025-12-18 04:35:51.472	9009
901001	901001	สะเดา	Sadao	90120	2025-12-18 04:35:51.475	9010
901002	901002	ปริก	Prik	90120	2025-12-18 04:35:51.478	9010
901003	901003	พังลา	Phang La	90170	2025-12-18 04:35:51.481	9010
901004	901004	สำนักแต้ว	Samnak Taeo	90120	2025-12-18 04:35:51.483	9010
901005	901005	ทุ่งหมอ	Thung Mo	90240	2025-12-18 04:35:51.486	9010
901006	901006	ท่าโพธิ์	Tha Pho	90170	2025-12-18 04:35:51.489	9010
901007	901007	ปาดังเบซาร์	Padang Besa	90240	2025-12-18 04:35:51.492	9010
901008	901008	สำนักขาม	Samnak Kham	90320	2025-12-18 04:35:51.495	9010
901009	901009	เขามีเกียรติ	Khao Mi Kiat	90170	2025-12-18 04:35:51.498	9010
901101	901101	หาดใหญ่	Hat Yai	90110	2025-12-18 04:35:51.501	9011
901102	901102	ควนลัง	Khuan Lang	90110	2025-12-18 04:35:51.504	9011
901103	901103	คูเต่า	Khu Tao	90110	2025-12-18 04:35:51.507	9011
901104	901104	คอหงส์	Kho Hong	90110	2025-12-18 04:35:51.51	9011
901105	901105	คลองแห	Khlong Hae	90110	2025-12-18 04:35:51.513	9011
901107	901107	คลองอู่ตะเภา	Khlong U Taphao	90110	2025-12-18 04:35:51.516	9011
901111	901111	ทุ่งใหญ่	Thung Yai	90110	2025-12-18 04:35:51.522	9011
901112	901112	ทุ่งตำเสา	Thung Tamsao	90110	2025-12-18 04:35:51.526	9011
901113	901113	ท่าข้าม	Tha Kham	90110	2025-12-18 04:35:51.531	9011
901114	901114	น้ำน้อย	Nam Noi	90110	2025-12-18 04:35:51.534	9011
901116	901116	บ้านพรุ	Ban Phru	90250	2025-12-18 04:35:51.537	9011
901118	901118	พะตง	Phatong	90230	2025-12-18 04:35:51.539	9011
901201	901201	นาหม่อม	Na Mom	90310	2025-12-18 04:35:51.542	9012
901202	901202	พิจิตร	Phichit	90310	2025-12-18 04:35:51.545	9012
901203	901203	ทุ่งขมิ้น	Thung Khamin	90310	2025-12-18 04:35:51.548	9012
901204	901204	คลองหรัง	Khlong Rhang	90310	2025-12-18 04:35:51.551	9012
901301	901301	รัตภูมิ	Rattaphum	90220	2025-12-18 04:35:51.553	9013
901302	901302	ควนโส	Khuan So	90220	2025-12-18 04:35:51.556	9013
901303	901303	ห้วยลึก	Huai Luek	90220	2025-12-18 04:35:51.559	9013
901304	901304	บางเหรียง	Bang Rieang	90220	2025-12-18 04:35:51.562	9013
901401	901401	บางกล่ำ	Bang Klam	90110	2025-12-18 04:35:51.564	9014
901402	901402	ท่าช้าง	Tha Chang	90110	2025-12-18 04:35:51.567	9014
901403	901403	แม่ทอม	Mae Thom	90110	2025-12-18 04:35:51.57	9014
901404	901404	บ้านหาร	Ban Han	90110	2025-12-18 04:35:51.573	9014
901501	901501	ชิงโค	Ching Kho	90280	2025-12-18 04:35:51.576	9015
901502	901502	สทิงหม้อ	Sathing Mo	90280	2025-12-18 04:35:51.579	9015
901503	901503	ทำนบ	Thamnop	90280	2025-12-18 04:35:51.581	9015
901504	901504	รำแดง	Ram Daeng	90330	2025-12-18 04:35:51.584	9015
901505	901505	วัดขนุน	Wat Khanun	90330	2025-12-18 04:35:51.587	9015
901506	901506	ชะแล้	Chalae	90330	2025-12-18 04:35:51.589	9015
901507	901507	ปากรอ	Pak Ro	90330	2025-12-18 04:35:51.592	9015
901508	901508	ป่าขาด	Pa Khat	90330	2025-12-18 04:35:51.595	9015
500906	500906	สันทราย	San Sai	50110	2025-12-18 04:35:47.045	5009
901509	901509	หัวเขา	Hua Khao	90280	2025-12-18 04:35:51.597	9015
901510	901510	บางเขียด	Bang Khiat	90330	2025-12-18 04:35:51.6	9015
901511	901511	ม่วงงาม	Muang Ngam	90330	2025-12-18 04:35:51.602	9015
901601	901601	คลองหอยโข่ง	Khlong Hoi Khong	90230	2025-12-18 04:35:51.605	9016
901602	901602	ทุ่งลาน	Thung Lan	90230	2025-12-18 04:35:51.607	9016
901603	901603	โคกม่วง	Khok Muang	90230	2025-12-18 04:35:51.61	9016
901604	901604	คลองหลา	Khlong La	90115	2025-12-18 04:35:51.613	9016
910101	910101	พิมาน	Phiman	91000	2025-12-18 04:35:51.616	9101
910102	910102	คลองขุด	Khlong Khut	91000	2025-12-18 04:35:51.619	9101
910103	910103	ควนขัน	Khuan Khan	91000	2025-12-18 04:35:51.621	9101
910104	910104	บ้านควน	Ban Khuan	91140	2025-12-18 04:35:51.624	9101
910105	910105	ฉลุง	Chalung	91140	2025-12-18 04:35:51.627	9101
910106	910106	เกาะสาหร่าย	Ko Sarai	91000	2025-12-18 04:35:51.63	9101
910107	910107	ตันหยงโป	Tanyong Po	91000	2025-12-18 04:35:51.632	9101
910108	910108	เจ๊ะบิลัง	Che Bilang	91000	2025-12-18 04:35:51.635	9101
910109	910109	ตำมะลัง	Tam Malang	91000	2025-12-18 04:35:51.637	9101
910110	910110	ปูยู	Puyu	91000	2025-12-18 04:35:51.64	9101
910111	910111	ควนโพธิ์	Khuan Pho	91140	2025-12-18 04:35:51.643	9101
910112	910112	เกตรี	Ketri	91140	2025-12-18 04:35:51.646	9101
910201	910201	ควนโดน	Khuan Don	91160	2025-12-18 04:35:51.648	9102
910202	910202	ควนสตอ	Khuan Sato	91160	2025-12-18 04:35:51.651	9102
910203	910203	ย่านซื่อ	Yan Sue	91160	2025-12-18 04:35:51.653	9102
910204	910204	วังประจัน	Wang Prachan	91160	2025-12-18 04:35:51.656	9102
910301	910301	ทุ่งนุ้ย	Thung Nui	91130	2025-12-18 04:35:51.659	9103
910302	910302	ควนกาหลง	Khuan Kalong	91130	2025-12-18 04:35:51.662	9103
910303	910303	อุใดเจริญ	Udai Charoen	91130	2025-12-18 04:35:51.665	9103
910401	910401	ท่าแพ	Tha Phae	91150	2025-12-18 04:35:51.667	9104
910403	910403	สาคร	Sakhon	91150	2025-12-18 04:35:51.672	9104
910404	910404	ท่าเรือ	Tha Rua	91150	2025-12-18 04:35:51.675	9104
910501	910501	กำแพง	Kamphaeng	91110	2025-12-18 04:35:51.678	9105
910502	910502	ละงู	La-ngu	91110	2025-12-18 04:35:51.68	9105
910503	910503	เขาขาว	Khao Khao	91110	2025-12-18 04:35:51.683	9105
910504	910504	ปากน้ำ	Pak Nam	91110	2025-12-18 04:35:51.686	9105
910505	910505	น้ำผุด	Nam Phut	91110	2025-12-18 04:35:51.687	9105
910506	910506	แหลมสน	Laem Son	91110	2025-12-18 04:35:51.689	9105
910601	910601	ทุ่งหว้า	Thung Wa	91120	2025-12-18 04:35:51.691	9106
910602	910602	นาทอน	Na Thon	91120	2025-12-18 04:35:51.693	9106
910603	910603	ขอนคลาน	Khon Khlan	91120	2025-12-18 04:35:51.695	9106
910604	910604	ทุ่งบุหลัง	Thung Bulang	91120	2025-12-18 04:35:51.697	9106
910605	910605	ป่าแก่บ่อหิน	Pa Kae Bo Hin	91120	2025-12-18 04:35:51.699	9106
910701	910701	ปาล์มพัฒนา	Palm Phatthana	91130	2025-12-18 04:35:51.701	9107
910702	910702	นิคมพัฒนา	Nikhom Phatthana	91130	2025-12-18 04:35:51.704	9107
920101	920101	ทับเที่ยง	Thap Thiang	92000	2025-12-18 04:35:51.706	9201
920104	920104	นาพละ	Na Phala	92000	2025-12-18 04:35:51.708	9201
920105	920105	บ้านควน	Ban Khuan	92000	2025-12-18 04:35:51.71	9201
920106	920106	นาบินหลา	Na Bin La	92000	2025-12-18 04:35:51.712	9201
920107	920107	ควนปริง	Khuan Pring	92000	2025-12-18 04:35:51.714	9201
920108	920108	นาโยงใต้	Na Yong Tai	92170	2025-12-18 04:35:51.716	9201
920109	920109	บางรัก	Bang Rak	92000	2025-12-18 04:35:51.718	9201
920110	920110	โคกหล่อ	Khok Lo	92000	2025-12-18 04:35:51.719	9201
920113	920113	นาโต๊ะหมิง	Na To Ming	92000	2025-12-18 04:35:51.721	9201
920114	920114	หนองตรุด	Nong Trut	92000	2025-12-18 04:35:51.722	9201
920115	920115	น้ำผุด	Nam Phut	92000	2025-12-18 04:35:51.727	9201
920117	920117	นาตาล่วง	Na Ta Luang	92000	2025-12-18 04:35:51.729	9201
920118	920118	บ้านโพธิ์	Ban Pho	92000	2025-12-18 04:35:51.732	9201
920119	920119	นาท่ามเหนือ	Na Tham Nuea	92190	2025-12-18 04:35:51.734	9201
920120	920120	นาท่ามใต้	Na Tham Tai	92190	2025-12-18 04:35:51.736	9201
920201	920201	กันตัง	Kantang	92110	2025-12-18 04:35:51.737	9202
920202	920202	ควนธานี	Khuan Thani	92110	2025-12-18 04:35:51.738	9202
920203	920203	บางหมาก	Bang Mak	92110	2025-12-18 04:35:51.739	9202
920204	920204	บางเป้า	Bang Pao	92110	2025-12-18 04:35:51.741	9202
920205	920205	วังวน	Wang Won	92110	2025-12-18 04:35:51.743	9202
920206	920206	กันตังใต้	Kantang Tai	92110	2025-12-18 04:35:51.744	9202
920207	920207	โคกยาง	Khok Yang	92110	2025-12-18 04:35:51.746	9202
920208	920208	คลองลุ	Khlong Lu	92110	2025-12-18 04:35:51.747	9202
920209	920209	ย่านซื่อ	Yan Sue	92110	2025-12-18 04:35:51.748	9202
920210	920210	บ่อน้ำร้อน	Bo Nam Ron	92110	2025-12-18 04:35:51.749	9202
920211	920211	บางสัก	Bang Sak	92110	2025-12-18 04:35:51.751	9202
920212	920212	นาเกลือ	Na Kluea	92110	2025-12-18 04:35:51.753	9202
920213	920213	เกาะลิบง	Ko Libong	92110	2025-12-18 04:35:51.755	9202
920214	920214	คลองชีล้อม	Khlong Chi Lom	92110	2025-12-18 04:35:51.756	9202
920301	920301	ย่านตาขาว	Yan Ta Khao	92140	2025-12-18 04:35:51.758	9203
920302	920302	หนองบ่อ	Nong Bo	92140	2025-12-18 04:35:51.759	9203
920303	920303	นาชุมเห็ด	Na Chum Het	92140	2025-12-18 04:35:51.761	9203
920304	920304	ในควน	Nai Khuan	92140	2025-12-18 04:35:51.763	9203
920305	920305	โพรงจระเข้	Phrong Chorakhe	92140	2025-12-18 04:35:51.764	9203
920306	920306	ทุ่งกระบือ	Thung Krabue	92140	2025-12-18 04:35:51.766	9203
920307	920307	ทุ่งค่าย	Thung Khai	92140	2025-12-18 04:35:51.767	9203
920308	920308	เกาะเปียะ	Ko Pia	92140	2025-12-18 04:35:51.769	9203
920401	920401	ท่าข้าม	Tha Kham	92120	2025-12-18 04:35:51.77	9204
120603	120603	บ้านใหม่	Ban Mai	11120	2025-12-18 04:35:38.904	1206
920402	920402	ทุ่งยาว	Thung Yao	92180	2025-12-18 04:35:51.772	9204
920403	920403	ปะเหลียน	Palian	92180	2025-12-18 04:35:51.774	9204
920404	920404	บางด้วน	Bang Duan	92140	2025-12-18 04:35:51.776	9204
920407	920407	บ้านนา	Ban Na	92140	2025-12-18 04:35:51.777	9204
920409	920409	สุโสะ	Suso	92120	2025-12-18 04:35:51.779	9204
920410	920410	ลิพัง	Liphang	92180	2025-12-18 04:35:51.782	9204
920411	920411	เกาะสุกร	Ko Sukon	92120	2025-12-18 04:35:51.784	9204
920412	920412	ท่าพญา	Tha Phaya	92140	2025-12-18 04:35:51.786	9204
920413	920413	แหลมสอม	Laem Som	92180	2025-12-18 04:35:51.788	9204
920501	920501	บ่อหิน	Bo Hin	92150	2025-12-18 04:35:51.789	9205
920502	920502	เขาไม้แก้ว	Khao Mai Kaeo	92150	2025-12-18 04:35:51.791	9205
920503	920503	กะลาเส	Kalase	92150	2025-12-18 04:35:51.793	9205
920504	920504	ไม้ฝาด	Mai Fat	92150	2025-12-18 04:35:51.795	9205
920505	920505	นาเมืองเพชร	Na Mueang Phet	92000	2025-12-18 04:35:51.797	9205
920601	920601	ห้วยยอด	Huai Yot	92130	2025-12-18 04:35:51.799	9206
920602	920602	หนองช้างแล่น	Nong Chang Laen	92130	2025-12-18 04:35:51.8	9206
920605	920605	บางดี	Bang Di	92210	2025-12-18 04:35:51.802	9206
920606	920606	บางกุ้ง	Bang Kung	92210	2025-12-18 04:35:51.803	9206
920607	920607	เขากอบ	Khao Kop	92130	2025-12-18 04:35:51.804	9206
920608	920608	เขาขาว	Khao Khao	92130	2025-12-18 04:35:51.806	9206
920609	920609	เขาปูน	Khao Pun	92130	2025-12-18 04:35:51.808	9206
920610	920610	ปากแจ่ม	Pak Chaem	92190	2025-12-18 04:35:51.81	9206
920611	920611	ปากคม	Pak Khom	92130	2025-12-18 04:35:51.812	9206
920614	920614	ท่างิ้ว	Tha Ngio	92130	2025-12-18 04:35:51.814	9206
920615	920615	ลำภูรา	Lamphu Ra	92190	2025-12-18 04:35:51.815	9206
920616	920616	นาวง	Na Wong	92210	2025-12-18 04:35:51.816	9206
920617	920617	ห้วยนาง	Huai Nang	92130	2025-12-18 04:35:51.818	9206
920619	920619	ในเตา	Nai Tao	92130	2025-12-18 04:35:51.82	9206
920620	920620	ทุ่งต่อ	Thung To	92130	2025-12-18 04:35:51.822	9206
920621	920621	วังคีรี	Wang Khiri	92210	2025-12-18 04:35:51.824	9206
920701	920701	เขาวิเศษ	Khao Wiset	92220	2025-12-18 04:35:51.825	9207
920702	920702	วังมะปราง	Wang Maprang	92220	2025-12-18 04:35:51.827	9207
920703	920703	อ่าวตง	Ao Tong	92220	2025-12-18 04:35:51.829	9207
920704	920704	ท่าสะบ้า	Tha Saba	92000	2025-12-18 04:35:51.831	9207
920705	920705	วังมะปรางเหนือ	Wang Maprang Nuea	92220	2025-12-18 04:35:51.832	9207
920801	920801	นาโยงเหนือ	Na Yong Nuea	92170	2025-12-18 04:35:51.833	9208
920802	920802	ช่อง	Chong	92170	2025-12-18 04:35:51.834	9208
920803	920803	ละมอ	Lamo	92170	2025-12-18 04:35:51.837	9208
920804	920804	โคกสะบ้า	Khok Saba	92170	2025-12-18 04:35:51.84	9208
920805	920805	นาหมื่นศรี	Na Muen Si	92170	2025-12-18 04:35:51.843	9208
920806	920806	นาข้าวเสีย	Na Khao Sia	92170	2025-12-18 04:35:51.846	9208
920901	920901	ควนเมา	Khuan Mao	92160	2025-12-18 04:35:51.848	9209
920902	920902	คลองปาง	Khlong Pang	92160	2025-12-18 04:35:51.85	9209
920903	920903	หนองบัว	Nong Bua	92160	2025-12-18 04:35:51.852	9209
920904	920904	หนองปรือ	Nong Prue	92130	2025-12-18 04:35:51.854	9209
920905	920905	เขาไพร	Khao Phrai	92160	2025-12-18 04:35:51.859	9209
921001	921001	หาดสำราญ	Hat Samran	92120	2025-12-18 04:35:51.862	9210
921002	921002	บ้าหวี	Ba Wi	92120	2025-12-18 04:35:51.865	9210
921003	921003	ตะเสะ	Ta Se	92120	2025-12-18 04:35:51.869	9210
930101	930101	คูหาสวรรค์	Khuha Sawan	93000	2025-12-18 04:35:51.873	9301
930103	930103	เขาเจียก	Khao Chiak	93000	2025-12-18 04:35:51.877	9301
930104	930104	ท่ามิหรำ	Tha Miram	93000	2025-12-18 04:35:51.88	9301
930105	930105	โคกชะงาย	Khok Cha-ngai	93000	2025-12-18 04:35:51.883	9301
930106	930106	นาท่อม	Na Thom	93000	2025-12-18 04:35:51.885	9301
930107	930107	ปรางหมู่	Prang Mu	93000	2025-12-18 04:35:51.887	9301
930108	930108	ท่าแค	Tha Khae	93000	2025-12-18 04:35:51.89	9301
930109	930109	ลำปำ	Lampam	93000	2025-12-18 04:35:51.893	9301
930110	930110	ตำนาน	Tamnan	93000	2025-12-18 04:35:51.895	9301
930111	930111	ควนมะพร้าว	Khuan Maphrao	93000	2025-12-18 04:35:51.898	9301
930112	930112	ร่มเมือง	Rom Mueang	93000	2025-12-18 04:35:51.9	9301
930113	930113	ชัยบุรี	Chai Buri	93000	2025-12-18 04:35:51.902	9301
930114	930114	นาโหนด	Na Not	93000	2025-12-18 04:35:51.904	9301
930115	930115	พญาขัน	Phaya Khan	93000	2025-12-18 04:35:51.906	9301
930201	930201	กงหรา	Kong Ra	93180	2025-12-18 04:35:51.908	9302
930202	930202	ชะรัด	Charat	93000	2025-12-18 04:35:51.91	9302
930203	930203	คลองเฉลิม	Khlong Chaloem	93180	2025-12-18 04:35:51.912	9302
930204	930204	คลองทรายขาว	Khlong Sai Khao	93180	2025-12-18 04:35:51.913	9302
930205	930205	สมหวัง	Som Wang	93000	2025-12-18 04:35:51.915	9302
930301	930301	เขาชัยสน	Khao Chaison	93130	2025-12-18 04:35:51.916	9303
930302	930302	ควนขนุน	Khuan Khanun	93130	2025-12-18 04:35:51.918	9303
930305	930305	จองถนน	Chong Thanon	93130	2025-12-18 04:35:51.919	9303
930306	930306	หานโพธิ์	Han Pho	93130	2025-12-18 04:35:51.921	9303
930307	930307	โคกม่วง	Khok Muang	93130	2025-12-18 04:35:51.923	9303
930401	930401	แม่ขรี	Mae Khari	93160	2025-12-18 04:35:51.925	9304
930402	930402	ตะโหมด	Tamod	93160	2025-12-18 04:35:51.927	9304
930403	930403	คลองใหญ่	Khlong Yai	93160	2025-12-18 04:35:51.929	9304
930501	930501	ควนขนุน	Khuan Khanun	93110	2025-12-18 04:35:51.931	9305
930502	930502	ทะเลน้อย	Thale Noi	93150	2025-12-18 04:35:51.933	9305
930504	930504	นาขยาด	Na Khayat	93110	2025-12-18 04:35:51.935	9305
930505	930505	พนมวังก์	Phanom Wang	93110	2025-12-18 04:35:51.938	9305
930506	930506	แหลมโตนด	Laem Tanot	93110	2025-12-18 04:35:51.94	9305
930508	930508	ปันแต	Pan Tae	93110	2025-12-18 04:35:51.942	9305
930509	930509	โตนดด้วน	Tanot Duan	93110	2025-12-18 04:35:51.944	9305
930510	930510	ดอนทราย	Don Sai	93110	2025-12-18 04:35:51.946	9305
930511	930511	มะกอกเหนือ	Makok Nuea	93150	2025-12-18 04:35:51.948	9305
930512	930512	พนางตุง	Phanang Tung	93150	2025-12-18 04:35:51.949	9305
930513	930513	ชะมวง	Chamuang	93110	2025-12-18 04:35:51.952	9305
930516	930516	แพรกหา	Phraek Ha	93110	2025-12-18 04:35:51.954	9305
930601	930601	ปากพะยูน	Pak Phayun	93120	2025-12-18 04:35:51.956	9306
930602	930602	ดอนประดู่	Don Pradu	93120	2025-12-18 04:35:51.958	9306
930603	930603	เกาะนางคำ	Ko Nang Kham	93120	2025-12-18 04:35:51.96	9306
930604	930604	เกาะหมาก	Ko Mak	93120	2025-12-18 04:35:51.962	9306
930605	930605	ฝาละมี	Falami	93120	2025-12-18 04:35:51.964	9306
930606	930606	หารเทา	Han Thao	93120	2025-12-18 04:35:51.966	9306
930607	930607	ดอนทราย	Don Sai	93120	2025-12-18 04:35:51.968	9306
930701	930701	เขาย่า	Khao Ya	93190	2025-12-18 04:35:51.971	9307
930702	930702	เขาปู่	Khao Pu	93190	2025-12-18 04:35:51.973	9307
930703	930703	ตะแพน	Taphaen	93190	2025-12-18 04:35:51.975	9307
930801	930801	ป่าบอน	Pa Bon	93170	2025-12-18 04:35:51.977	9308
930802	930802	โคกทราย	Khok Sai	93170	2025-12-18 04:35:51.98	9308
930803	930803	หนองธง	Nong Thong	93170	2025-12-18 04:35:51.982	9308
930804	930804	ทุ่งนารี	Thung Nari	93170	2025-12-18 04:35:51.984	9308
930806	930806	วังใหม่	Wang Mai	93170	2025-12-18 04:35:51.986	9308
930901	930901	ท่ามะเดื่อ	Tha Maduea	93140	2025-12-18 04:35:51.988	9309
930902	930902	นาปะขอ	Na Pakho	93140	2025-12-18 04:35:51.99	9309
930903	930903	โคกสัก	Khok Sak	93140	2025-12-18 04:35:51.992	9309
931001	931001	ป่าพะยอม	Pa Phayom	93110	2025-12-18 04:35:51.995	9310
931002	931002	ลานข่อย	Lan Khoi	93110	2025-12-18 04:35:51.997	9310
931003	931003	เกาะเต่า	Ko Tao	93110	2025-12-18 04:35:52	9310
931004	931004	บ้านพร้าว	Ban Phrao	93110	2025-12-18 04:35:52.002	9310
931101	931101	ชุมพล	Chumphon	93000	2025-12-18 04:35:52.004	9311
931102	931102	บ้านนา	Ban Na	93000	2025-12-18 04:35:52.006	9311
931103	931103	อ่างทอง	Ang Thong	93000	2025-12-18 04:35:52.008	9311
931104	931104	ลำสินธุ์	Lam Sin	93000	2025-12-18 04:35:52.01	9311
940101	940101	สะบารัง	Sabarang	94000	2025-12-18 04:35:52.011	9401
940102	940102	อาเนาะรู	Ano Ru	94000	2025-12-18 04:35:52.013	9401
940103	940103	จะบังติกอ	Chabang Tiko	94000	2025-12-18 04:35:52.015	9401
940104	940104	บานา	Bana	94000	2025-12-18 04:35:52.017	9401
940105	940105	ตันหยงลุโละ	Tanyong Lulo	94000	2025-12-18 04:35:52.019	9401
940106	940106	คลองมานิง	Khlong Maning	94000	2025-12-18 04:35:52.021	9401
940107	940107	กะมิยอ	Kamiyo	94000	2025-12-18 04:35:52.023	9401
940108	940108	บาราโหม	Barahom	94000	2025-12-18 04:35:52.025	9401
940109	940109	ปะกาฮะรัง	Paka Harang	94000	2025-12-18 04:35:52.027	9401
940110	940110	รูสะมิแล	Ru Samilae	94000	2025-12-18 04:35:52.029	9401
940111	940111	ตะลุโบะ	Talubo	94000	2025-12-18 04:35:52.031	9401
940112	940112	บาราเฮาะ	Baraho	94000	2025-12-18 04:35:52.034	9401
940113	940113	ปุยุด	Puyut	94000	2025-12-18 04:35:52.036	9401
940201	940201	โคกโพธิ์	Khok Pho	94120	2025-12-18 04:35:52.038	9402
940202	940202	มะกรูด	Makrut	94120	2025-12-18 04:35:52.04	9402
940203	940203	บางโกระ	Bang Kro	94120	2025-12-18 04:35:52.043	9402
940204	940204	ป่าบอน	Pa Bon	94120	2025-12-18 04:35:52.045	9402
940205	940205	ทรายขาว	Sai Khao	94120	2025-12-18 04:35:52.047	9402
940206	940206	นาประดู่	Na Pradu	94180	2025-12-18 04:35:52.049	9402
940207	940207	ปากล่อ	Pak Lo	94180	2025-12-18 04:35:52.051	9402
940208	940208	ทุ่งพลา	Thung Phala	94180	2025-12-18 04:35:52.053	9402
940211	940211	ท่าเรือ	Tha Ruea	94120	2025-12-18 04:35:52.056	9402
940213	940213	นาเกตุ	Na Ket	94120	2025-12-18 04:35:52.058	9402
940214	940214	ควนโนรี	Khuan Nori	94180	2025-12-18 04:35:52.06	9402
940215	940215	ช้างให้ตก	Chang Hai Tok	94120	2025-12-18 04:35:52.062	9402
940301	940301	เกาะเปาะ	Ko Po	94170	2025-12-18 04:35:52.064	9403
940302	940302	คอลอตันหยง	Kholo Tanyong	94170	2025-12-18 04:35:52.067	9403
940303	940303	ดอนรัก	Don Rak	94170	2025-12-18 04:35:52.069	9403
940304	940304	ดาโต๊ะ	Dato	94170	2025-12-18 04:35:52.071	9403
940306	940306	ท่ากำชำ	Tha Kamcham	94170	2025-12-18 04:35:52.075	9403
940307	940307	บ่อทอง	Bo Thong	94170	2025-12-18 04:35:52.078	9403
940308	940308	บางเขา	Bang Khao	94170	2025-12-18 04:35:52.08	9403
940309	940309	บางตาวา	Bang Tawa	94170	2025-12-18 04:35:52.082	9403
940310	940310	ปุโละปุโย	Pulo Puyo	94170	2025-12-18 04:35:52.084	9403
940311	940311	ยาบี	Yabi	94170	2025-12-18 04:35:52.088	9403
940312	940312	ลิปะสะโง	Lipa Sa-ngo	94170	2025-12-18 04:35:52.09	9403
940401	940401	ปะนาเระ	Panare	94130	2025-12-18 04:35:52.092	9404
940402	940402	ท่าข้าม	Tha Kham	94130	2025-12-18 04:35:52.095	9404
940403	940403	บ้านนอก	Ban Nok	94130	2025-12-18 04:35:52.097	9404
940404	940404	ดอน	Don	94130	2025-12-18 04:35:52.099	9404
940405	940405	ควน	Khuan	94190	2025-12-18 04:35:52.101	9404
940406	940406	ท่าน้ำ	Tha Nam	94130	2025-12-18 04:35:52.104	9404
940407	940407	คอกกระบือ	Khok Krabue	94130	2025-12-18 04:35:52.106	9404
940408	940408	พ่อมิ่ง	Pho Ming	94130	2025-12-18 04:35:52.108	9404
940409	940409	บ้านกลาง	Ban Klang	94130	2025-12-18 04:35:52.11	9404
940410	940410	บ้านน้ำบ่อ	Ban Nam Bo	94130	2025-12-18 04:35:52.113	9404
940501	940501	มายอ	Mayo	94140	2025-12-18 04:35:52.114	9405
940502	940502	ถนน	Thanon	94140	2025-12-18 04:35:52.116	9405
940503	940503	ตรัง	Trang	94140	2025-12-18 04:35:52.118	9405
940504	940504	กระหวะ	Krawa	94140	2025-12-18 04:35:52.12	9405
940505	940505	ลุโบะยิไร	Lubo Yirai	94140	2025-12-18 04:35:52.122	9405
940506	940506	ลางา	La-nga	94190	2025-12-18 04:35:52.124	9405
940507	940507	กระเสาะ	Kra So	94140	2025-12-18 04:35:52.126	9405
940508	940508	เกาะจัน	Ko Chan	94140	2025-12-18 04:35:52.128	9405
940509	940509	ปะโด	Pado	94140	2025-12-18 04:35:52.13	9405
940510	940510	สาคอบน	Sakho Bon	94140	2025-12-18 04:35:52.133	9405
940511	940511	สาคอใต้	Sakho Tai	94140	2025-12-18 04:35:52.135	9405
940512	940512	สะกำ	Sakam	94140	2025-12-18 04:35:52.137	9405
940513	940513	ปานัน	Panan	94140	2025-12-18 04:35:52.14	9405
940601	940601	ตะโละแมะนา	Talo Mae Na	94140	2025-12-18 04:35:52.142	9406
940602	940602	พิเทน	Phithen	94140	2025-12-18 04:35:52.144	9406
940603	940603	น้ำดำ	Nam Dam	94140	2025-12-18 04:35:52.147	9406
940604	940604	ปากู	Paku	94140	2025-12-18 04:35:52.149	9406
940701	940701	ตะลุบัน	Taluban	94110	2025-12-18 04:35:52.152	9407
940702	940702	ตะบิ้ง	Tabing	94110	2025-12-18 04:35:52.154	9407
940703	940703	ปะเสยะวอ	Pase Yawo	94110	2025-12-18 04:35:52.158	9407
940704	940704	บางเก่า	Bang Kao	94110	2025-12-18 04:35:52.16	9407
940705	940705	บือเระ	Bue Re	94110	2025-12-18 04:35:52.162	9407
940706	940706	เตราะบอน	Tro Bon	94110	2025-12-18 04:35:52.165	9407
940707	940707	กะดุนง	Kadunong	94110	2025-12-18 04:35:52.167	9407
940708	940708	ละหาร	Lahan	94110	2025-12-18 04:35:52.17	9407
940709	940709	มะนังดาลำ	Manang Dalam	94110	2025-12-18 04:35:52.172	9407
940710	940710	แป้น	Paen	94110	2025-12-18 04:35:52.174	9407
940711	940711	ทุ่งคล้า	Thung Khla	94190	2025-12-18 04:35:52.177	9407
940801	940801	ไทรทอง	Sai Thong	94220	2025-12-18 04:35:52.179	9408
940802	940802	ไม้แก่น	Mai Kaen	94220	2025-12-18 04:35:52.181	9408
940803	940803	ตะโละไกรทอง	Talo Krai Thong	94220	2025-12-18 04:35:52.184	9408
940804	940804	ดอนทราย	Don Sai	94220	2025-12-18 04:35:52.186	9408
940901	940901	ตะโละ	Talo	94150	2025-12-18 04:35:52.188	9409
940902	940902	ตะโละกาโปร์	Talo Kapo	94150	2025-12-18 04:35:52.191	9409
940903	940903	ตันหยงดาลอ	Tanyong Dalo	94150	2025-12-18 04:35:52.193	9409
940904	940904	ตันหยงจึงงา	Tanyong Chueng-nga	94190	2025-12-18 04:35:52.195	9409
940905	940905	ตอหลัง	Tolang	94150	2025-12-18 04:35:52.198	9409
940906	940906	ตาแกะ	Ta Kae	94150	2025-12-18 04:35:52.2	9409
940907	940907	ตาลีอายร์	Tali-ai	94150	2025-12-18 04:35:52.202	9409
940908	940908	ยามู	Yamu	94150	2025-12-18 04:35:52.205	9409
940909	940909	บางปู	Bang Pu	94150	2025-12-18 04:35:52.207	9409
940910	940910	หนองแรต	Nong Raet	94150	2025-12-18 04:35:52.21	9409
940911	940911	ปิยามุมัง	Piya Mumang	94150	2025-12-18 04:35:52.212	9409
940912	940912	ปุลากง	Pula Kong	94150	2025-12-18 04:35:52.214	9409
940913	940913	บาโลย	Baloi	94190	2025-12-18 04:35:52.217	9409
940914	940914	สาบัน	Saban	94150	2025-12-18 04:35:52.219	9409
940915	940915	มะนังยง	Manang Yong	94150	2025-12-18 04:35:52.222	9409
940916	940916	ราตาปันยัง	Rata Panyang	94150	2025-12-18 04:35:52.224	9409
940917	940917	จะรัง	Charang	94150	2025-12-18 04:35:52.228	9409
940918	940918	แหลมโพธิ์	Laem Pho	94150	2025-12-18 04:35:52.23	9409
941001	941001	ยะรัง	Yarang	94160	2025-12-18 04:35:52.233	9410
941002	941002	สะดาวา	Sadawa	94160	2025-12-18 04:35:52.235	9410
941003	941003	ประจัน	Prachan	94160	2025-12-18 04:35:52.238	9410
941004	941004	สะนอ	Sano	94160	2025-12-18 04:35:52.24	9410
941005	941005	ระแว้ง	Rawaeng	94160	2025-12-18 04:35:52.243	9410
941006	941006	ปิตูมุดี	Pitu Mudi	94160	2025-12-18 04:35:52.245	9410
941007	941007	วัด	Wat	94160	2025-12-18 04:35:52.248	9410
941008	941008	กระโด	Krado	94160	2025-12-18 04:35:52.25	9410
941009	941009	คลองใหม่	Khlong Mai	94160	2025-12-18 04:35:52.253	9410
941010	941010	เมาะมาวี	Mo Mawi	94160	2025-12-18 04:35:52.256	9410
941011	941011	กอลำ	Kolam	94160	2025-12-18 04:35:52.258	9410
941012	941012	เขาตูม	Khao Tum	94160	2025-12-18 04:35:52.261	9410
941101	941101	กะรุบี	Karubi	94230	2025-12-18 04:35:52.263	9411
941102	941102	ตะโละดือรามัน	Talo Due Raman	94230	2025-12-18 04:35:52.266	9411
941103	941103	ปล่องหอย	Plong Hoi	94230	2025-12-18 04:35:52.269	9411
941201	941201	แม่ลาน	Mae Lan	94180	2025-12-18 04:35:52.271	9412
941202	941202	ม่วงเตี้ย	Muang Tia	94180	2025-12-18 04:35:52.273	9412
941203	941203	ป่าไร่	Pa Rai	94180	2025-12-18 04:35:52.276	9412
950101	950101	สะเตง	Sateng	95000	2025-12-18 04:35:52.279	9501
950102	950102	บุดี	Budi	95000	2025-12-18 04:35:52.281	9501
950103	950103	ยุโป	Yopo	95000	2025-12-18 04:35:52.284	9501
950104	950104	ลิดล	Lidon	95160	2025-12-18 04:35:52.287	9501
950106	950106	ยะลา	Yala	95000	2025-12-18 04:35:52.29	9501
950108	950108	ท่าสาป	Tha Sap	95000	2025-12-18 04:35:52.293	9501
950109	950109	ลำใหม่	Lam Mai	95160	2025-12-18 04:35:52.296	9501
950110	950110	หน้าถ้ำ	Na Tham	95000	2025-12-18 04:35:52.298	9501
950111	950111	ลำพะยา	Lam Phaya	95160	2025-12-18 04:35:52.301	9501
950112	950112	เปาะเส้ง	Po Seng	95000	2025-12-18 04:35:52.304	9501
950114	950114	พร่อน	Phron	95160	2025-12-18 04:35:52.307	9501
950115	950115	บันนังสาเรง	Bannang Sareng	95000	2025-12-18 04:35:52.31	9501
950116	950116	สะเตงนอก	Sateng Nok	95000	2025-12-18 04:35:52.313	9501
950118	950118	ตาเซะ	Ta Se	95000	2025-12-18 04:35:52.315	9501
950201	950201	เบตง	Betong	95110	2025-12-18 04:35:52.318	9502
950202	950202	ยะรม	Yarom	95110	2025-12-18 04:35:52.321	9502
950203	950203	ตาเนาะแมเราะ	Tano Maero	95110	2025-12-18 04:35:52.323	9502
950204	950204	อัยเยอร์เวง	Aiyoe Weng	95110	2025-12-18 04:35:52.326	9502
950205	950205	ธารน้ำทิพย์	Than Nam Thip	95110	2025-12-18 04:35:52.328	9502
950301	950301	บันนังสตา	Bannang Sata	95130	2025-12-18 04:35:52.331	9503
950302	950302	บาเจาะ	Bacho	95130	2025-12-18 04:35:52.334	9503
950303	950303	ตาเนาะปูเต๊ะ	Tano Pute	95130	2025-12-18 04:35:52.337	9503
950304	950304	ถ้ำทะลุ	Tham Thalu	95130	2025-12-18 04:35:52.341	9503
950305	950305	ตลิ่งชัน	Taling Chan	95130	2025-12-18 04:35:52.344	9503
520505	520505	ปงเตา	Pong Tao	52110	2025-12-18 04:35:47.355	5205
950306	950306	เขื่อนบางลาง	Khuean Bang Lang	95130	2025-12-18 04:35:52.347	9503
950401	950401	ธารโต	Than To	95150	2025-12-18 04:35:52.349	9504
950402	950402	บ้านแหร	Ban Rae	95150	2025-12-18 04:35:52.352	9504
950403	950403	แม่หวาด	Mae Wat	95170	2025-12-18 04:35:52.355	9504
950404	950404	คีรีเขต	Khiri Khet	95150	2025-12-18 04:35:52.358	9504
950501	950501	ยะหา	Yaha	95120	2025-12-18 04:35:52.361	9505
950502	950502	ละแอ	La-ae	95120	2025-12-18 04:35:52.364	9505
950503	950503	ปะแต	Patae	95120	2025-12-18 04:35:52.366	9505
950504	950504	บาโร๊ะ	Baro	95120	2025-12-18 04:35:52.369	9505
950506	950506	ตาชี	Ta Chi	95120	2025-12-18 04:35:52.372	9505
950507	950507	บาโงยซิแน	Ba-ngoi Sinae	95120	2025-12-18 04:35:52.375	9505
950508	950508	กาตอง	Ka Tong	95120	2025-12-18 04:35:52.378	9505
950601	950601	กายูบอเกาะ	Kayu Boko	95140	2025-12-18 04:35:52.381	9506
950602	950602	กาลูปัง	Kalupang	95140	2025-12-18 04:35:52.384	9506
950604	950604	กอตอตือร๊ะ	Koto Tuera	95140	2025-12-18 04:35:52.389	9506
950605	950605	โกตาบารู	Kota Baru	95140	2025-12-18 04:35:52.392	9506
950606	950606	เกะรอ	Kero	95140	2025-12-18 04:35:52.395	9506
950607	950607	จะกว๊ะ	Cha-kwa	95140	2025-12-18 04:35:52.398	9506
950608	950608	ท่าธง	Tha Thong	95140	2025-12-18 04:35:52.401	9506
950609	950609	เนินงาม	Noen Ngam	95140	2025-12-18 04:35:52.404	9506
950610	950610	บาลอ	Balo	95140	2025-12-18 04:35:52.407	9506
950611	950611	บาโงย	Ba-ngoi	95140	2025-12-18 04:35:52.41	9506
950612	950612	บือมัง	Buemang	95140	2025-12-18 04:35:52.412	9506
950613	950613	ยะต๊ะ	Yata	95140	2025-12-18 04:35:52.414	9506
950614	950614	วังพญา	Wang Phaya	95140	2025-12-18 04:35:52.417	9506
950615	950615	อาซ่อง	Asong	95140	2025-12-18 04:35:52.419	9506
950616	950616	ตะโล๊ะหะลอ	Talo Halo	95140	2025-12-18 04:35:52.422	9506
950701	950701	กาบัง	Kabang	95120	2025-12-18 04:35:52.424	9507
950702	950702	บาละ	Bala	95120	2025-12-18 04:35:52.427	9507
950801	950801	กรงปินัง	Krong Pinang	95000	2025-12-18 04:35:52.43	9508
950802	950802	สะเอะ	Sa-e	95000	2025-12-18 04:35:52.433	9508
950803	950803	ห้วยกระทิง	Huai Krathing	95000	2025-12-18 04:35:52.436	9508
950804	950804	ปุโรง	Purong	95000	2025-12-18 04:35:52.439	9508
960101	960101	บางนาค	Bang Nak	96000	2025-12-18 04:35:52.442	9601
960102	960102	ลำภู	Lam Phu	96000	2025-12-18 04:35:52.445	9601
960103	960103	มะนังตายอ	Manang Tayo	96000	2025-12-18 04:35:52.448	9601
960104	960104	บางปอ	Bang Po	96000	2025-12-18 04:35:52.451	9601
960105	960105	กะลุวอ	Kaluwo	96000	2025-12-18 04:35:52.454	9601
960106	960106	กะลุวอเหนือ	Kaluwo Nuea	96000	2025-12-18 04:35:52.456	9601
960107	960107	โคกเคียน	Khok Khian	96000	2025-12-18 04:35:52.461	9601
960201	960201	เจ๊ะเห	Chehe	96110	2025-12-18 04:35:52.464	9602
960202	960202	ไพรวัน	Phrai Wan	96110	2025-12-18 04:35:52.467	9602
960203	960203	พร่อน	Phron	96110	2025-12-18 04:35:52.47	9602
960204	960204	ศาลาใหม่	Sala Mai	96110	2025-12-18 04:35:52.473	9602
960205	960205	บางขุนทอง	Bang Khun Thong	96110	2025-12-18 04:35:52.475	9602
960206	960206	เกาะสะท้อน	Ko Sathon	96110	2025-12-18 04:35:52.478	9602
960207	960207	นานาค	Na Nak	96110	2025-12-18 04:35:52.481	9602
960208	960208	โฆษิต	Khosit	96110	2025-12-18 04:35:52.485	9602
960301	960301	บาเจาะ	Bacho	96170	2025-12-18 04:35:52.487	9603
960302	960302	ลุโบะสาวอ	Lubo Sawo	96170	2025-12-18 04:35:52.491	9603
960303	960303	กาเยาะมาตี	Kayo Mati	96170	2025-12-18 04:35:52.494	9603
960304	960304	ปะลุกาสาเมาะ	Paluka Samo	96170	2025-12-18 04:35:52.496	9603
960305	960305	บาเระเหนือ	Bare Nuea	96170	2025-12-18 04:35:52.499	9603
960306	960306	บาเระใต้	Ba Re Tai	96170	2025-12-18 04:35:52.501	9603
960401	960401	ยี่งอ	Yi-ngo	96180	2025-12-18 04:35:52.504	9604
960402	960402	ละหาร	Lahan	96180	2025-12-18 04:35:52.506	9604
960403	960403	จอเบาะ	Chobo	96180	2025-12-18 04:35:52.508	9604
960404	960404	ลุโบะบายะ	Lubo Baya	96180	2025-12-18 04:35:52.51	9604
960405	960405	ลุโบะบือซา	Lubo Buesa	96180	2025-12-18 04:35:52.512	9604
960406	960406	ตะปอเยาะ	Tapoyo	96180	2025-12-18 04:35:52.514	9604
960501	960501	ตันหยงมัส	Tanyong Mat	96130	2025-12-18 04:35:52.516	9605
960502	960502	ตันหยงลิมอ	Tanyong Limo	96130	2025-12-18 04:35:52.518	9605
960506	960506	บองอ	Bo-ngo	96220	2025-12-18 04:35:52.52	9605
960507	960507	กาลิซา	Kalisa	96130	2025-12-18 04:35:52.523	9605
960508	960508	บาโงสะโต	Ba-ngo Sato	96130	2025-12-18 04:35:52.525	9605
960509	960509	เฉลิม	Chaloem	96130	2025-12-18 04:35:52.526	9605
960510	960510	มะรือโบตก	Maruebo Tok	96130	2025-12-18 04:35:52.528	9605
960601	960601	รือเสาะ	Rueso	96150	2025-12-18 04:35:52.53	9606
960602	960602	สาวอ	Sawo	96150	2025-12-18 04:35:52.532	9606
960603	960603	เรียง	Riang	96150	2025-12-18 04:35:52.533	9606
960604	960604	สามัคคี	Samakkhi	96150	2025-12-18 04:35:52.534	9606
960605	960605	บาตง	Batong	96150	2025-12-18 04:35:52.536	9606
960606	960606	ลาโละ	Lalo	96150	2025-12-18 04:35:52.537	9606
960607	960607	รือเสาะออก	Rueso Ok	96150	2025-12-18 04:35:52.539	9606
960608	960608	โคกสะตอ	Khok Sato	96150	2025-12-18 04:35:52.541	9606
960609	960609	สุวารี	Suwari	96150	2025-12-18 04:35:52.542	9606
960701	960701	ซากอ	Sako	96210	2025-12-18 04:35:52.544	9607
960702	960702	ตะมะยูง	Tamayung	96210	2025-12-18 04:35:52.545	9607
530603	530603	นาขุม	Na Khum	53180	2025-12-18 04:35:47.583	5306
120604	120604	บางพูด	Bang Phut	11120	2025-12-18 04:35:38.905	1206
550706	550706	ส้าน	San	55110	2025-12-18 04:35:47.787	5507
120605	120605	บางตะไนย์	Bang Tanai	11120	2025-12-18 04:35:38.907	1206
640401	640401	กง	Kong	64170	2025-12-18 04:35:48.435	6404
650111	650111	หัวรอ	Hua Ro	65000	2025-12-18 04:35:48.544	6501
130707	130707	บ้านปทุม	Ban Pathum	12160	2025-12-18 04:35:39	1307
130708	130708	บ้านงิ้ว	Ban Ngio	12160	2025-12-18 04:35:39.001	1307
140419	140419	ราชคราม	Ratchakhram	13290	2025-12-18 04:35:39.143	1404
710512	710512	พระแท่น	Phra Thaen	71130	2025-12-18 04:35:49.269	7105
140420	140420	ช้างใหญ่	Chang Yai	13290	2025-12-18 04:35:39.145	1404
140421	140421	โพแตง	Pho Taeng	13290	2025-12-18 04:35:39.146	1404
730208	730208	ดอนข่อย	Don Khoi	73140	2025-12-18 04:35:49.619	7302
770203	770203	เขาแดง	Khao Daeng	77150	2025-12-18 04:35:50.039	7702
800303	800303	ท่าดี	Tha Di	80230	2025-12-18 04:35:50.11	8003
801302	801302	หินตก	Hin Tok	80350	2025-12-18 04:35:50.217	8013
140811	140811	โคกช้าง	Khok Chang	13120	2025-12-18 04:35:39.235	1408
860203	860203	สลุย	Salui	86140	2025-12-18 04:35:51.153	8602
140812	140812	จักราช	Chakkarat	13280	2025-12-18 04:35:39.236	1408
100101	100101	พระบรมมหาราชวัง	Phra Borom Maha Ratchawang	10200	2025-12-18 04:35:38.5	1001
100102	100102	วังบูรพาภิรมย์	Wang Burapha Phirom	10200	2025-12-18 04:35:38.505	1001
120606	120606	คลองพระอุดม	Khlong Phra Udom	11120	2025-12-18 04:35:38.908	1206
140423	140423	โคกช้าง	Khok Chang	13190	2025-12-18 04:35:39.149	1404
160305	160305	ห้วยโป่ง	Huai Pong	15120	2025-12-18 04:35:39.559	1603
220202	220202	บ่อ	Bo	22110	2025-12-18 04:35:40.43	2202
250701	250701	ประจันตคาม	Prachantakham	25130	2025-12-18 04:35:40.93	2507
300609	300609	พระพุทธ	Phra Phut	30230	2025-12-18 04:35:41.383	3006
301211	301211	สีดา	Sri Da	30120	2025-12-18 04:35:41.555	3012
321703	321703	โนน	Non	32130	2025-12-18 04:35:42.68	3217
330409	330409	ตระกาจ	Trakat	33110	2025-12-18 04:35:42.732	3304
330907	330907	ด่าน	Dan	33160	2025-12-18 04:35:42.806	3309
341111	341111	ตระการ	Trakan	34130	2025-12-18 04:35:42.987	3411
360613	360613	ส้มป่อย	Sompoi	36130	2025-12-18 04:35:43.245	3606
370102	370102	ไก่คำ	Kai Kham	37000	2025-12-18 04:35:43.352	3701
401706	401706	นาข่า	Na Kha	40160	2025-12-18 04:35:44.063	4017
411002	411002	หนองหญ้าไซ	Nong Ya Sai	41280	2025-12-18 04:35:44.296	4110
420803	420803	อาฮี	A Hi	42140	2025-12-18 04:35:44.586	4208
440902	440902	ขามป้อม	Kham Pom	44120	2025-12-18 04:35:45.13	4409
470202	470202	นาโพธิ์	Na Pho	47210	2025-12-18 04:35:46.253	4702
481001	481001	โพนสวรรค์	Phon Sawan	48190	2025-12-18 04:35:46.732	4810
500103	500103	หายยา	Haiya	50100	2025-12-18 04:35:46.864	5001
530306	530306	ท่าแฝก	Tha Faek	53110	2025-12-18 04:35:47.554	5303
540702	540702	สรอย	Saroi	54160	2025-12-18 04:35:47.719	5407
571401	571401	ต้า	Ta	57340	2025-12-18 04:35:47.997	5714
601304	601304	วังซ่าน	Wang San	60150	2025-12-18 04:35:48.182	6013
610611	610611	บ้านบึง	Ban Bueng	61140	2025-12-18 04:35:48.241	6106
630602	630602	แม่กุ	Mae Ku	63110	2025-12-18 04:35:48.366	6306
650112	650112	จอมทอง	Chom Thong	65000	2025-12-18 04:35:48.546	6501
650706	650706	คันโช้ง	Khan Chong	65160	2025-12-18 04:35:48.647	6507
710603	710603	วังศาลา	Wang Sala	71110	2025-12-18 04:35:49.28	7106
720209	720209	หัวนา	Hua Na	72120	2025-12-18 04:35:49.387	7202
760401	760401	ชะอำ	Cha-am	76120	2025-12-18 04:35:49.963	7604
770201	770201	กุยบุรี	Kui Buri	77150	2025-12-18 04:35:50.037	7702
801101	801101	ท่ายาง	Tha Yang	80240	2025-12-18 04:35:50.187	8011
810805	810805	โคกยาง	Khok Yang	81130	2025-12-18 04:35:50.402	8108
841712	841712	มะลวน	Maluan	84130	2025-12-18 04:35:50.967	8417
860207	860207	หงษ์เจริญ	Hong Charoen	86140	2025-12-18 04:35:51.163	8602
901108	901108	ฉลุง	Chalung	90110	2025-12-18 04:35:51.519	9011
910402	910402	แป-ระ	Paera	91150	2025-12-18 04:35:51.67	9104
940305	940305	ตุยง	Tuyong	94170	2025-12-18 04:35:52.073	9403
950603	950603	กาลอ	Kalo	95140	2025-12-18 04:35:52.386	9506
960703	960703	ศรีสาคร	Si Sakhon	96210	2025-12-18 04:35:52.547	9607
960704	960704	เชิงคีรี	Choeng Khiri	96210	2025-12-18 04:35:52.548	9607
960705	960705	กาหลง	Kalong	96210	2025-12-18 04:35:52.55	9607
960706	960706	ศรีบรรพต	Si Banphot	96210	2025-12-18 04:35:52.552	9607
960801	960801	แว้ง	Waeng	96160	2025-12-18 04:35:52.554	9608
960802	960802	กายูคละ	Kayu Khla	96160	2025-12-18 04:35:52.556	9608
960803	960803	ฆอเลาะ	Kholo	96160	2025-12-18 04:35:52.558	9608
960804	960804	โละจูด	Lochut	96160	2025-12-18 04:35:52.56	9608
960805	960805	แม่ดง	Mae Dong	96160	2025-12-18 04:35:52.562	9608
960806	960806	เอราวัณ	Erawan	96160	2025-12-18 04:35:52.564	9608
960901	960901	มาโมง	Mamong	96190	2025-12-18 04:35:52.567	9609
960902	960902	สุคิริน	Sukhirin	96190	2025-12-18 04:35:52.569	9609
960903	960903	เกียร์	Kia	96190	2025-12-18 04:35:52.571	9609
960904	960904	ภูเขาทอง	Phukhao Thong	96190	2025-12-18 04:35:52.573	9609
960905	960905	ร่มไทร	Rom Sai	96190	2025-12-18 04:35:52.576	9609
961001	961001	สุไหงโก-ลก	Su-ngai Kolok	96120	2025-12-18 04:35:52.578	9610
961002	961002	ปาเสมัส	Pase Mat	96120	2025-12-18 04:35:52.58	9610
961003	961003	มูโนะ	Muno	96120	2025-12-18 04:35:52.582	9610
961004	961004	ปูโยะ	Puyo	96120	2025-12-18 04:35:52.585	9610
961101	961101	ปะลุรู	Paluru	96140	2025-12-18 04:35:52.587	9611
961102	961102	สุไหงปาดี	Su-ngai Padi	96140	2025-12-18 04:35:52.591	9611
961103	961103	โต๊ะเด็ง	To Deng	96140	2025-12-18 04:35:52.593	9611
961104	961104	สากอ	Sako	96140	2025-12-18 04:35:52.594	9611
961105	961105	ริโก๋	Riko	96140	2025-12-18 04:35:52.596	9611
961106	961106	กาวะ	Ka Wa	96140	2025-12-18 04:35:52.598	9611
961201	961201	จะแนะ	Chanae	96220	2025-12-18 04:35:52.6	9612
961202	961202	ดุซงญอ	Dusong Yo	96220	2025-12-18 04:35:52.602	9612
961203	961203	ผดุงมาตร	Phadung Mat	96220	2025-12-18 04:35:52.604	9612
961204	961204	ช้างเผือก	Chang Phueak	96220	2025-12-18 04:35:52.606	9612
961301	961301	จวบ	Chuap	96130	2025-12-18 04:35:52.608	9613
961302	961302	บูกิต	Bukit	96130	2025-12-18 04:35:52.611	9613
961303	961303	มะรือโบออก	Maruebo Ok	96130	2025-12-18 04:35:52.613	9613
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suppliers (id, code, display_name, tax_id, address, phone, email, province_id, district_id, subdistrict_id, status, notes, rubber_type_codes, created_at, updated_at, first_name, last_name, title, avatar, zip_code, certificate_number, certificate_expire, score, eudr_quota_used, eudr_quota_current, contact_person, is_active, deleted_at, deleted_by) FROM stdin;
11	0096	นายบุญส่ง อินธนู	\N	34/3 ม.3	0898746893	\N	67	8416	841603	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.642	2025-12-19 02:35:04.803	บุญส่ง	อินธนู	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
2	0021	นายอุดม แก้วมณี	\N	\N	0822718068		\N	\N	\N	ACTIVE		{Regular_CL,Regular_USS}	2025-12-18 04:35:52.621	2025-12-19 02:35:04.789	อุดม	แก้วมณี	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
20	0239	นายศรัญญู ศรีนุ่น	\N	160/4 ม.5	0805421472	\N	11	2009	200904	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.667	2025-12-19 02:35:04.819	ศรัญญู	ศรีนุ่น	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
21	0259	นางสุคนธ์ พุทรง	\N	29 ม.3	0836430891	\N	65	8206	820602	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.67	2025-12-19 02:35:04.821	สุคนธ์	พุทรง	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
22	0273	นางภิญญา ทวีแก้ว	\N	102 ม.3	0801469851	\N	67	8418	841803	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.673	2025-12-19 02:35:04.823	ภิญญา	ทวีแก้ว	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
23	0275	นายฮาโหรน วาดวงค์พักตร์	\N	1/11 ม.4	0822774904	\N	65	8205	820502	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.675	2025-12-19 02:35:04.824	ฮาโหรน	วาดวงค์พักตร์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
25	0292	หจก.เสกทรัพย์ ยางพารา	\N	28/62 ม.1 ถ.เพชรเกษม	0881792489	\N	65	8205	820504	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.68	2025-12-19 02:35:04.827	เสกทรัพย์	ยางพารา	หจก.	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
26	0302	นายวีระ ฉิมเรือง	\N	82/1 ม.2	0862793230	\N	67	8416	841603	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.682	2025-12-19 02:35:04.829	วีระ	ฉิมเรือง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
27	0307	นายสุนทร สองเมือง	\N	41 ม.1	0812712183	\N	65	8206	820605	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.684	2025-12-19 02:35:04.83	สุนทร	สองเมือง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
28	0330	นายชาญ เพ้งหล้ง	\N	162 ม.2 ถ.ตรัง-ปะเหลียน	0818937344	\N	72	9204	920407	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.688	2025-12-19 02:35:04.832	ชาญ	เพ้งหล้ง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
29	0338	นายวิชัย วรรณวิชัยกุล	\N	75/4 ม.2	0898735032	\N	67	8411	841106	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.691	2025-12-19 02:35:04.834	วิชัย	วรรณวิชัยกุล	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
30	0342	นายสรายุทธ คงวุ่น	\N	68 ม.3	0963837206	\N	67	8419	841902	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.694	2025-12-19 02:35:04.835	สรายุทธ	คงวุ่น	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
32	0347	นางสุณีรัตน์ แซ่ลิ้ง	\N	11 ม.4	0862727661	\N	67	8417	841713	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.698	2025-12-19 02:35:04.839	สุณีรัตน์	แซ่ลิ้ง	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
39	0370	นายประพันธ์ ฤกษ์ดี	\N	95 ม.8	0818944695	\N	67	8417	841712	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.712	2025-12-19 02:35:04.85	ประพันธ์	ฤกษ์ดี	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
40	0372	นายสุริพล แก้วพิชัย	\N	205 ม.6	0828004550	\N	69	8602	860210	ACTIVE	\N	{EUDR_CL,North_East_CL,Regular_CL,Regular_USS}	2025-12-18 04:35:52.714	2025-12-19 02:35:04.851	สุริพล	แก้วพิชัย	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
42	0374	นายไพโรจน์ พิกุลทอง	\N	25/1 ม.7	0898746833	\N	67	8417	841709	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.717	2025-12-19 02:35:04.854	ไพโรจน์	พิกุลทอง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
43	0375	นายธีรภัทร อุดมวิทยาไกร	\N	176 ถ.ธราธิบดี	0814778070	\N	67	8417	841701	ACTIVE	\N	{EUDR_CL,Regular_CL,Regular_USS}	2025-12-18 04:35:52.719	2025-12-19 02:35:04.856	ธีรภัทร	อุดมวิทยาไกร	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
44	0377	นางสิริพันธ์ เกศดายุรัตน์	\N	34/1 ม.1	0987956536	\N	67	8407	840702	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.721	2025-12-19 02:35:04.857	สิริพันธ์	เกศดายุรัตน์	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
45	0378	นางสาวกุสุมา บุญตรี	\N	4 ม.11	086-322-6306	\N	67	8403	840304	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.723	2025-12-19 02:35:04.859	กุสุมา	บุญตรี	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
48	0389	นางสาวกัญญาภัทร ไชยยุทธ์	\N	57/1 ม.5	0918780297	\N	67	8408	840808	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.728	2025-12-19 02:35:04.863	กัญญาภัทร	ไชยยุทธ์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
50	0401	นางเบญจมาศ ประดิษฐพร	\N	39 ถ.สราญราษฎร์	0900687484	\N	67	8417	841701	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.732	2025-12-19 02:35:04.866	เบญจมาศ	ประดิษฐพร	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
51	0402	นางจำเนียร รุ่งเรือง	\N	54 ม.14	0937286986	\N	67	8414	841405	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.734	2025-12-19 02:35:04.868	จำเนียร	รุ่งเรือง	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
53	0407	นายพงษ์ศักดิ์ ฐานา	\N	104/4 ม.11	0821447492	\N	67	8415	841503	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.739	2025-12-19 02:35:04.871	พงษ์ศักดิ์	ฐานา	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
54	0414	นางสาวนิภา เกียรติอนันต์	\N	14/2 ม.3	0832434554	\N	67	8417	841705	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.741	2025-12-19 02:35:04.872	นิภา	เกียรติอนันต์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
55	0419	นายก้องเกียรติ เพชรแก้ว	\N	98/12 ม.6	0848393487	\N	69	8601	860111	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.742	2025-12-19 02:35:04.874	ก้องเกียรติ	เพชรแก้ว	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
56	0421	นางสาวประไพศรี ยุ่ยฉิม	\N	37 ม.10	0898667737	\N	67	8408	840803	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.744	2025-12-19 02:35:04.875	ประไพศรี	ยุ่ยฉิม	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
24	0286	นายศักดิ์ชัย สื่อวานิชกุล	\N	37/1 ถ.จุลจอมเกล้า	0818940578	\N	67	8417	841701	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.678	2025-12-19 02:35:04.826	ศักดิ์ชัย	สื่อวานิชกุล	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
31	0345	นายเกียรติชัย พรรณแสง	\N	83/4 ม.6	0878811701	\N	64	8101	810105	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.696	2025-12-19 02:35:04.837	เกียรติชัย	พรรณแสง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
41	0373	นางจันทิรา กุลภัทรคำเงิน	\N	182 ม.4	0818936905	\N	67	8417	841706	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.715	2025-12-19 02:35:04.853	จันทิรา	กุลภัทรคำเงิน	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
46	0379	นายวัชรพงษ์ วรรณชนะ	\N	24/1 ม.3	0862667617	\N	67	8417	841704	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.724	2025-12-19 02:35:04.86	วัชรพงษ์	วรรณชนะ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
49	0393	นางสาวอุทุมพร เรืองดิษฐ์	\N	87/2 ม.4	0872794967	\N	67	8416	841602	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.73	2025-12-19 02:35:04.865	อุทุมพร	เรืองดิษฐ์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
52	0404	สหกรณ์บริการขนส่งและการค้า จำกัด	\N	248 หมู่5 ถ.กาญจนาภิเษก	0815513817	\N	1	1050	105001	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.737	2025-12-19 02:35:04.869	บริการขนส่งและการค้า	จำกัด	สหกรณ์	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
57	0422	นางสาวสุวรรณี มีความสุข	\N	44 ม.3	0878273410	\N	67	8418	841804	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.746	2025-12-19 02:35:04.877	สุวรรณี	มีความสุข	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
61	0428	นางสาวววรรณพร เชาวฤทธิ์	\N	41 ม.12	0872640460	\N	67	8419	841901	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.754	2025-12-19 02:35:04.883	ววรรณพร	เชาวฤทธิ์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
66	0435	นายทวีศักดิ์ พัฒน์พงศ์	\N	32/3 ม.2	0612375786	\N	67	8417	841708	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.761	2025-12-19 02:35:04.89	ทวีศักดิ์	พัฒน์พงศ์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
69	0438	นางเปรมกมล เหล่าบัณฑิต	\N	238 ถ.ธราธิบดี	0872704161	\N	67	8417	841701	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.766	2025-12-19 02:35:04.895	เปรมกมล	เหล่าบัณฑิต	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
76	0450	นายชลากร กุลภัทรคำเงิน	\N	36 ม.3	0818936905	\N	67	8409	840901	ACTIVE	\N	{EUDR_CL,Regular_CL,Regular_USS}	2025-12-18 04:35:52.78	2025-12-19 02:35:04.905	ชลากร	กุลภัทรคำเงิน	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
79	0454	นายประเสริฐ ทิพย์บรรพต	\N	34/20 ซ.หมู่บ้านธานทิพย์ 8 ถ.ศิริรักษ์	0865959616	\N	67	8417	841701	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.786	2025-12-19 02:35:04.909	ประเสริฐ	ทิพย์บรรพต	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
85	0462	นางสาวศุภธิดา ชุมทอง	\N	57/2 ม.2	0816067381	\N	67	8411	841105	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.797	2025-12-19 02:35:04.919	ศุภธิดา	ชุมทอง	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
90	0467	นางเฟื่องฟ้า ตั้งแซ่	\N	3/48	0819569791	\N	67	8401	840101	ACTIVE	\N	{EUDR_CL,Regular_CL,Regular_USS}	2025-12-18 04:35:52.805	2025-12-19 02:35:04.926	เฟื่องฟ้า	ตั้งแซ่	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
94	0471	บริษัทเอส พี ที (2016)	\N	113 ม.9	0896524566	\N	63	8013	801302	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.812	2025-12-19 02:35:04.932	เอส	พี ที (2016)	บริษัท	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
97	0475	นายวรพจน์ เรืองพลับ	\N	125/3 ม.7	0854716879	\N	67	8406	840609	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.817	2025-12-19 02:35:04.937	วรพจน์	เรืองพลับ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
99	0477	สหกรณ์ผู้ผลิตยางพาราสุราษฎร์ธานี จำกัด	\N	49 ม.4	0890549112	\N	67	8417	841713	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.82	2025-12-19 02:35:04.94	ผู้ผลิตยางพาราสุราษฎร์ธานี	จำกัด	สหกรณ์	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
108	0489	นายณัฐวิทย์ โรยทองคำ	\N	160/2 ม.5	0831761109	\N	67	8411	841103	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.838	2025-12-19 02:35:04.954	ณัฐวิทย์	โรยทองคำ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
113	0495	นายวิวัฒน์ เรืองดิษฐ์	\N	87/3 ม.4	0952287914	\N	67	8416	841602	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.852	2025-12-19 02:35:04.991	วิวัฒน์	เรืองดิษฐ์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
117	0499	นางสาวปวีณา หมวดทอง	\N	141 ม.5	0993043619	\N	67	8411	841102	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.86	2025-12-19 02:35:05.006	ปวีณา	หมวดทอง	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
121	0504	นายจันทรายุทธ จิตราภิรมย์	\N	8 ม.5	0882642823	\N	67	8417	841711	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.87	2025-12-19 02:35:05.012	จันทรายุทธ	จิตราภิรมย์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
126	0510	นางสาวอารดา คุ้มครอง	\N	60 ม.4	0901589605	\N	67	8410	841004	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.88	2025-12-19 02:35:05.021	อารดา	คุ้มครอง	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
129	0513	นางสาวจิรพรรณ เพชรศรี	\N	31/4 ม.2	0615956878	\N	67	8411	841105	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.884	2025-12-19 02:35:05.025	จิรพรรณ	เพชรศรี	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
130	0514	สหกรณ์การเกษตรบ้านเชี่ยวหลาน จำกัด	\N	16 ม.4	0951539519	\N	67	8409	840904	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.886	2025-12-19 02:35:05.027	การเกษตรบ้านเชี่ยวหลาน	จำกัด	สหกรณ์	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
59	0425	นายกิตติศักดิ์ แซ่ด่าน	\N	147 ม.4	0814260396	\N	67	8411	841103	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.75	2025-12-19 02:35:04.88	กิตติศักดิ์	แซ่ด่าน	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
60	0427	หจก.ยะหา ยางพารา	\N	54/1 ม.2	0814260396	\N	75	9505	950501	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.752	2025-12-19 02:35:04.881	ยะหา	ยางพารา	หจก.	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
62	0429	นางสาวนิตยา ปานเดช	\N	14 ม.1	0847686972	\N	67	8417	841709	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.755	2025-12-19 02:35:04.884	นิตยา	ปานเดช	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
63	0432	นายมูฮำหมัด สะมะแอ	\N	98/2 ม.8	0612375783	\N	75	9507	950702	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.757	2025-12-19 02:35:04.886	มูฮำหมัด	สะมะแอ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
64	0433	นายไกรศักดิ์ พันธ์สน	\N	15/1 ม.1	0612375784	\N	66	8303	830301	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.758	2025-12-19 02:35:04.887	ไกรศักดิ์	พันธ์สน	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
65	0434	นายปุณณภพ ไชยโย	\N	68 ม.2	0848463971	\N	67	8411	841101	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.759	2025-12-19 02:35:04.889	ปุณณภพ	ไชยโย	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
67	0436	นายธนกฤต เพชรคง	\N	43 ม.4	0816072206	\N	67	8402	840203	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.763	2025-12-19 02:35:04.892	ธนกฤต	เพชรคง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
68	0437	นางสาววิลัยรักษ์ พรหมรักษ์	\N	212 ม.2	0816072207	\N	67	8411	841106	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.765	2025-12-19 02:35:04.893	วิลัยรักษ์	พรหมรักษ์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
70	0439	นางจริญา พิมพ์ช่างไม้	\N	180/21 ม.1 ซ.ร่วมฤดี	0954199239	\N	67	8401	840102	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.768	2025-12-19 02:35:04.896	จริญา	พิมพ์ช่างไม้	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
72	0441	นายเชิดศักดิ์ แซ่เฮ่า	\N	34/1 ม.12	0822765120	\N	67	8402	840206	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.772	2025-12-19 02:35:04.899	เชิดศักดิ์	แซ่เฮ่า	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
73	0444	นายเดชากุล แสงอุทัศน์	\N	64/2 ม.1	0616457498	\N	67	8417	841706	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.774	2025-12-19 02:35:04.9	เดชากุล	แสงอุทัศน์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
74	0448	นางจิรา สาลี	\N	106 ม.4	0861206190	\N	67	8407	840706	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.775	2025-12-19 02:35:04.902	จิรา	สาลี	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
75	0449	นายพิทยาพล ชัยรัตน์	\N	11/1 ม.1	0806954791	\N	67	8416	841604	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.778	2025-12-19 02:35:04.903	พิทยาพล	ชัยรัตน์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
77	0451	นายธีระศักดิ์ เตือนวีระเดช	\N	229 ม.1	0818947017	\N	63	8009	800902	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.782	2025-12-19 02:35:04.906	ธีระศักดิ์	เตือนวีระเดช	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
78	0452	นางสาวกรรณิกา ศรีคิรินทร์	\N	4 ม.15	0635839159	\N	67	8408	840801	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.784	2025-12-19 02:35:04.907	กรรณิกา	ศรีคิรินทร์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
80	0455	นายณรงค์ฤทธิ์ บุตรมิตร	\N	65 ม.2	0818936910	\N	64	8102	810204	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.787	2025-12-19 02:35:04.911	ณรงค์ฤทธิ์	บุตรมิตร	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
81	0456	นายอนันต์ ราชอุไร	\N	109 ม.4	0861616963	\N	64	8101	810105	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.789	2025-12-19 02:35:04.913	อนันต์	ราชอุไร	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
82	0458	นายภักดี มุขช่วย	\N	287 ม.2	0818936913	\N	68	8503	850305	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.791	2025-12-19 02:35:04.914	ภักดี	มุขช่วย	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
83	0460	นางสาวอภิสรา จันทร์พรมแก้ว	\N	76 ม.1	0993039669	\N	67	8417	841705	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.793	2025-12-19 02:35:04.916	อภิสรา	จันทร์พรมแก้ว	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
84	0461	นายธีรโนช วงศ์สุบรรณ	\N	183 ม.3	0998928798	\N	67	8417	841706	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.795	2025-12-19 02:35:04.917	ธีรโนช	วงศ์สุบรรณ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
86	0463	นางกาญจนา พาลเสือ	\N	40/1 ม.6	089-680-0970	\N	67	8410	841003	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.799	2025-12-19 02:35:04.92	กาญจนา	พาลเสือ	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
87	0464	นายธีรยุทธ ทิพย์ทองลาด	\N	84 ม.7 ถ.เทศบาล 8	0864801531	\N	76	9605	960501	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.8	2025-12-19 02:35:04.922	ธีรยุทธ	ทิพย์ทองลาด	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
88	0465	นายพลากร อภิรักษ์เสนา	\N	77 ม.7 ถ.เทศบาล 11	0819636884	\N	76	9605	960501	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.802	2025-12-19 02:35:04.923	พลากร	อภิรักษ์เสนา	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
89	0466	นายกูดา นิเซ็ง	\N	66 ม.5	0818977534	\N	76	9604	960403	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.804	2025-12-19 02:35:04.925	กูดา	นิเซ็ง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
91	0468	นางสาวธีราพร ซั่วเซ่งอี่	\N	61/2 ม.2	0857930405	\N	69	8607	860709	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.807	2025-12-19 02:35:04.928	ธีราพร	ซั่วเซ่งอี่	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
92	0469	นายสุนทร มีช้าง	\N	37/1 ม.2	0876875950	\N	67	8406	840608	ACTIVE	\N	{EUDR_CL}	2025-12-18 04:35:52.808	2025-12-19 02:35:04.929	สุนทร	มีช้าง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
93	0470	นายพนม พรหมวิเศษ	\N	6 ม.2	0856268541	\N	67	8417	841711	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.81	2025-12-19 02:35:04.931	พนม	พรหมวิเศษ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
96	0473	นายจักรกฤษณ์ วิเชียรครุฑ	\N	160/1 ม.3	0806979314	\N	65	8206	820601	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.816	2025-12-19 02:35:04.936	จักรกฤษณ์	วิเชียรครุฑ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
71	0440	นายนุกูล ชูพิน	\N	748 ม.15	0612294749	\N	69	8607	860709	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.77	2025-12-19 02:35:04.898	นุกูล	ชูพิน	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
98	0476	นายนฤสรณ์ วันวิน	\N	85/1 ม.4	0935838514	\N	67	8414	841403	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.818	2025-12-19 02:35:04.939	นฤสรณ์	วันวิน	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
100	0478	นางสาวกรรณิการ์ ชูสุวรรณ	\N	48 ม.2	0910400356	\N	67	8408	840807	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.823	2025-12-19 02:35:04.941	กรรณิการ์	ชูสุวรรณ	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
101	0479	นายยอดคีรี คงรักษา	\N	56/2 ม.12	0816293353	\N	67	8408	840801	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.824	2025-12-19 02:35:04.943	ยอดคีรี	คงรักษา	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
102	0481	นายพิมล นาคพล	\N	82/3 ม.5	0822604546	\N	67	8417	841705	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.825	2025-12-19 02:35:04.944	พิมล	นาคพล	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
103	0482	นายปราโมทย์ แสงแก้ว	\N	32/1 ม.2	0854748869	\N	67	8410	841002	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.827	2025-12-19 02:35:04.946	ปราโมทย์	แสงแก้ว	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
104	0486	นางสาวกาญจนา พรหมจรรย์	\N	7/2 ม.7	0824246663	\N	67	8417	841709	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.829	2025-12-19 02:35:04.947	กาญจนา	พรหมจรรย์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
105	0485	นายพิษณุ อุ่นศร	\N	83 ม.8	0810871198	\N	67	8410	841002	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.831	2025-12-19 02:35:04.949	พิษณุ	อุ่นศร	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
106	0487	นายทรงยศ ทับทอง	\N	75 ม.2	0897253234	\N	67	8411	841101	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.833	2025-12-19 02:35:04.951	ทรงยศ	ทับทอง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
107	0488	นายอัคเรศ กัญญาหาร	\N	101 ม.7	0866848633	\N	67	8407	840702	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.835	2025-12-19 02:35:04.953	อัคเรศ	กัญญาหาร	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
109	0490	นางวาสนา ฤทธิกุล	\N	36/4 ม.7	0848463971	\N	67	8408	840808	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.842	2025-12-19 02:35:04.964	วาสนา	ฤทธิกุล	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
110	0491	นายเกรียงสิทธิ์ ทิพย์ประชา	\N	54/3 ม.7	0866862336	\N	67	8417	841704	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.845	2025-12-19 02:35:04.97	เกรียงสิทธิ์	ทิพย์ประชา	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
111	0493	นายราชวัฒน์ หนูมาก	\N	125/499 ม.17	0876210587	\N	67	8407	840703	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.848	2025-12-19 02:35:04.981	ราชวัฒน์	หนูมาก	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
112	0494	นายวรารักษ์ วรรณศรี	\N	99 ม.6	0816078625	\N	67	8417	841709	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.85	2025-12-19 02:35:04.988	วรารักษ์	วรรณศรี	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
114	0496	นางสาวธนัชพร ชูจร	\N	35 ม.9	0825615857	\N	67	8419	841901	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.854	2025-12-19 02:35:04.994	ธนัชพร	ชูจร	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
115	0497	นางสาวรุ่งนภา แซ่เค้า	\N	1 ม.3	0979269222	\N	67	8411	841103	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.856	2025-12-19 02:35:05.001	รุ่งนภา	แซ่เค้า	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
116	0498	นายเฉลิมชัย วิเชียรพร	\N	25/1 ม.8	0895998443	\N	67	8408	840803	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.858	2025-12-19 02:35:05.004	เฉลิมชัย	วิเชียรพร	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
118	0501	นายธานินทร์ รักษาทรัพย์	\N	9 ม.1	0812710584	\N	67	8408	840803	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.863	2025-12-19 02:35:05.008	ธานินทร์	รักษาทรัพย์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
119	0502	นายนิรุตติ์ สุขอุ่น	\N	108/3 ม.8	0836447883	\N	67	8408	840808	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.865	2025-12-19 02:35:05.009	นิรุตติ์	สุขอุ่น	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
120	0503	นางรุ้งทอง แซ่ลิ้ง	\N	136 ม.8	0813707761	\N	67	8402	840203	ACTIVE	\N	{EUDR_CL,Regular_USS}	2025-12-18 04:35:52.868	2025-12-19 02:35:05.011	รุ้งทอง	แซ่ลิ้ง	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
122	0505	นายธีรชัย ไพบูลย์	\N	20/2 ม.5	0854714251	\N	67	8417	841705	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.872	2025-12-19 02:35:05.014	ธีรชัย	ไพบูลย์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
123	0507	นายจักรพันธ์ หีตช่วย	\N	38 ม.17	0895921087	\N	67	8419	841902	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.874	2025-12-19 02:35:05.016	จักรพันธ์	หีตช่วย	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
124	0508	นางสาวบุปผา กันเจริญ	\N	88/2 ม.7	0966788455	\N	67	8408	840801	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.876	2025-12-19 02:35:05.018	บุปผา	กันเจริญ	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
125	0509	นางอุทัย ขาวหล้า	\N	88 ม.6	0652127132	\N	67	8407	840702	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.878	2025-12-19 02:35:05.019	อุทัย	ขาวหล้า	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
127	0511	นายเตชินท์ สมทรง	\N	1884/3 ม.17	0831051202	\N	69	8602	860205	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.881	2025-12-19 02:35:05.022	เตชินท์	สมทรง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
128	0512	นางสาวณัฐสินี ธรรมภัทรกุล	\N	27/1 ม.1	0993594542	\N	67	8402	840206	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.883	2025-12-19 02:35:05.023	ณัฐสินี	ธรรมภัทรกุล	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
132	0516	นางธนพร มาดูฤกษ์	\N	159/1 ม.8	0625340558	\N	67	8417	841712	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.889	2025-12-19 02:35:05.03	ธนพร	มาดูฤกษ์	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
133	0517	นายสรายุทธ พึ่งสาระ	\N	143 ม.4	0987324755	\N	67	8406	840601	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.891	2025-12-19 02:35:05.032	สรายุทธ	พึ่งสาระ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
135	0520	นายวิเชียร ศรีสุวรรณ์	\N	131 ม.2	0899095179	\N	67	8410	841002	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.894	2025-12-19 02:35:05.035	วิเชียร	ศรีสุวรรณ์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
136	0521	นางสาวอรณิชชา สมเศรษฐ์	\N	17 ม.5	0876875950	\N	67	8406	840605	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.896	2025-12-19 02:35:05.036	อรณิชชา	สมเศรษฐ์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
138	0523	นายภูมินทร์ จันทร์ภุชงค์	\N	64/1 ม.2	0812735294	\N	67	8411	841106	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.899	2025-12-19 02:35:05.039	ภูมินทร์	จันทร์ภุชงค์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
139	0524	นางสาวปัณณรัตน์ สวัสดิ์วงษ์	\N	626/8 ม.4	0630979149	\N	67	8415	841502	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.901	2025-12-19 02:35:05.041	ปัณณรัตน์	สวัสดิ์วงษ์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
140	0525	สหกรณ์ผู้ผลิตยางพาราสุราษฎร์ธานี จำกัด (ไชยา)	\N	115 ม.2	0818936343	\N	67	8406	840608	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.903	2025-12-19 02:35:05.042	ผู้ผลิตยางพาราสุราษฎร์ธานี	จำกัด (ไชยา)	สหกรณ์	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
141	0527	นายกิตติชัย แก้วชู	\N	13 ม.4	0642658858	\N	63	8012	801216	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.904	2025-12-19 02:35:05.044	กิตติชัย	แก้วชู	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
142	0529	นายวัชรินทร์ ช่างสุวรรณ	\N	20 ม.7	0817280111	\N	67	8408	840809	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.906	2025-12-19 02:35:05.046	วัชรินทร์	ช่างสุวรรณ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
143	0534	นายวัฒนะ ดำอมร	\N	15/2 ม.10	0990898802	\N	69	8601	860112	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.908	2025-12-19 02:35:05.048	วัฒนะ	ดำอมร	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
145	0536	นายธวัชชัย อินหว่าง	\N	1 ม.10	0918588893	\N	67	8408	840803	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.911	2025-12-19 02:35:05.051	ธวัชชัย	อินหว่าง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
146	0538	นายทศพล แซ่เอียะ	\N	201/50 ม.1	0812737999	\N	69	8603	860305	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.913	2025-12-19 02:35:05.052	ทศพล	แซ่เอียะ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
147	0539	นายบัณฑิต ลี้ยุทธานนท์	\N	4 ม.3	0966363125	\N	67	8418	841801	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.914	2025-12-19 02:35:05.053	บัณฑิต	ลี้ยุทธานนท์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
149	0541	นางเจียมใจ ราชแสง	\N	84/6 ม.6	0937193171	\N	72	9201	920119	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.918	2025-12-19 02:35:05.056	เจียมใจ	ราชแสง	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
150	0542	นายอุดมศักดิ์ แซ่เอียะ	\N	299 ม.2	0959954632	\N	69	8602	860207	ACTIVE	\N	{EUDR_CL,EUDR_NCL,EUDR_USS,North_East_CL,Regular_CL,Regular_USS}	2025-12-18 04:35:52.919	2025-12-19 02:35:05.058	อุดมศักดิ์	แซ่เอียะ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
151	0544	นายมโนชย์ ทองรัตน์	\N	100 ม.6	0823521555	\N	63	8003	800301	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.92	2025-12-19 02:35:05.059	มโนชย์	ทองรัตน์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
153	0546	นางกมลวรรณ แจ้งใจ	\N	45/4 ม.5	084-385-3301	\N	65	8205	820504	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.923	2025-12-19 02:35:05.063	กมลวรรณ	แจ้งใจ	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
154	0547	นางสาววิลาวรรณ พลลือ	\N	185 ม.8	0862720615	\N	67	8417	841709	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.924	2025-12-19 02:35:05.064	วิลาวรรณ	พลลือ	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
155	0548	นายณัฐพงศ์ หมีรักษา	\N	119/5 ม.1	0808896904	\N	63	8002	800204	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.925	2025-12-19 02:35:05.066	ณัฐพงศ์	หมีรักษา	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
157	0550	นายสุทิน เหมาะสม	\N	36 ม.3	0872838907	\N	69	8602	860207	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.927	2025-12-19 02:35:05.069	สุทิน	เหมาะสม	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
158	0552	นายอัคคเดช ณ ระนอง	\N	6 ม.5	0814961978	\N	65	8205	820507	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.928	2025-12-19 02:35:05.071	อัคคเดช	ณ ระนอง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
159	0553	นางสาววิภารัตน์ ลักษณะ	\N	78/6 ม.12	0640892638	\N	67	8402	840206	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.929	2025-12-19 02:35:05.072	วิภารัตน์	ลักษณะ	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
160	0554	นางสาวพรณรินทร์ คชมาศ	\N	11/50 ม.2	0855695343	\N	65	8205	820507	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.93	2025-12-19 02:35:05.073	พรณรินทร์	คชมาศ	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
162	0556	นายฐาปกรณ์ ศรีสุวรรณ	\N	131 ม.2	0828136350	\N	67	8410	841002	ACTIVE	\N	{EUDR_CL,North_East_CL,Regular_CL}	2025-12-18 04:35:52.933	2025-12-19 02:35:05.076	ฐาปกรณ์	ศรีสุวรรณ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
163	0557	นายภัฐณน แซ่อึ๋ง	\N	54/1 ม.5	0898670670	\N	65	8204	820405	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.934	2025-12-19 02:35:05.078	ภัฐณน	แซ่อึ๋ง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
164	0558	ว่าที่ ร.ต.สรรค์ชัย ปรีชา	\N	70/1 ม.9	0935757350	\N	67	8415	841502	ACTIVE	\N	{EUDR_CL,North_East_CL,Regular_CL}	2025-12-18 04:35:52.935	2025-12-19 02:35:05.079	ว่าที่	ร.ต.สรรค์ชัย ปรีชา	\N	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
137	0522	สหกรณ์บริการขนส่งและการค้า (สาขากาญจนดิษฐ์)	\N	23/8 ม.3	0812702022	\N	67	8402	840211	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.898	2025-12-19 02:35:05.038	บริการขนส่งและการค้า	(สาขากาญจนดิษฐ์)	สหกรณ์	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
144	0535	นายตรีอำพร หลิวปลอด	\N	386 ม.6	0901719857	\N	67	8401	840104	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.909	2025-12-19 02:35:05.049	ตรีอำพร	หลิวปลอด	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
148	0540	นายณรงค์ชัย พลภักดี	\N	29 ม.8	0898752502	\N	67	8408	840808	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.916	2025-12-19 02:35:05.055	ณรงค์ชัย	พลภักดี	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
167	0562	นางอรทัย วรชาติ	\N	202 ม.17	0848411437	\N	69	8602	860205	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.938	2025-12-19 02:35:05.084	อรทัย	วรชาติ	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
168	0563	นายสามารถ จันทร์ทิพย์	\N	183  ม.2	0895944462	\N	72	9206	920616	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.939	2025-12-19 02:35:05.085	สามารถ	จันทร์ทิพย์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
169	0567	นางสาวทิพย์วรรณ จันทนานนท์	\N	179/141 ม.14	0857860072	\N	67	8407	840703	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.94	2025-12-19 02:35:05.087	ทิพย์วรรณ	จันทนานนท์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
170	0568	นางสาวพิมพ์ชนก หาญช้าง	\N	19/4 ม.3	0954184746	\N	65	8208	820805	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.941	2025-12-19 02:35:05.088	พิมพ์ชนก	หาญช้าง	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
171	0569	นายณัฐพงษ์ ร่มแก้ว	\N	119/9 ม.7	0805378701	\N	69	8607	860701	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.942	2025-12-19 02:35:05.09	ณัฐพงษ์	ร่มแก้ว	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
172	0571	นายก้องเกียรติ ช่วยคงทอง	\N	183/4 ม.14	0822715077	\N	67	8403	840304	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.943	2025-12-19 02:35:05.092	ก้องเกียรติ	ช่วยคงทอง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
173	0573	บริษัทAgriac Global	\N	187/17 ถ.ประชาธิปัตย์	0865558080	\N	70	9011	901101	ACTIVE	\N	{EUDR_CL,Regular_USS}	2025-12-18 04:35:52.945	2025-12-19 02:35:05.093	Agriac	Global	บริษัท	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
174	0574	นายอนนท์ ปรางทอง	\N	4/16 ม.2	0899728699	\N	65	8205	820507	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.946	2025-12-19 02:35:05.095	อนนท์	ปรางทอง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
175	0581	นายนัฏฐพงศ์ ฤกษ์ดี	\N	95/2 ม.8	0818944695	\N	67	8417	841712	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.947	2025-12-19 02:35:05.096	นัฏฐพงศ์	ฤกษ์ดี	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
176	0583	นางสาวปรัสรา สุขศิริ	\N	261 ม.11	0997968388	\N	69	8604	860412	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.948	2025-12-19 02:35:05.098	ปรัสรา	สุขศิริ	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
177	0584	นายศุภกฤษ ศรีอาวุธ	\N	25/403	0818955945	\N	1	1044	104401	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.949	2025-12-19 02:35:05.099	ศุภกฤษ	ศรีอาวุธ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
178	0585	นายสมพงษ์ หนูแก้ว	\N	431 ม.11	0869420758	\N	69	8604	860404	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.95	2025-12-19 02:35:05.101	สมพงษ์	หนูแก้ว	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
179	0586	นายอรุณ วงค์รอด	\N	55 ม.3	0897543467	\N	63	8007	800709	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.951	2025-12-19 02:35:05.102	อรุณ	วงค์รอด	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
181	0588	นางสาววาสนา บุญเกื้อ	\N	155 ม.8	0810860564	\N	67	8408	840810	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.953	2025-12-19 02:35:05.105	วาสนา	บุญเกื้อ	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
183	0591	นายพิสุทธิ์ ศรีฟ้า	\N	57 ม.1	0936451425	\N	65	8206	820602	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.955	2025-12-19 02:35:05.108	พิสุทธิ์	ศรีฟ้า	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
184	0592	นายวุฒินันท์ เจริญสุข	\N	132/6 ม.1	0808972558	\N	70	9015	901509	ACTIVE	\N	{North_East_CL,Regular_CL}	2025-12-18 04:35:52.956	2025-12-19 02:35:05.109	วุฒินันท์	เจริญสุข	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
186	0594	นายสงกรานต์ เจริญธรรมสิทธิ์	\N	106/1	0863775552	\N	18	2707	270703	ACTIVE	\N	{North_East_CL}	2025-12-18 04:35:52.959	2025-12-19 02:35:05.112	สงกรานต์	เจริญธรรมสิทธิ์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
187	0595	นายบุณธรรม บุตรแดง	\N	164 ม.3	0613301615	\N	43	5514	551404	ACTIVE	\N	{North_East_CL}	2025-12-18 04:35:52.96	2025-12-19 02:35:05.114	บุณธรรม	บุตรแดง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
152	0545	นายรณชัย สุวรรณวงศ์	\N	60 ม.11	0801595388	\N	65	8204	820403	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.921	2025-12-19 02:35:05.061	รณชัย	สุวรรณวงศ์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
156	0549	นางสาวปภาดา อินทร์เกลี้ยง	\N	20 ม.6	0966535531	\N	67	8409	840901	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.926	2025-12-19 02:35:05.067	ปภาดา	อินทร์เกลี้ยง	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
161	0555	นายอภิชัย สัจจารักษ์	\N	50/3 ม.8	0933704965	\N	65	8204	820401	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.932	2025-12-19 02:35:05.075	อภิชัย	สัจจารักษ์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
165	0559	นายณัฐพงค์ คงคล้าย	\N	55 ม.1	0935848971	\N	67	8402	840209	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.936	2025-12-19 02:35:05.081	ณัฐพงค์	คงคล้าย	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
166	0560	นางสาวจิราพร หีตจินดา	\N	470 ม.4	0612371143	\N	67	8409	840904	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.937	2025-12-19 02:35:05.082	จิราพร	หีตจินดา	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
180	0587	นางสาวธิดารัตน์ ตอฮา	\N	9/30 ม.13	0629944293	\N	69	8602	860201	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.952	2025-12-19 02:35:05.104	ธิดารัตน์	ตอฮา	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
185	0593	นางสาวศยามล มูลสาคร	\N	14 ซ.นายอำเภอ	0817822022	\N	13	2203	220301	ACTIVE	\N	{North_East_CL}	2025-12-18 04:35:52.957	2025-12-19 02:35:05.111	ศยามล	มูลสาคร	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
188	0596	สหกรณ์เครดิตยูเนี่ยนบ้านไร่จันดี จำกัด	\N	7/27 ม.4	0863775552	\N	12	2101	210110	ACTIVE	\N	{EUDR_CL,North_East_CL}	2025-12-18 04:35:52.961	2025-12-19 02:35:05.115	เครดิตยูเนี่ยนบ้านไร่จันดี	จำกัด	สหกรณ์	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
19	0231	นางกาญจนา หูรัตนภิรมย์	\N	2 ซ.2 ถ.จุลจอมเกล้า	0818932879	\N	67	8417	841701	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.665	2025-12-19 02:35:04.818	กาญจนา	หูรัตนภิรมย์	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
47	0382	บริษัทสุราษฎร์สัมฤทธิ์ ธุรกิจ	\N	6 ถ.จุลจอมเกล้า	0890549112	\N	67	8417	841701	ACTIVE	\N	{EUDR_CL}	2025-12-18 04:35:52.726	2025-12-19 02:35:04.862	สุราษฎร์สัมฤทธิ์	ธุรกิจ	บริษัท	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
58	0423	นายจตุรนต์ จิยาเพชร	\N	139 ม.2	0887613927	\N	67	8411	841106	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.748	2025-12-19 02:35:04.879	จตุรนต์	จิยาเพชร	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
95	0472	บริษัทยางไทยปักต์ใต้ จำกัด	\N	157 ถ.นิพัทธอุทิศ 2	0935765151	\N	70	9011	901101	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.814	2025-12-19 02:35:04.934	ยางไทยปักต์ใต้	จำกัด	บริษัท	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
134	0518	นางปรานอม ช่วยสวัสดิ์	\N	10/9 ม.2	081-476-8325	\N	65	8201	820105	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.893	2025-12-19 02:35:05.033	ปรานอม	ช่วยสวัสดิ์	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
1	0016	บริษัทอกรีแอคโกลบอล จำกัด	\N	168/73	0865558080	\N	2	1103	110302	ACTIVE		{FSC_CL,FSC_USS}	2025-12-18 04:35:52.617	2025-12-19 02:35:04.781	อกรีแอคโกลบอล	จำกัด	บริษัท	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
3	0042	นางสาวศรีจันทร์ จริงจิตร	\N	5/3 ม.3	0813705533		67	8401	840104	ACTIVE		{EUDR_USS,Regular_CL,Regular_USS}	2025-12-18 04:35:52.623	2025-12-19 02:35:04.791	ศรีจันทร์	จริงจิตร	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
4	0065	นางฟาติมะฮ์ บาสอ	\N	15 ถนนยะหา-ตาชี	0612367091	\N	64	8104	810402	ACTIVE		{Regular_USS}	2025-12-18 04:35:52.625	2025-12-19 02:35:04.793	ฟาติมะฮ์	บาสอ	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
5	0070	นายเอกภพ นพทวี	\N	104 หมู่ 10	0817474931		67	8414	841401	ACTIVE		{Regular_CL}	2025-12-18 04:35:52.628	2025-12-19 02:35:04.795	เอกภพ	นพทวี	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
6	0071	นางสาวปนิดา เพ็ชรแดง	\N	100 หมู่ 5	0818938225		67	8413	841301	ACTIVE		{Regular_CL,Regular_USS}	2025-12-18 04:35:52.63	2025-12-19 02:35:04.796	ปนิดา	เพ็ชรแดง	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
7	0075	นางสาวจารีย์ รัตนพันธ์	\N	53/195 หมู่ 2 ถนน ศรีวิชัย	0819266192		67	8401	840102	ACTIVE		{Regular_CL,Regular_USS}	2025-12-18 04:35:52.632	2025-12-19 02:35:04.798	จารีย์	รัตนพันธ์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
8	0078	นายไรณูดิง มะเกะ	\N	40/7 หมู่ 3	0892984950		76	9606	960605	ACTIVE		{Regular_USS}	2025-12-18 04:35:52.635	2025-12-19 02:35:04.799	ไรณูดิง	มะเกะ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
9	0086	นายเทพฤทธิ์ ใจปลื้ม	\N	236/5 หมู่ 5	0812728688		67	8401	840102	ACTIVE		{Regular_CL,Regular_USS}	2025-12-18 04:35:52.638	2025-12-19 02:35:04.801	เทพฤทธิ์	ใจปลื้ม	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
10	0079	นายชัยพร หงนิพนธ์	\N	184 ม.13	0818963799	\N	70	9005	900505	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.641	2025-12-19 02:35:04.802	ชัยพร	หงนิพนธ์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
12	0107	นางสาวอมรรัตน์ สินชาตรี(ฤทธิอา)	\N	86/1 ม.8	0833928445	\N	67	8411	841102	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.645	2025-12-19 02:35:04.805	อมรรัตน์	สินชาตรี(ฤทธิอา)	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
13	0127	สหกรณ์การเกษตรรวบรวมผลิตผลทางการเกษตรทุ่งสง-ทุ่งใหญ่ จำกัด	\N	231/5 ม.5	0813705533	\N	63	8009	800902	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.648	2025-12-19 02:35:04.807	การเกษตรรวบรวมผลิตผลทางการเกษตรทุ่งสง-ทุ่งใหญ่	จำกัด	สหกรณ์	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
14	0138	นายอุดม หมาดเส็ม	\N	47 ม.1	0840656103	\N	64	8103	810303	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.651	2025-12-19 02:35:04.81	อุดม	หมาดเส็ม	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
15	0169	นางรัตนา จงศิริรัตนพันธ์	\N	100/23 ม.4	0634656777	\N	69	8607	860702	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.653	2025-12-19 02:35:04.811	รัตนา	จงศิริรัตนพันธ์	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
16	0194	นายสันต์ ติงสพัฒน์	\N	517 ม.5 ถ.เหนือคลอง-ชัยบุรี	0817377147	\N	64	8102	810201	ACTIVE	\N	{Regular_USS}	2025-12-18 04:35:52.657	2025-12-19 02:35:04.813	สันต์	ติงสพัฒน์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
17	0202	นายชาญ เพ้งหล้ง	\N	121 ม.6	0818937344	\N	72	9207	920703	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.659	2025-12-19 02:35:04.814	ชาญ	เพ้งหล้ง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
18	0213	นายรุ่งเลิศ ทองหยอด	\N	141 ม.17	0639039962	\N	69	8605	860501	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.662	2025-12-19 02:35:04.816	รุ่งเลิศ	ทองหยอด	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
33	0364	นายธนวัฒน์ วงสอาด	\N	8/1 ม.5	0855792229	\N	64	8105	810505	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.7	2025-12-19 02:35:04.84	ธนวัฒน์	วงสอาด	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
34	0365	นายทวีศักดิ์ เพชรเมือง	\N	62/1 ม.1	0847440790	\N	69	8607	860702	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.702	2025-12-19 02:35:04.842	ทวีศักดิ์	เพชรเมือง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
35	0366	นางอภิญญา อภิวัฒน์วราวงศ์	\N	149/24 ถ.จุลจอมเกล้า	0898722882	\N	67	8417	841701	ACTIVE	\N	{EUDR_CL,Regular_CL,Regular_USS}	2025-12-18 04:35:52.705	2025-12-19 02:35:04.843	อภิญญา	อภิวัฒน์วราวงศ์	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
36	0367	นายภูวดล ปิยะรัตน์	\N	4 ม.4	0819586490	\N	67	8417	841714	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.706	2025-12-19 02:35:04.845	ภูวดล	ปิยะรัตน์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
37	0368	นายธีรศักดิ์ เผือกเดช	\N	8 ม.10	0819589637	\N	67	8403	840301	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.708	2025-12-19 02:35:04.846	ธีรศักดิ์	เผือกเดช	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
38	0369	นางสาวปรียานันท์ พรหมคุ้ม	\N	114/2 ม.6	0878932422	\N	67	8417	841712	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.71	2025-12-19 02:35:04.848	ปรียานันท์	พรหมคุ้ม	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
182	0589	นายจเร หวานอม	\N	104/1 ม.9	0895949646	\N	67	8414	841402	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.954	2025-12-19 02:35:05.106	จเร	หวานอม	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
131	0515	นายธเนตร โอชุม	\N	23 ม.9	0867702636	\N	67	8408	840808	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.888	2025-12-19 02:35:05.028	ธเนตร	โอชุม	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
189	0597	นายดีน มีเบนซ์	\N	200/1 ม.9	0933507333	\N	45	5703	570305	ACTIVE	\N	{EUDR_CL,North_East_CL}	2025-12-18 04:35:52.962	2025-12-19 02:35:05.117	ดีน	มีเบนซ์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
190	0598	นายนัธทวัฒน์ คงหาเพชร	\N	79/168	0811922298	\N	67	8401	840110	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.963	2025-12-19 02:35:05.118	นัธทวัฒน์	คงหาเพชร	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
191	0599	นางสาวศจีรัตน์ หลักอินทร์	\N	114 ม.8	0818941559	\N	69	8601	860106	ACTIVE	\N	{Regular_CL,Regular_USS}	2025-12-18 04:35:52.964	2025-12-19 02:35:05.12	ศจีรัตน์	หลักอินทร์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
192	0600	นายเศรษฐ์ สนพิภพ	\N	9/5 ม.6	0818941559	\N	69	8601	860110	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.966	2025-12-19 02:35:05.121	เศรษฐ์	สนพิภพ	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
193	0601	นายวิชิต จำปาพันธ์	\N	99/6 ม.8	0821460654	\N	68	8504	850401	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.967	2025-12-19 02:35:05.123	วิชิต	จำปาพันธ์	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
194	0602	นางปราณี พรหมคุ้ม	\N	271/1 ม.5	0878932422	\N	67	8417	841712	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.968	2025-12-19 02:35:05.124	ปราณี	พรหมคุ้ม	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
195	0603	นางเยาวลักษณ์ สมทรง	\N	7/2 ม.11	0929691645	\N	63	8015	801502	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.969	2025-12-19 02:35:05.125	เยาวลักษณ์	สมทรง	นาง	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
196	0605	นางสาวอำพร ดำเชื้อ	\N	\N	0	\N	64	8105	810504	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.97	2025-12-19 02:35:05.127	อำพร	ดำเชื้อ	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
197	0606	นางสาวนิศากร ศักดา	\N	150 ม.5	0629625915	\N	67	8411	841103	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.971	2025-12-19 02:35:05.129	นิศากร	ศักดา	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
198	0611	นายธีระศักดิ์ ดำสีใหม่	\N	\N	0800402068	\N	67	8410	841002	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.972	2025-12-19 02:35:05.13	ธีระศักดิ์	ดำสีใหม่	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
199	0608	นางสาวมณีรัตน์ สมศักดิ์	\N	58/16 ม.4	0811883040	\N	63	8019	801904	ACTIVE	\N	{EUDR_CL,Regular_CL,Regular_USS,EUDR_USS}	2025-12-18 04:35:52.973	2025-12-19 02:35:05.132	มณีรัตน์	สมศักดิ์	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
200	0609	นางสาวนารากร แก้วสกด	\N	33 ม.6	0833959558	\N	68	8504	850404	ACTIVE	\N	{EUDR_CL,Regular_CL}	2025-12-18 04:35:52.974	2025-12-19 02:35:05.133	นารากร	แก้วสกด	นางสาว	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
201	0610	นายตะวัน พุทรง	\N	29 ม.3	0836430891	\N	65	8206	820602	ACTIVE	\N	{Regular_CL}	2025-12-18 04:35:52.975	2025-12-19 02:35:05.134	ตะวัน	พุทรง	นาย	\N	\N	\N	\N	0	\N	\N	\N	t	\N	\N
\.


--
-- Data for Name: user_app_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_app_permissions (id, user_id, "appName", actions, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, "createdAt", "updatedAt", avatar, department, display_name, first_name, hod_id, last_name, pin_code, "position", status, username, role, employee_id, failed_login_attempts, force_change_password, is_hod, last_login_at, manager_id, permissions, preferences, site, role_id) FROM stdin;
027fc907-e8b3-4017-b84d-5f0279965aae	admin@example.com	$2b$10$YourHashedPasswordHere	2025-12-31 08:30:36.116	2025-12-31 08:30:36.116	\N	\N	Admin User	Admin	\N	User	\N	\N	ACTIVE	\N	ADMIN	\N	0	f	f	\N	\N	[]	\N	\N	\N
2ac478f7-bea2-4c63-8b83-b6ffff647e04	admin@ytrc.co.th	$2b$10$vjIjDP5PS6K/pLgwrkpzTOhNVAkVyqW6.JIWFpwx1mJqhHQ4zvLfC	2025-12-31 08:30:36.134	2025-12-31 08:30:36.134	\N	\N	YTRC Admin	YTRC	\N	Admin	\N	\N	ACTIVE	\N	ADMIN	\N	0	f	f	\N	\N	[]	\N	\N	\N
aca59953-34bf-4338-952d-8c8812e8db90	user@example.com	$2b$10$YourHashedPasswordHere	2025-12-31 08:30:36.138	2025-12-31 08:30:36.138	\N	\N	Sample User	Sample	\N	User	\N	\N	ACTIVE	\N	USER	\N	0	f	f	\N	\N	[]	\N	\N	\N
61cfb8eb-a050-432d-bf1f-c0e2f3236f7a	apiwat.s@ytrc.co.th	$2b$10$uLQpYm8AOSk6oO5GKJND3u.NsSZhPvgdJZwu1/C8CEgOHEpdV.gRe	2025-12-31 08:30:36.136	2026-01-01 02:05:48.609	\N	Information Technology	Apiwat S.	Apiwat	\N	Sukjaroen	\N	Assistant Manager	ACTIVE	apiwat.s	admin	\N	0	f	f	2026-01-01 02:00:15.218	\N	[]	\N	\N	\N
\.


--
-- Name: NotificationGroup NotificationGroup_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."NotificationGroup"
    ADD CONSTRAINT "NotificationGroup_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: approval_logs approval_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_logs
    ADD CONSTRAINT approval_logs_pkey PRIMARY KEY (id);


--
-- Name: approval_requests approval_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_requests
    ADD CONSTRAINT approval_requests_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- Name: notification_settings notification_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: provinces provinces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rubber_types rubber_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rubber_types
    ADD CONSTRAINT rubber_types_pkey PRIMARY KEY (id);


--
-- Name: subdistricts subdistricts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subdistricts
    ADD CONSTRAINT subdistricts_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: user_app_permissions user_app_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_app_permissions
    ADD CONSTRAINT user_app_permissions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: NotificationGroup_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "NotificationGroup_name_key" ON public."NotificationGroup" USING btree (name);


--
-- Name: _NotificationGroupMembers_AB_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "_NotificationGroupMembers_AB_unique" ON public."_NotificationGroupMembers" USING btree ("A", "B");


--
-- Name: _NotificationGroupMembers_B_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "_NotificationGroupMembers_B_index" ON public."_NotificationGroupMembers" USING btree ("B");


--
-- Name: approval_logs_actor_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approval_logs_actor_id_idx ON public.approval_logs USING btree (actor_id);


--
-- Name: approval_logs_approval_request_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approval_logs_approval_request_id_idx ON public.approval_logs USING btree (approval_request_id);


--
-- Name: approval_requests_approver_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approval_requests_approver_id_idx ON public.approval_requests USING btree (approver_id);


--
-- Name: approval_requests_entity_type_entity_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approval_requests_entity_type_entity_id_idx ON public.approval_requests USING btree (entity_type, entity_id);


--
-- Name: approval_requests_requester_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approval_requests_requester_id_idx ON public.approval_requests USING btree (requester_id);


--
-- Name: approval_requests_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX approval_requests_status_idx ON public.approval_requests USING btree (status);


--
-- Name: bookings_booking_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bookings_booking_code_idx ON public.bookings USING btree (booking_code);


--
-- Name: bookings_booking_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX bookings_booking_code_key ON public.bookings USING btree (booking_code);


--
-- Name: bookings_date_slot_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bookings_date_slot_idx ON public.bookings USING btree (date, slot);


--
-- Name: bookings_deleted_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bookings_deleted_at_idx ON public.bookings USING btree (deleted_at);


--
-- Name: districts_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX districts_code_key ON public.districts USING btree (code);


--
-- Name: notification_settings_sourceApp_actionType_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "notification_settings_sourceApp_actionType_key" ON public.notification_settings USING btree ("sourceApp", "actionType");


--
-- Name: notifications_approval_request_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notifications_approval_request_id_idx ON public.notifications USING btree (approval_request_id);


--
-- Name: notifications_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX notifications_user_id_idx ON public.notifications USING btree (user_id);


--
-- Name: posts_authorId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "posts_authorId_idx" ON public.posts USING btree ("authorId");


--
-- Name: provinces_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX provinces_code_key ON public.provinces USING btree (code);


--
-- Name: roles_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX roles_name_key ON public.roles USING btree (name);


--
-- Name: rubber_types_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX rubber_types_code_key ON public.rubber_types USING btree (code);


--
-- Name: rubber_types_deleted_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX rubber_types_deleted_at_idx ON public.rubber_types USING btree (deleted_at);


--
-- Name: subdistricts_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX subdistricts_code_key ON public.subdistricts USING btree (code);


--
-- Name: suppliers_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX suppliers_code_key ON public.suppliers USING btree (code);


--
-- Name: suppliers_deleted_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX suppliers_deleted_at_idx ON public.suppliers USING btree (deleted_at);


--
-- Name: user_app_permissions_user_id_appName_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "user_app_permissions_user_id_appName_key" ON public.user_app_permissions USING btree (user_id, "appName");


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: users_employee_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_employee_id_key ON public.users USING btree (employee_id);


--
-- Name: users_username_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);


--
-- Name: _NotificationGroupMembers _NotificationGroupMembers_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_NotificationGroupMembers"
    ADD CONSTRAINT "_NotificationGroupMembers_A_fkey" FOREIGN KEY ("A") REFERENCES public."NotificationGroup"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _NotificationGroupMembers _NotificationGroupMembers_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_NotificationGroupMembers"
    ADD CONSTRAINT "_NotificationGroupMembers_B_fkey" FOREIGN KEY ("B") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: approval_logs approval_logs_approval_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_logs
    ADD CONSTRAINT approval_logs_approval_request_id_fkey FOREIGN KEY (approval_request_id) REFERENCES public.approval_requests(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: approval_requests approval_requests_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_requests
    ADD CONSTRAINT approval_requests_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: approval_requests approval_requests_requester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.approval_requests
    ADD CONSTRAINT approval_requests_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: districts districts_province_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_province_id_fkey FOREIGN KEY (province_id) REFERENCES public.provinces(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: posts posts_authorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT "posts_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subdistricts subdistricts_district_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subdistricts
    ADD CONSTRAINT subdistricts_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: suppliers suppliers_district_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: suppliers suppliers_province_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_province_id_fkey FOREIGN KEY (province_id) REFERENCES public.provinces(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: suppliers suppliers_subdistrict_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_subdistrict_id_fkey FOREIGN KEY (subdistrict_id) REFERENCES public.subdistricts(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: user_app_permissions user_app_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_app_permissions
    ADD CONSTRAINT user_app_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_hod_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_hod_id_fkey FOREIGN KEY (hod_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: users users_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict f7R8i9pD0Rzstx5sFgyzkF7EeyAXWE6aH53RDYiOQ7lPniiTKImO99E3jMbdCZR

