--
-- PostgreSQL database dump
--

-- Dumped from database version 13.21
-- Dumped by pg_dump version 17.5

-- Started on 2025-07-16 09:10:18

-- SET statement_timeout = 0;
-- SET lock_timeout = 0;
-- SET idle_in_transaction_session_timeout = 0;
-- SET transaction_timeout = 0;
-- SET client_encoding = 'UTF8';
-- SET standard_conforming_strings = on;
-- SELECT pg_catalog.set_config('search_path', '', false);
-- SET check_function_bodies = false;
-- SET xmloption = content;
-- SET client_min_messages = warning;
-- SET row_security = off;

--
-- TOC entry 4146 (class 1262 OID 16384)
-- Name: octopus; Type: DATABASE; Schema: -; Owner: -
--

\connect octopus

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- TOC entry 972 (class 1247 OID 17238)
-- Name: channel_bookmark_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.channel_bookmark_type AS ENUM (
    'link',
    'file'
);


--
-- TOC entry 924 (class 1247 OID 17089)
-- Name: channel_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.channel_type AS ENUM (
    'P',
    'G',
    'O',
    'D'
);


--
-- TOC entry 965 (class 1247 OID 17219)
-- Name: outgoingoauthconnections_granttype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.outgoingoauthconnections_granttype AS ENUM (
    'client_credentials',
    'password'
);


--
-- TOC entry 986 (class 1247 OID 17284)
-- Name: property_field_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.property_field_type AS ENUM (
    'text',
    'select',
    'multiselect',
    'date',
    'user',
    'multiuser'
);


--
-- TOC entry 928 (class 1247 OID 17116)
-- Name: team_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.team_type AS ENUM (
    'I',
    'O'
);


--
-- TOC entry 932 (class 1247 OID 17135)
-- Name: upload_session_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.upload_session_type AS ENUM (
    'attachment',
    'import'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 275 (class 1259 OID 17335)
-- Name: accesscontrolpolicies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accesscontrolpolicies (
    id character varying(26) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    active boolean NOT NULL,
    createat bigint NOT NULL,
    revision integer NOT NULL,
    version character varying(8) NOT NULL,
    data jsonb,
    props jsonb
);


--
-- TOC entry 276 (class 1259 OID 17343)
-- Name: accesscontrolpolicyhistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accesscontrolpolicyhistory (
    id character varying(26) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(128) NOT NULL,
    createat bigint NOT NULL,
    revision integer NOT NULL,
    version character varying(8) NOT NULL,
    data jsonb,
    props jsonb
);


--
-- TOC entry 270 (class 1259 OID 17297)
-- Name: propertyfields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.propertyfields (
    id character varying(26) NOT NULL,
    groupid character varying(26) NOT NULL,
    name character varying(255) NOT NULL,
    type public.property_field_type,
    attrs jsonb,
    targetid character varying(255),
    targettype character varying(255),
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    deleteat bigint NOT NULL
);


--
-- TOC entry 271 (class 1259 OID 17306)
-- Name: propertyvalues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.propertyvalues (
    id character varying(26) NOT NULL,
    targetid character varying(255) NOT NULL,
    targettype character varying(255) NOT NULL,
    groupid character varying(26) NOT NULL,
    fieldid character varying(26) NOT NULL,
    value jsonb NOT NULL,
    createat bigint NOT NULL,
    updateat bigint NOT NULL,
    deleteat bigint NOT NULL
);


--
-- TOC entry 277 (class 1259 OID 17353)
-- Name: attributeview; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.attributeview AS
 SELECT pv.groupid,
    pv.targetid,
    pv.targettype,
    jsonb_object_agg(pf.name,
        CASE
            WHEN (pf.type = 'select'::public.property_field_type) THEN ( SELECT to_jsonb(options.name) AS to_jsonb
               FROM jsonb_to_recordset((pf.attrs -> 'options'::text)) options(id text, name text)
              WHERE (options.id = (pv.value #>> '{}'::text[]))
             LIMIT 1)
            WHEN ((pf.type = 'multiselect'::public.property_field_type) AND (jsonb_typeof(pv.value) = 'array'::text)) THEN ( SELECT jsonb_agg(option_names.name) AS jsonb_agg
               FROM (jsonb_array_elements_text(pv.value) option_id(value)
                 JOIN jsonb_to_recordset((pf.attrs -> 'options'::text)) option_names(id text, name text) ON ((option_id.value = option_names.id))))
            ELSE pv.value
        END) AS attributes
   FROM (public.propertyvalues pv
     LEFT JOIN public.propertyfields pf ON (((pf.id)::text = (pv.fieldid)::text)))
  WHERE (((pv.deleteat = 0) OR (pv.deleteat IS NULL)) AND ((pf.deleteat = 0) OR (pf.deleteat IS NULL)))
  GROUP BY pv.groupid, pv.targetid, pv.targettype
  WITH NO DATA;


--
-- TOC entry 225 (class 1259 OID 16622)
-- Name: audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audits (
    id character varying(26) NOT NULL,
    createat bigint,
    userid character varying(26),
    action character varying(512),
    extrainfo character varying(1024),
    ipaddress character varying(64),
    sessionid character varying(26)
);


--
-- TOC entry 230 (class 1259 OID 16664)
-- Name: bots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bots (
    userid character varying(26) NOT NULL,
    description character varying(1024),
    ownerid character varying(190),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    lasticonupdate bigint
);


--
-- TOC entry 250 (class 1259 OID 16854)
-- Name: channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channels (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    teamid character varying(26),
    type public.channel_type,
    displayname character varying(64),
    name character varying(64),
    header character varying(1024),
    purpose character varying(250),
    lastpostat bigint,
    totalmsgcount bigint,
    extraupdateat bigint,
    creatorid character varying(26),
    schemeid character varying(26),
    groupconstrained boolean,
    shared boolean,
    totalmsgcountroot bigint,
    lastrootpostat bigint DEFAULT '0'::bigint,
    bannerinfo jsonb
);


--
-- TOC entry 221 (class 1259 OID 16576)
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    userid character varying(26),
    channelid character varying(26),
    rootid character varying(26),
    originalid character varying(26),
    message character varying(65535),
    type character varying(26),
    props jsonb,
    hashtags character varying(1000),
    filenames character varying(4000),
    fileids character varying(300),
    hasreactions boolean,
    editat bigint,
    ispinned boolean,
    remoteid character varying(26)
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


--
-- TOC entry 273 (class 1259 OID 17321)
-- Name: bot_posts_by_team_day; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.bot_posts_by_team_day AS
 SELECT (to_timestamp(((p.createat / 1000))::double precision))::date AS day,
    count(*) AS num,
    c.teamid
   FROM ((public.posts p
     JOIN public.bots b ON (((p.userid)::text = (b.userid)::text)))
     JOIN public.channels c ON (((p.channelid)::text = (c.id)::text)))
  GROUP BY ((to_timestamp(((p.createat / 1000))::double precision))::date), c.teamid
  WITH NO DATA;


--
-- TOC entry 286 (class 1259 OID 17518)
-- Name: calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calls (
    id character varying(26) NOT NULL,
    channelid character varying(26),
    startat bigint,
    endat bigint,
    createat bigint,
    deleteat bigint,
    title character varying(256),
    postid character varying(26),
    threadid character varying(26),
    ownerid character varying(26),
    participants jsonb NOT NULL,
    stats jsonb NOT NULL,
    props jsonb NOT NULL
);


--
-- TOC entry 284 (class 1259 OID 17490)
-- Name: calls_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calls_channels (
    channelid character varying(26) NOT NULL,
    enabled boolean,
    props jsonb NOT NULL
);


--
-- TOC entry 288 (class 1259 OID 17549)
-- Name: calls_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calls_jobs (
    id character varying(26) NOT NULL,
    callid character varying(26),
    type character varying(64),
    creatorid character varying(26),
    initat bigint,
    startat bigint,
    endat bigint,
    props jsonb NOT NULL
);


--
-- TOC entry 287 (class 1259 OID 17535)
-- Name: calls_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calls_sessions (
    id character varying(26) NOT NULL,
    callid character varying(26),
    userid character varying(26),
    joinat bigint,
    unmuted boolean,
    raisedhand bigint
);


--
-- TOC entry 267 (class 1259 OID 17243)
-- Name: channelbookmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channelbookmarks (
    id character varying(26) NOT NULL,
    ownerid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    fileinfoid character varying(26) DEFAULT NULL::character varying,
    createat bigint DEFAULT 0,
    updateat bigint DEFAULT 0,
    deleteat bigint DEFAULT 0,
    displayname text DEFAULT ''::text,
    sortorder integer DEFAULT 0,
    linkurl text,
    imageurl text,
    emoji character varying(64) DEFAULT NULL::character varying,
    type public.channel_bookmark_type DEFAULT 'link'::public.channel_bookmark_type,
    originalid character varying(26) DEFAULT NULL::character varying,
    parentid character varying(26) DEFAULT NULL::character varying
);


--
-- TOC entry 240 (class 1259 OID 16748)
-- Name: channelmemberhistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channelmemberhistory (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    jointime bigint NOT NULL,
    leavetime bigint
);


--
-- TOC entry 251 (class 1259 OID 16876)
-- Name: channelmembers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channelmembers (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    roles character varying(256),
    lastviewedat bigint,
    msgcount bigint,
    mentioncount bigint,
    notifyprops jsonb,
    lastupdateat bigint,
    schemeuser boolean,
    schemeadmin boolean,
    schemeguest boolean,
    mentioncountroot bigint,
    msgcountroot bigint,
    urgentmentioncount bigint
);


--
-- TOC entry 204 (class 1259 OID 16421)
-- Name: clusterdiscovery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clusterdiscovery (
    id character varying(26) NOT NULL,
    type character varying(64),
    clustername character varying(64),
    hostname character varying(512),
    gossipport integer,
    port integer,
    createat bigint,
    lastpingat bigint
);


--
-- TOC entry 213 (class 1259 OID 16495)
-- Name: commands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commands (
    id character varying(26) NOT NULL,
    token character varying(26),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    creatorid character varying(26),
    teamid character varying(26),
    trigger character varying(128),
    method character varying(1),
    username character varying(64),
    iconurl character varying(1024),
    autocomplete boolean,
    autocompletedesc character varying(1024),
    autocompletehint character varying(1024),
    displayname character varying(64),
    description character varying(128),
    url character varying(1024),
    pluginid character varying(190)
);


--
-- TOC entry 205 (class 1259 OID 16429)
-- Name: commandwebhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commandwebhooks (
    id character varying(26) NOT NULL,
    createat bigint,
    commandid character varying(26),
    userid character varying(26),
    channelid character varying(26),
    rootid character varying(26),
    usecount integer
);


--
-- TOC entry 206 (class 1259 OID 16435)
-- Name: compliances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.compliances (
    id character varying(26) NOT NULL,
    createat bigint,
    userid character varying(26),
    status character varying(64),
    count integer,
    "desc" character varying(512),
    type character varying(64),
    startat bigint,
    endat bigint,
    keywords character varying(512),
    emails character varying(1024)
);


--
-- TOC entry 200 (class 1259 OID 16385)
-- Name: db_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.db_lock (
    id character varying(64) NOT NULL,
    expireat bigint
);


--
-- TOC entry 201 (class 1259 OID 16390)
-- Name: db_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.db_migrations (
    version bigint NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 283 (class 1259 OID 17473)
-- Name: db_migrations_calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.db_migrations_calls (
    version bigint NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 263 (class 1259 OID 17198)
-- Name: desktoptokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.desktoptokens (
    token character varying(64) NOT NULL,
    createat bigint NOT NULL,
    userid character varying(26) NOT NULL
);


--
-- TOC entry 261 (class 1259 OID 17173)
-- Name: drafts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drafts (
    createat bigint,
    updateat bigint,
    deleteat bigint,
    userid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    rootid character varying(26) DEFAULT ''::character varying NOT NULL,
    message character varying(65535),
    props character varying(8000),
    fileids character varying(300),
    priority text
);


--
-- TOC entry 207 (class 1259 OID 16443)
-- Name: emoji; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emoji (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    creatorid character varying(26),
    name character varying(64)
);


--
-- TOC entry 248 (class 1259 OID 16829)
-- Name: fileinfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fileinfo (
    id character varying(26) NOT NULL,
    creatorid character varying(26),
    postid character varying(26),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    path character varying(512),
    thumbnailpath character varying(512),
    previewpath character varying(512),
    name character varying(256),
    extension character varying(64),
    size bigint,
    mimetype character varying(256),
    width integer,
    height integer,
    haspreviewimage boolean,
    minipreview bytea,
    content text,
    remoteid character varying(26),
    archived boolean DEFAULT false NOT NULL,
    channelid character varying(26)
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


--
-- TOC entry 274 (class 1259 OID 17326)
-- Name: file_stats; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.file_stats AS
 SELECT count(*) AS num,
    COALESCE(sum(fileinfo.size), (0)::numeric) AS usage
   FROM public.fileinfo
  WHERE (fileinfo.deleteat = 0)
  WITH NO DATA;


--
-- TOC entry 211 (class 1259 OID 16480)
-- Name: groupchannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groupchannels (
    groupid character varying(26) NOT NULL,
    autoadd boolean,
    schemeadmin boolean,
    createat bigint,
    deleteat bigint,
    updateat bigint,
    channelid character varying(26) NOT NULL
);


--
-- TOC entry 209 (class 1259 OID 16467)
-- Name: groupmembers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groupmembers (
    groupid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    createat bigint,
    deleteat bigint
);


--
-- TOC entry 210 (class 1259 OID 16473)
-- Name: groupteams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groupteams (
    groupid character varying(26) NOT NULL,
    autoadd boolean,
    schemeadmin boolean,
    createat bigint,
    deleteat bigint,
    updateat bigint,
    teamid character varying(26) NOT NULL
);


--
-- TOC entry 214 (class 1259 OID 16507)
-- Name: incomingwebhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incomingwebhooks (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    userid character varying(26),
    channelid character varying(26),
    teamid character varying(26),
    displayname character varying(64),
    description character varying(500),
    username character varying(255),
    iconurl character varying(1024),
    channellocked boolean
);


--
-- TOC entry 296 (class 1259 OID 17692)
-- Name: ir_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_category (
    id character varying(26) NOT NULL,
    name character varying(512) NOT NULL,
    teamid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    collapsed boolean DEFAULT false,
    createat bigint NOT NULL,
    updateat bigint DEFAULT 0 NOT NULL,
    deleteat bigint DEFAULT 0 NOT NULL
);


--
-- TOC entry 297 (class 1259 OID 17704)
-- Name: ir_category_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_category_item (
    type character varying(1) NOT NULL,
    categoryid character varying(26) NOT NULL,
    itemid character varying(26) NOT NULL
);


--
-- TOC entry 295 (class 1259 OID 17678)
-- Name: ir_channelaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_channelaction (
    id character varying(26) NOT NULL,
    channelid character varying(26),
    enabled boolean DEFAULT false,
    deleteat bigint DEFAULT 0 NOT NULL,
    actiontype character varying(65535) NOT NULL,
    triggertype character varying(65535) NOT NULL,
    payload json NOT NULL
);


--
-- TOC entry 279 (class 1259 OID 17414)
-- Name: ir_incident; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_incident (
    id character varying(26) NOT NULL,
    name character varying(1024) NOT NULL,
    description character varying(4096) NOT NULL,
    isactive boolean NOT NULL,
    commanderuserid character varying(26) NOT NULL,
    teamid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    createat bigint NOT NULL,
    endat bigint DEFAULT 0 NOT NULL,
    deleteat bigint DEFAULT 0 NOT NULL,
    activestage bigint NOT NULL,
    postid character varying(26) DEFAULT ''::text NOT NULL,
    playbookid character varying(26) DEFAULT ''::text NOT NULL,
    checklistsjson json NOT NULL,
    activestagetitle character varying(1024) DEFAULT ''::text,
    reminderpostid character varying(26),
    broadcastchannelid character varying(26) DEFAULT ''::text,
    previousreminder bigint DEFAULT 0 NOT NULL,
    remindermessagetemplate character varying(65535) DEFAULT ''::text,
    currentstatus character varying(1024) DEFAULT 'Active'::text NOT NULL,
    reporteruserid character varying(26) DEFAULT ''::text NOT NULL,
    concatenatedinviteduserids character varying(65535) DEFAULT ''::text,
    defaultcommanderid character varying(26) DEFAULT ''::text,
    announcementchannelid character varying(26) DEFAULT ''::text,
    concatenatedwebhookoncreationurls character varying(65535) DEFAULT ''::text,
    concatenatedinvitedgroupids character varying(65535) DEFAULT ''::text,
    retrospective character varying(65535) DEFAULT ''::text,
    messageonjoin character varying(65535) DEFAULT ''::text,
    retrospectivepublishedat bigint DEFAULT 0 NOT NULL,
    retrospectivereminderintervalseconds bigint DEFAULT 0 NOT NULL,
    retrospectivewascanceled boolean DEFAULT false,
    concatenatedwebhookonstatusupdateurls character varying(65535) DEFAULT ''::text,
    laststatusupdateat bigint DEFAULT 0,
    exportchannelonfinishedenabled boolean DEFAULT false NOT NULL,
    categorizechannelenabled boolean DEFAULT false,
    categoryname character varying(65535) DEFAULT ''::text,
    concatenatedbroadcastchannelids character varying(65535),
    channelidtorootid character varying(65535) DEFAULT ''::text,
    remindertimerdefaultseconds bigint DEFAULT 0 NOT NULL,
    statusupdateenabled boolean DEFAULT true,
    retrospectiveenabled boolean DEFAULT true,
    statusupdatebroadcastchannelsenabled boolean DEFAULT false,
    statusupdatebroadcastwebhooksenabled boolean DEFAULT false,
    summarymodifiedat bigint DEFAULT 0 NOT NULL,
    createchannelmemberonnewparticipant boolean DEFAULT true,
    removechannelmemberonremovedparticipant boolean DEFAULT true,
    runtype character varying(32) DEFAULT 'playbook'::character varying
);


--
-- TOC entry 294 (class 1259 OID 17658)
-- Name: ir_metric; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_metric (
    incidentid character varying(26) NOT NULL,
    metricconfigid character varying(26) NOT NULL,
    value bigint,
    published boolean NOT NULL
);


--
-- TOC entry 293 (class 1259 OID 17642)
-- Name: ir_metricconfig; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_metricconfig (
    id character varying(26) NOT NULL,
    playbookid character varying(26) NOT NULL,
    title character varying(512) NOT NULL,
    description character varying(4096) NOT NULL,
    type character varying(32) NOT NULL,
    target bigint,
    ordering smallint DEFAULT 0 NOT NULL,
    deleteat bigint DEFAULT 0 NOT NULL
);


--
-- TOC entry 280 (class 1259 OID 17428)
-- Name: ir_playbook; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_playbook (
    id character varying(26) NOT NULL,
    title character varying(1024) NOT NULL,
    description character varying(4096) NOT NULL,
    teamid character varying(26) NOT NULL,
    createpublicincident boolean NOT NULL,
    createat bigint NOT NULL,
    deleteat bigint DEFAULT 0 NOT NULL,
    checklistsjson json NOT NULL,
    numstages bigint DEFAULT 0 NOT NULL,
    numsteps bigint DEFAULT 0 NOT NULL,
    broadcastchannelid character varying(26) DEFAULT ''::text,
    remindermessagetemplate character varying(65535) DEFAULT ''::text,
    remindertimerdefaultseconds bigint DEFAULT 0 NOT NULL,
    concatenatedinviteduserids character varying(65535) DEFAULT ''::text,
    inviteusersenabled boolean DEFAULT false,
    defaultcommanderid character varying(26) DEFAULT ''::text,
    defaultcommanderenabled boolean DEFAULT false,
    announcementchannelid character varying(26) DEFAULT ''::text,
    announcementchannelenabled boolean DEFAULT false,
    concatenatedwebhookoncreationurls character varying(65535) DEFAULT ''::text,
    webhookoncreationenabled boolean DEFAULT false,
    concatenatedinvitedgroupids character varying(65535) DEFAULT ''::text,
    messageonjoin character varying(65535) DEFAULT ''::text,
    messageonjoinenabled boolean DEFAULT false,
    retrospectivereminderintervalseconds bigint DEFAULT 0 NOT NULL,
    retrospectivetemplate character varying(65535),
    concatenatedwebhookonstatusupdateurls character varying(65535) DEFAULT ''::text,
    webhookonstatusupdateenabled boolean DEFAULT false,
    concatenatedsignalanykeywords character varying(65535) DEFAULT ''::text,
    signalanykeywordsenabled boolean DEFAULT false,
    updateat bigint DEFAULT 0 NOT NULL,
    exportchannelonfinishedenabled boolean DEFAULT false NOT NULL,
    categorizechannelenabled boolean DEFAULT false,
    categoryname character varying(65535) DEFAULT ''::text,
    concatenatedbroadcastchannelids character varying(65535),
    broadcastenabled boolean DEFAULT false,
    runsummarytemplate character varying(65535) DEFAULT ''::text,
    channelnametemplate character varying(65535) DEFAULT ''::text,
    statusupdateenabled boolean DEFAULT true,
    retrospectiveenabled boolean DEFAULT true,
    public boolean DEFAULT false,
    runsummarytemplateenabled boolean DEFAULT true,
    createchannelmemberonnewparticipant boolean DEFAULT true,
    removechannelmemberonremovedparticipant boolean DEFAULT true,
    channelid character varying(26) DEFAULT ''::character varying,
    channelmode character varying(32) DEFAULT 'create_new_channel'::character varying
);


--
-- TOC entry 292 (class 1259 OID 17622)
-- Name: ir_playbookautofollow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_playbookautofollow (
    playbookid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL
);


--
-- TOC entry 281 (class 1259 OID 17439)
-- Name: ir_playbookmember; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_playbookmember (
    playbookid character varying(26) NOT NULL,
    memberid character varying(26) NOT NULL,
    roles character varying(65535)
);


--
-- TOC entry 291 (class 1259 OID 17606)
-- Name: ir_run_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_run_participants (
    userid character varying(26) NOT NULL,
    incidentid character varying(26) NOT NULL,
    isfollower boolean DEFAULT false NOT NULL,
    isparticipant boolean DEFAULT false
);


--
-- TOC entry 282 (class 1259 OID 17459)
-- Name: ir_statusposts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_statusposts (
    incidentid character varying(26) NOT NULL,
    postid character varying(26) NOT NULL
);


--
-- TOC entry 278 (class 1259 OID 17406)
-- Name: ir_system; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_system (
    skey character varying(64) NOT NULL,
    svalue character varying(1024)
);


--
-- TOC entry 285 (class 1259 OID 17491)
-- Name: ir_timelineevent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_timelineevent (
    id character varying(26) NOT NULL,
    incidentid character varying(26) NOT NULL,
    createat bigint NOT NULL,
    deleteat bigint DEFAULT 0 NOT NULL,
    eventat bigint NOT NULL,
    eventtype character varying(32) DEFAULT ''::text NOT NULL,
    summary character varying(256) DEFAULT ''::text NOT NULL,
    details character varying(4096) DEFAULT ''::text NOT NULL,
    postid character varying(26) DEFAULT ''::text NOT NULL,
    subjectuserid character varying(26) DEFAULT ''::text NOT NULL,
    creatoruserid character varying(26) DEFAULT ''::text NOT NULL
);


--
-- TOC entry 290 (class 1259 OID 17598)
-- Name: ir_userinfo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_userinfo (
    id character varying(26) NOT NULL,
    lastdailytododmat bigint,
    digestnotificationsettingsjson json
);


--
-- TOC entry 289 (class 1259 OID 17559)
-- Name: ir_viewedchannel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ir_viewedchannel (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL
);


--
-- TOC entry 239 (class 1259 OID 16739)
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id character varying(26) NOT NULL,
    type character varying(32),
    priority bigint,
    createat bigint,
    startat bigint,
    lastactivityat bigint,
    status character varying(32),
    progress bigint,
    data jsonb
);


--
-- TOC entry 220 (class 1259 OID 16568)
-- Name: licenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.licenses (
    id character varying(26) NOT NULL,
    createat bigint,
    bytes character varying(10000)
);


--
-- TOC entry 212 (class 1259 OID 16486)
-- Name: linkmetadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linkmetadata (
    hash bigint NOT NULL,
    url character varying(2048),
    "timestamp" bigint,
    type character varying(16),
    data jsonb
);


--
-- TOC entry 258 (class 1259 OID 17158)
-- Name: notifyadmin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifyadmin (
    userid character varying(26) NOT NULL,
    createat bigint,
    requiredplan character varying(100) NOT NULL,
    requiredfeature character varying(255) NOT NULL,
    trial boolean NOT NULL,
    sentat bigint
);


--
-- TOC entry 226 (class 1259 OID 16631)
-- Name: oauthaccessdata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauthaccessdata (
    token character varying(26) NOT NULL,
    refreshtoken character varying(26),
    redirecturi character varying(256),
    clientid character varying(26),
    userid character varying(26),
    expiresat bigint,
    scope character varying(128)
);


--
-- TOC entry 249 (class 1259 OID 16845)
-- Name: oauthapps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauthapps (
    id character varying(26) NOT NULL,
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    clientsecret character varying(128),
    name character varying(64),
    description character varying(512),
    callbackurls character varying(1024),
    homepage character varying(256),
    istrusted boolean,
    iconurl character varying(512),
    mattermostappid character varying(32) DEFAULT ''::character varying NOT NULL
);


--
-- TOC entry 235 (class 1259 OID 16709)
-- Name: oauthauthdata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauthauthdata (
    clientid character varying(26),
    userid character varying(26),
    code character varying(128) NOT NULL,
    expiresin integer,
    createat bigint,
    redirecturi character varying(256),
    state character varying(1024),
    scope character varying(128)
);


--
-- TOC entry 266 (class 1259 OID 17223)
-- Name: outgoingoauthconnections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outgoingoauthconnections (
    id character varying(26) NOT NULL,
    name character varying(64),
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    clientid character varying(255),
    clientsecret character varying(255),
    credentialsusername character varying(255),
    credentialspassword character varying(255),
    oauthtokenurl text,
    granttype public.outgoingoauthconnections_granttype DEFAULT 'client_credentials'::public.outgoingoauthconnections_granttype,
    audiences character varying(1024)
);


--
-- TOC entry 215 (class 1259 OID 16520)
-- Name: outgoingwebhooks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outgoingwebhooks (
    id character varying(26) NOT NULL,
    token character varying(26),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    creatorid character varying(26),
    channelid character varying(26),
    teamid character varying(26),
    triggerwords character varying(1024),
    callbackurls character varying(1024),
    displayname character varying(64),
    contenttype character varying(128),
    triggerwhen integer,
    username character varying(64),
    iconurl character varying(1024),
    description character varying(500)
);


--
-- TOC entry 262 (class 1259 OID 17193)
-- Name: persistentnotifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.persistentnotifications (
    postid character varying(26) NOT NULL,
    createat bigint,
    lastsentat bigint,
    deleteat bigint,
    sentcount smallint
);


--
-- TOC entry 246 (class 1259 OID 16793)
-- Name: pluginkeyvaluestore; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pluginkeyvaluestore (
    pluginid character varying(190) NOT NULL,
    pkey character varying(150) NOT NULL,
    pvalue bytea,
    expireat bigint
);


--
-- TOC entry 260 (class 1259 OID 17168)
-- Name: postacknowledgements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postacknowledgements (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    acknowledgedat bigint
);


--
-- TOC entry 257 (class 1259 OID 17150)
-- Name: postreminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postreminders (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    targettime bigint
);


--
-- TOC entry 272 (class 1259 OID 17316)
-- Name: posts_by_team_day; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.posts_by_team_day AS
 SELECT (to_timestamp(((p.createat / 1000))::double precision))::date AS day,
    count(*) AS num,
    c.teamid
   FROM (public.posts p
     JOIN public.channels c ON (((p.channelid)::text = (c.id)::text)))
  GROUP BY ((to_timestamp(((p.createat / 1000))::double precision))::date), c.teamid
  WITH NO DATA;


--
-- TOC entry 259 (class 1259 OID 17163)
-- Name: postspriority; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postspriority (
    postid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    priority character varying(32) NOT NULL,
    requestedack boolean,
    persistentnotifications boolean
);


--
-- TOC entry 265 (class 1259 OID 17214)
-- Name: poststats; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.poststats AS
 SELECT posts.userid,
    (to_timestamp(((posts.createat / 1000))::double precision))::date AS day,
    count(*) AS numposts,
    max(posts.createat) AS lastpostdate
   FROM public.posts
  GROUP BY posts.userid, ((to_timestamp(((posts.createat / 1000))::double precision))::date)
  WITH NO DATA;


--
-- TOC entry 227 (class 1259 OID 16640)
-- Name: preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preferences (
    userid character varying(26) NOT NULL,
    category character varying(32) NOT NULL,
    name character varying(32) NOT NULL,
    value text
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


--
-- TOC entry 222 (class 1259 OID 16594)
-- Name: productnoticeviewstate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.productnoticeviewstate (
    userid character varying(26) NOT NULL,
    noticeid character varying(26) NOT NULL,
    viewed integer,
    "timestamp" bigint
);


--
-- TOC entry 269 (class 1259 OID 17276)
-- Name: propertygroups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.propertygroups (
    id character varying(26) NOT NULL,
    name character varying(64) NOT NULL
);


--
-- TOC entry 252 (class 1259 OID 16885)
-- Name: publicchannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicchannels (
    id character varying(26) NOT NULL,
    deleteat bigint,
    teamid character varying(26),
    displayname character varying(64),
    name character varying(64),
    header character varying(1024),
    purpose character varying(250)
);


--
-- TOC entry 217 (class 1259 OID 16540)
-- Name: reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reactions (
    userid character varying(26) NOT NULL,
    postid character varying(26) NOT NULL,
    emojiname character varying(64) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    remoteid character varying(26),
    channelid character varying(26) DEFAULT ''::character varying NOT NULL
);


--
-- TOC entry 256 (class 1259 OID 17075)
-- Name: recentsearches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recentsearches (
    userid character(26) NOT NULL,
    searchpointer integer NOT NULL,
    query jsonb,
    createat bigint NOT NULL
);


--
-- TOC entry 232 (class 1259 OID 16683)
-- Name: remoteclusters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.remoteclusters (
    remoteid character varying(26) NOT NULL,
    remoteteamid character varying(26),
    name character varying(64) NOT NULL,
    displayname character varying(64),
    siteurl character varying(512),
    createat bigint,
    lastpingat bigint,
    token character varying(26),
    remotetoken character varying(26),
    topics character varying(512),
    creatorid character varying(26),
    pluginid character varying(190) DEFAULT ''::character varying NOT NULL,
    options smallint DEFAULT 0 NOT NULL,
    defaultteamid character varying(26) DEFAULT ''::character varying,
    deleteat bigint DEFAULT 0
);


--
-- TOC entry 264 (class 1259 OID 17204)
-- Name: retentionidsfordeletion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retentionidsfordeletion (
    id character varying(26) NOT NULL,
    tablename character varying(64),
    ids character varying(26)[]
);


--
-- TOC entry 253 (class 1259 OID 16901)
-- Name: retentionpolicies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retentionpolicies (
    id character varying(26) NOT NULL,
    displayname character varying(64),
    postduration bigint
);


--
-- TOC entry 255 (class 1259 OID 16911)
-- Name: retentionpolicieschannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retentionpolicieschannels (
    policyid character varying(26),
    channelid character varying(26) NOT NULL
);


--
-- TOC entry 254 (class 1259 OID 16906)
-- Name: retentionpoliciesteams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.retentionpoliciesteams (
    policyid character varying(26),
    teamid character varying(26) NOT NULL
);


--
-- TOC entry 218 (class 1259 OID 16545)
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id character varying(26) NOT NULL,
    name character varying(64),
    displayname character varying(128),
    description character varying(1024),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    permissions text,
    schememanaged boolean,
    builtin boolean
);


--
-- TOC entry 268 (class 1259 OID 17267)
-- Name: scheduledposts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduledposts (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    userid character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    rootid character varying(26),
    message character varying(65535),
    props character varying(8000),
    fileids character varying(300),
    priority text,
    scheduledat bigint NOT NULL,
    processedat bigint,
    errorcode character varying(200)
);


--
-- TOC entry 219 (class 1259 OID 16555)
-- Name: schemes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schemes (
    id character varying(26) NOT NULL,
    name character varying(64),
    displayname character varying(128),
    description character varying(1024),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    scope character varying(32),
    defaultteamadminrole character varying(64),
    defaultteamuserrole character varying(64),
    defaultchanneladminrole character varying(64),
    defaultchanneluserrole character varying(64),
    defaultteamguestrole character varying(64),
    defaultchannelguestrole character varying(64),
    defaultplaybookadminrole character varying(64) DEFAULT ''::character varying,
    defaultplaybookmemberrole character varying(64) DEFAULT ''::character varying,
    defaultrunadminrole character varying(64) DEFAULT ''::character varying,
    defaultrunmemberrole character varying(64) DEFAULT ''::character varying
);


--
-- TOC entry 223 (class 1259 OID 16601)
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(26) NOT NULL,
    token character varying(26),
    createat bigint,
    expiresat bigint,
    lastactivityat bigint,
    userid character varying(26),
    deviceid character varying(512),
    roles character varying(256),
    isoauth boolean,
    props jsonb,
    expirednotify boolean
);


--
-- TOC entry 236 (class 1259 OID 16717)
-- Name: sharedchannelattachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sharedchannelattachments (
    id character varying(26) NOT NULL,
    fileid character varying(26),
    remoteid character varying(26),
    createat bigint,
    lastsyncat bigint
);


--
-- TOC entry 238 (class 1259 OID 16732)
-- Name: sharedchannelremotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sharedchannelremotes (
    id character varying(26) NOT NULL,
    channelid character varying(26) NOT NULL,
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    isinviteaccepted boolean,
    isinviteconfirmed boolean,
    remoteid character varying(26),
    lastpostupdateat bigint,
    lastpostid character varying(26),
    lastpostcreateat bigint DEFAULT 0 NOT NULL,
    lastpostcreateid character varying(26),
    deleteat bigint DEFAULT 0
);


--
-- TOC entry 233 (class 1259 OID 16692)
-- Name: sharedchannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sharedchannels (
    channelid character varying(26) NOT NULL,
    teamid character varying(26),
    home boolean,
    readonly boolean,
    sharename character varying(64),
    sharedisplayname character varying(64),
    sharepurpose character varying(250),
    shareheader character varying(1024),
    creatorid character varying(26),
    createat bigint,
    updateat bigint,
    remoteid character varying(26)
);


--
-- TOC entry 237 (class 1259 OID 16724)
-- Name: sharedchannelusers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sharedchannelusers (
    id character varying(26) NOT NULL,
    userid character varying(26),
    remoteid character varying(26),
    createat bigint,
    lastsyncat bigint,
    channelid character varying(26)
);


--
-- TOC entry 241 (class 1259 OID 16753)
-- Name: sidebarcategories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sidebarcategories (
    id character varying(128) NOT NULL,
    userid character varying(26),
    teamid character varying(26),
    sortorder bigint,
    sorting character varying(64),
    type character varying(64),
    displayname character varying(64),
    muted boolean,
    collapsed boolean
);


--
-- TOC entry 234 (class 1259 OID 16702)
-- Name: sidebarchannels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sidebarchannels (
    channelid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    categoryid character varying(128) NOT NULL,
    sortorder bigint
);


--
-- TOC entry 228 (class 1259 OID 16650)
-- Name: status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.status (
    userid character varying(26) NOT NULL,
    status character varying(32),
    manual boolean,
    lastactivityat bigint,
    dndendtime bigint,
    prevstatus character varying(32)
);


--
-- TOC entry 216 (class 1259 OID 16532)
-- Name: systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.systems (
    name character varying(64) NOT NULL,
    value character varying(1024)
);


--
-- TOC entry 203 (class 1259 OID 16414)
-- Name: teammembers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teammembers (
    teamid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    roles character varying(256),
    deleteat bigint,
    schemeuser boolean,
    schemeadmin boolean,
    schemeguest boolean,
    createat bigint DEFAULT 0
);


--
-- TOC entry 202 (class 1259 OID 16398)
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    displayname character varying(64),
    name character varying(64),
    description character varying(255),
    email character varying(128),
    type public.team_type,
    companyname character varying(64),
    alloweddomains character varying(1000),
    inviteid character varying(32),
    schemeid character varying(26),
    allowopeninvite boolean,
    lastteamiconupdate bigint,
    groupconstrained boolean,
    cloudlimitsarchived boolean DEFAULT false NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 16614)
-- Name: termsofservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.termsofservice (
    id character varying(26) NOT NULL,
    createat bigint,
    userid character varying(26),
    text character varying(65535)
);


--
-- TOC entry 244 (class 1259 OID 16780)
-- Name: threadmemberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.threadmemberships (
    postid character varying(26) NOT NULL,
    userid character varying(26) NOT NULL,
    following boolean,
    lastviewed bigint,
    lastupdated bigint,
    unreadmentions bigint
)
WITH (autovacuum_vacuum_scale_factor='0.1', autovacuum_analyze_scale_factor='0.05');


--
-- TOC entry 243 (class 1259 OID 16771)
-- Name: threads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.threads (
    postid character varying(26) NOT NULL,
    replycount bigint,
    lastreplyat bigint,
    participants jsonb,
    channelid character varying(26),
    threaddeleteat bigint,
    threadteamid character varying(26)
);


--
-- TOC entry 229 (class 1259 OID 16656)
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    token character varying(64) NOT NULL,
    createat bigint,
    type character varying(64),
    extra character varying(2048)
);


--
-- TOC entry 242 (class 1259 OID 16760)
-- Name: uploadsessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploadsessions (
    id character varying(26) NOT NULL,
    type public.upload_session_type,
    createat bigint,
    userid character varying(26),
    channelid character varying(26),
    filename character varying(256),
    path character varying(512),
    filesize bigint,
    fileoffset bigint,
    remoteid character varying(26),
    reqfileid character varying(26)
);


--
-- TOC entry 231 (class 1259 OID 16672)
-- Name: useraccesstokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.useraccesstokens (
    id character varying(26) NOT NULL,
    token character varying(26),
    userid character varying(26),
    description character varying(512),
    isactive boolean
);


--
-- TOC entry 208 (class 1259 OID 16453)
-- Name: usergroups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usergroups (
    id character varying(26) NOT NULL,
    name character varying(64),
    displayname character varying(128),
    description character varying(1024),
    source character varying(64),
    remoteid character varying(48),
    createat bigint,
    updateat bigint,
    deleteat bigint,
    allowreference boolean
);


--
-- TOC entry 247 (class 1259 OID 16802)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id character varying(26) NOT NULL,
    createat bigint,
    updateat bigint,
    deleteat bigint,
    username character varying(64),
    password character varying(128),
    authdata character varying(128),
    authservice character varying(32),
    email character varying(128),
    emailverified boolean,
    nickname character varying(64),
    firstname character varying(64),
    lastname character varying(64),
    roles character varying(256),
    allowmarketing boolean,
    props jsonb,
    notifyprops jsonb,
    lastpasswordupdate bigint,
    lastpictureupdate bigint,
    failedattempts integer,
    locale character varying(5),
    mfaactive boolean,
    mfasecret character varying(128),
    "position" character varying(128),
    timezone jsonb,
    remoteid character varying(26),
    lastlogin bigint DEFAULT 0 NOT NULL,
    mfausedtimestamps jsonb
);


--
-- TOC entry 245 (class 1259 OID 16788)
-- Name: usertermsofservice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usertermsofservice (
    userid character varying(26) NOT NULL,
    termsofserviceid character varying(26),
    createat bigint
);


--
-- TOC entry 4118 (class 0 OID 17335)
-- Dependencies: 275
-- Data for Name: accesscontrolpolicies; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4119 (class 0 OID 17343)
-- Dependencies: 276
-- Data for Name: accesscontrolpolicyhistory; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4068 (class 0 OID 16622)
-- Dependencies: 225
-- Data for Name: audits; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.audits VALUES ('c4rh76aiypbhxrewibrhu4qb3r', 1752630995181, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/login', 'attempt - login_id=', '192.168.143.2', '');
INSERT INTO public.audits VALUES ('ryhzoubti3na7qwqz53h59fz9c', 1752630995253, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/login', 'authenticated', '192.168.143.2', '');
INSERT INTO public.audits VALUES ('wu9m8xsisbdzbxycsunabmesgc', 1752630995284, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/login', 'success session_user=bdc3dd1mzjd888gwfyfoxb4zkw', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('6fsh85u6ffgsxxatbwehi8t7fy', 1752630995576, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/system/onboarding/complete', 'attempt', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('tdtzjpuewtfi7jxf3z66j7385r', 1752630995589, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/me/patch', '', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('6mzij477nfgh8jwfak4yz7y4mo', 1752631082436, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/hooks/incoming', 'attempt', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('a7u777o94ingxgxudapkdhhtwa', 1752631082458, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/hooks/incoming', 'success', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('d7qwfj5mqbrfzyy7pziof59wnc', 1752631105729, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/iyc3dqxk7bbimywg73cfgo15qo/image', '', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('65qkhm17nffs8g4z6ps361xqac', 1752631105742, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/iyc3dqxk7bbimywg73cfgo15qo/tokens', '', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('mgwgr1spi3bqzpqgmxkpda6ouo', 1752631105752, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/iyc3dqxk7bbimywg73cfgo15qo/tokens', 'success - token_id=duxpa3knwjy78rny3fxmnf8gza', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('mq57pncybtygbdpm7zokd6wd7o', 1752631105782, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/iyc3dqxk7bbimywg73cfgo15qo/roles', 'user=iyc3dqxk7bbimywg73cfgo15qo roles=system_user', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('bfrw3mpsbjrymct6bz4rur5r9r', 1752631134948, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/bdc3dd1mzjd888gwfyfoxb4zkw/tokens', '', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');
INSERT INTO public.audits VALUES ('m3n113m1kjdmipae5um554yqma', 1752631134965, 'bdc3dd1mzjd888gwfyfoxb4zkw', '/api/v4/users/bdc3dd1mzjd888gwfyfoxb4zkw/tokens', 'success - token_id=phiq5afi3jrybfk5pyaugfb3ww', '192.168.143.2', 'jy8g6mw6yjf4ten9b1xgu7psgw');


--
-- TOC entry 4073 (class 0 OID 16664)
-- Dependencies: 230
-- Data for Name: bots; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.bots VALUES ('7d7wpdcjubbgtktic4kim3zexo', 'Feedbackbot collects user feedback to improve Mattermost. [Learn more](https://mattermost.com/pl/default-nps).', 'com.mattermost.nps', 1752630851172, 1752630851172, 0, 0);
INSERT INTO public.bots VALUES ('yq4taxhkofgqmdmc3spxgwcdbo', 'Playbooks bot.', 'playbooks', 1752630851611, 1752630851611, 0, 0);
INSERT INTO public.bots VALUES ('pyc6o84getd87dpnarubd73cto', 'Calls Bot', 'com.mattermost.calls', 1752630852144, 1752630852144, 0, 0);
INSERT INTO public.bots VALUES ('iyc3dqxk7bbimywg73cfgo15qo', '', 'bdc3dd1mzjd888gwfyfoxb4zkw', 1752631105653, 1752631105653, 0, 0);
INSERT INTO public.bots VALUES ('9t3c85qk67dazmw7ssatfwgaxa', '', 'bdc3dd1mzjd888gwfyfoxb4zkw', 1752631200016, 1752631200016, 0, 0);


--
-- TOC entry 4129 (class 0 OID 17518)
-- Dependencies: 286
-- Data for Name: calls; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4127 (class 0 OID 17490)
-- Dependencies: 284
-- Data for Name: calls_channels; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4131 (class 0 OID 17549)
-- Dependencies: 288
-- Data for Name: calls_jobs; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4130 (class 0 OID 17535)
-- Dependencies: 287
-- Data for Name: calls_sessions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4110 (class 0 OID 17243)
-- Dependencies: 267
-- Data for Name: channelbookmarks; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4083 (class 0 OID 16748)
-- Dependencies: 240
-- Data for Name: channelmemberhistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.channelmemberhistory VALUES ('38qt17ckcffktjh9czdffytp8r', 'bdc3dd1mzjd888gwfyfoxb4zkw', 1752631000307, NULL);
INSERT INTO public.channelmemberhistory VALUES ('6m4kqf36bprf5dkb458nhk6fne', 'bdc3dd1mzjd888gwfyfoxb4zkw', 1752631000372, NULL);
INSERT INTO public.channelmemberhistory VALUES ('ndftxtgu5tgoxpft97k4jxmz1y', 'iyc3dqxk7bbimywg73cfgo15qo', 1752631105672, NULL);
INSERT INTO public.channelmemberhistory VALUES ('ndftxtgu5tgoxpft97k4jxmz1y', 'bdc3dd1mzjd888gwfyfoxb4zkw', 1752631105675, NULL);


--
-- TOC entry 4094 (class 0 OID 16876)
-- Dependencies: 251
-- Data for Name: channelmembers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.channelmembers VALUES ('38qt17ckcffktjh9czdffytp8r', 'bdc3dd1mzjd888gwfyfoxb4zkw', '', 0, 0, 0, '{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}', 1752631000297, true, true, false, 0, 0, 0);
INSERT INTO public.channelmembers VALUES ('6m4kqf36bprf5dkb458nhk6fne', 'bdc3dd1mzjd888gwfyfoxb4zkw', '', 0, 0, 0, '{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}', 1752631000357, true, true, false, 0, 0, 0);
INSERT INTO public.channelmembers VALUES ('ndftxtgu5tgoxpft97k4jxmz1y', 'iyc3dqxk7bbimywg73cfgo15qo', '', 0, 0, 0, '{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}', 1752631105661, true, false, false, 0, 0, 0);
INSERT INTO public.channelmembers VALUES ('ndftxtgu5tgoxpft97k4jxmz1y', 'bdc3dd1mzjd888gwfyfoxb4zkw', '', 1752631105679, 1, 0, '{"push": "default", "email": "default", "desktop": "default", "mark_unread": "all", "ignore_channel_mentions": "default", "channel_auto_follow_threads": "off"}', 1752631105679, true, false, false, 0, 1, 0);


--
-- TOC entry 4093 (class 0 OID 16854)
-- Dependencies: 250
-- Data for Name: channels; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.channels VALUES ('38qt17ckcffktjh9czdffytp8r', 1752631000207, 1752631000207, 0, 'xjxaqwfdm3rgtjry53iqr6r4pe', 'O', 'Town Square', 'town-square', '', '', 1752631000314, 0, 0, '', NULL, NULL, NULL, 0, 1752631000314, NULL);
INSERT INTO public.channels VALUES ('6m4kqf36bprf5dkb458nhk6fne', 1752631000239, 1752631000239, 0, 'xjxaqwfdm3rgtjry53iqr6r4pe', 'O', 'Off-Topic', 'off-topic', '', '', 1752631000377, 0, 0, '', NULL, NULL, NULL, 0, 1752631000377, NULL);
INSERT INTO public.channels VALUES ('ndftxtgu5tgoxpft97k4jxmz1y', 1752631105660, 1752631105660, 0, '', 'D', '', 'bdc3dd1mzjd888gwfyfoxb4zkw__iyc3dqxk7bbimywg73cfgo15qo', '', '', 1752631105679, 1, 0, 'iyc3dqxk7bbimywg73cfgo15qo', NULL, NULL, false, 1, 1752631105679, NULL);


--
-- TOC entry 4047 (class 0 OID 16421)
-- Dependencies: 204
-- Data for Name: clusterdiscovery; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4056 (class 0 OID 16495)
-- Dependencies: 213
-- Data for Name: commands; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4048 (class 0 OID 16429)
-- Dependencies: 205
-- Data for Name: commandwebhooks; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4049 (class 0 OID 16435)
-- Dependencies: 206
-- Data for Name: compliances; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4043 (class 0 OID 16385)
-- Dependencies: 200
-- Data for Name: db_lock; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4044 (class 0 OID 16390)
-- Dependencies: 201
-- Data for Name: db_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.db_migrations VALUES (1, 'create_teams');
INSERT INTO public.db_migrations VALUES (2, 'create_team_members');
INSERT INTO public.db_migrations VALUES (3, 'create_cluster_discovery');
INSERT INTO public.db_migrations VALUES (4, 'create_command_webhooks');
INSERT INTO public.db_migrations VALUES (5, 'create_compliances');
INSERT INTO public.db_migrations VALUES (6, 'create_emojis');
INSERT INTO public.db_migrations VALUES (7, 'create_user_groups');
INSERT INTO public.db_migrations VALUES (8, 'create_group_members');
INSERT INTO public.db_migrations VALUES (9, 'create_group_teams');
INSERT INTO public.db_migrations VALUES (10, 'create_group_channels');
INSERT INTO public.db_migrations VALUES (11, 'create_link_metadata');
INSERT INTO public.db_migrations VALUES (12, 'create_commands');
INSERT INTO public.db_migrations VALUES (13, 'create_incoming_webhooks');
INSERT INTO public.db_migrations VALUES (14, 'create_outgoing_webhooks');
INSERT INTO public.db_migrations VALUES (15, 'create_systems');
INSERT INTO public.db_migrations VALUES (16, 'create_reactions');
INSERT INTO public.db_migrations VALUES (17, 'create_roles');
INSERT INTO public.db_migrations VALUES (18, 'create_schemes');
INSERT INTO public.db_migrations VALUES (19, 'create_licenses');
INSERT INTO public.db_migrations VALUES (20, 'create_posts');
INSERT INTO public.db_migrations VALUES (21, 'create_product_notice_view_state');
INSERT INTO public.db_migrations VALUES (22, 'create_sessions');
INSERT INTO public.db_migrations VALUES (23, 'create_terms_of_service');
INSERT INTO public.db_migrations VALUES (24, 'create_audits');
INSERT INTO public.db_migrations VALUES (25, 'create_oauth_access_data');
INSERT INTO public.db_migrations VALUES (26, 'create_preferences');
INSERT INTO public.db_migrations VALUES (27, 'create_status');
INSERT INTO public.db_migrations VALUES (28, 'create_tokens');
INSERT INTO public.db_migrations VALUES (29, 'create_bots');
INSERT INTO public.db_migrations VALUES (30, 'create_user_access_tokens');
INSERT INTO public.db_migrations VALUES (31, 'create_remote_clusters');
INSERT INTO public.db_migrations VALUES (32, 'create_sharedchannels');
INSERT INTO public.db_migrations VALUES (33, 'create_sidebar_channels');
INSERT INTO public.db_migrations VALUES (34, 'create_oauthauthdata');
INSERT INTO public.db_migrations VALUES (35, 'create_sharedchannelattachments');
INSERT INTO public.db_migrations VALUES (36, 'create_sharedchannelusers');
INSERT INTO public.db_migrations VALUES (37, 'create_sharedchannelremotes');
INSERT INTO public.db_migrations VALUES (38, 'create_jobs');
INSERT INTO public.db_migrations VALUES (39, 'create_channel_member_history');
INSERT INTO public.db_migrations VALUES (40, 'create_sidebar_categories');
INSERT INTO public.db_migrations VALUES (41, 'create_upload_sessions');
INSERT INTO public.db_migrations VALUES (42, 'create_threads');
INSERT INTO public.db_migrations VALUES (43, 'thread_memberships');
INSERT INTO public.db_migrations VALUES (44, 'create_user_terms_of_service');
INSERT INTO public.db_migrations VALUES (45, 'create_plugin_key_value_store');
INSERT INTO public.db_migrations VALUES (46, 'create_users');
INSERT INTO public.db_migrations VALUES (47, 'create_file_info');
INSERT INTO public.db_migrations VALUES (48, 'create_oauth_apps');
INSERT INTO public.db_migrations VALUES (49, 'create_channels');
INSERT INTO public.db_migrations VALUES (50, 'create_channelmembers');
INSERT INTO public.db_migrations VALUES (51, 'create_msg_root_count');
INSERT INTO public.db_migrations VALUES (52, 'create_public_channels');
INSERT INTO public.db_migrations VALUES (53, 'create_retention_policies');
INSERT INTO public.db_migrations VALUES (54, 'create_crt_channelmembership_count');
INSERT INTO public.db_migrations VALUES (55, 'create_crt_thread_count_and_unreads');
INSERT INTO public.db_migrations VALUES (56, 'upgrade_channels_v6.0');
INSERT INTO public.db_migrations VALUES (57, 'upgrade_command_webhooks_v6.0');
INSERT INTO public.db_migrations VALUES (58, 'upgrade_channelmembers_v6.0');
INSERT INTO public.db_migrations VALUES (59, 'upgrade_users_v6.0');
INSERT INTO public.db_migrations VALUES (60, 'upgrade_jobs_v6.0');
INSERT INTO public.db_migrations VALUES (61, 'upgrade_link_metadata_v6.0');
INSERT INTO public.db_migrations VALUES (62, 'upgrade_sessions_v6.0');
INSERT INTO public.db_migrations VALUES (63, 'upgrade_threads_v6.0');
INSERT INTO public.db_migrations VALUES (64, 'upgrade_status_v6.0');
INSERT INTO public.db_migrations VALUES (65, 'upgrade_groupchannels_v6.0');
INSERT INTO public.db_migrations VALUES (66, 'upgrade_posts_v6.0');
INSERT INTO public.db_migrations VALUES (67, 'upgrade_channelmembers_v6.1');
INSERT INTO public.db_migrations VALUES (68, 'upgrade_teammembers_v6.1');
INSERT INTO public.db_migrations VALUES (69, 'upgrade_jobs_v6.1');
INSERT INTO public.db_migrations VALUES (70, 'upgrade_cte_v6.1');
INSERT INTO public.db_migrations VALUES (71, 'upgrade_sessions_v6.1');
INSERT INTO public.db_migrations VALUES (72, 'upgrade_schemes_v6.3');
INSERT INTO public.db_migrations VALUES (73, 'upgrade_plugin_key_value_store_v6.3');
INSERT INTO public.db_migrations VALUES (74, 'upgrade_users_v6.3');
INSERT INTO public.db_migrations VALUES (75, 'alter_upload_sessions_index');
INSERT INTO public.db_migrations VALUES (76, 'upgrade_lastrootpostat');
INSERT INTO public.db_migrations VALUES (77, 'upgrade_users_v6.5');
INSERT INTO public.db_migrations VALUES (78, 'create_oauth_mattermost_app_id');
INSERT INTO public.db_migrations VALUES (79, 'usergroups_displayname_index');
INSERT INTO public.db_migrations VALUES (80, 'posts_createat_id');
INSERT INTO public.db_migrations VALUES (81, 'threads_deleteat');
INSERT INTO public.db_migrations VALUES (82, 'upgrade_oauth_mattermost_app_id');
INSERT INTO public.db_migrations VALUES (83, 'threads_threaddeleteat');
INSERT INTO public.db_migrations VALUES (84, 'recent_searches');
INSERT INTO public.db_migrations VALUES (85, 'fileinfo_add_archived_column');
INSERT INTO public.db_migrations VALUES (86, 'add_cloud_limits_archived');
INSERT INTO public.db_migrations VALUES (87, 'sidebar_categories_index');
INSERT INTO public.db_migrations VALUES (88, 'remaining_migrations');
INSERT INTO public.db_migrations VALUES (89, 'add-channelid-to-reaction');
INSERT INTO public.db_migrations VALUES (90, 'create_enums');
INSERT INTO public.db_migrations VALUES (91, 'create_post_reminder');
INSERT INTO public.db_migrations VALUES (92, 'add_createat_to_teamembers');
INSERT INTO public.db_migrations VALUES (93, 'notify_admin');
INSERT INTO public.db_migrations VALUES (94, 'threads_teamid');
INSERT INTO public.db_migrations VALUES (95, 'remove_posts_parentid');
INSERT INTO public.db_migrations VALUES (96, 'threads_threadteamid');
INSERT INTO public.db_migrations VALUES (97, 'create_posts_priority');
INSERT INTO public.db_migrations VALUES (98, 'create_post_acknowledgements');
INSERT INTO public.db_migrations VALUES (99, 'create_drafts');
INSERT INTO public.db_migrations VALUES (100, 'add_draft_priority_column');
INSERT INTO public.db_migrations VALUES (101, 'create_true_up_review_history');
INSERT INTO public.db_migrations VALUES (102, 'posts_originalid_index');
INSERT INTO public.db_migrations VALUES (103, 'add_sentat_to_notifyadmin');
INSERT INTO public.db_migrations VALUES (104, 'upgrade_notifyadmin');
INSERT INTO public.db_migrations VALUES (105, 'remove_tokens');
INSERT INTO public.db_migrations VALUES (106, 'fileinfo_channelid');
INSERT INTO public.db_migrations VALUES (107, 'threadmemberships_cleanup');
INSERT INTO public.db_migrations VALUES (108, 'remove_orphaned_oauth_preferences');
INSERT INTO public.db_migrations VALUES (109, 'create_persistent_notifications');
INSERT INTO public.db_migrations VALUES (111, 'update_vacuuming');
INSERT INTO public.db_migrations VALUES (112, 'rework_desktop_tokens');
INSERT INTO public.db_migrations VALUES (113, 'create_retentionidsfordeletion_table');
INSERT INTO public.db_migrations VALUES (114, 'sharedchannelremotes_drop_nextsyncat_description');
INSERT INTO public.db_migrations VALUES (115, 'user_reporting_changes');
INSERT INTO public.db_migrations VALUES (116, 'create_outgoing_oauth_connections');
INSERT INTO public.db_migrations VALUES (117, 'msteams_shared_channels');
INSERT INTO public.db_migrations VALUES (118, 'create_index_poststats');
INSERT INTO public.db_migrations VALUES (119, 'msteams_shared_channels_opts');
INSERT INTO public.db_migrations VALUES (120, 'create_channelbookmarks_table');
INSERT INTO public.db_migrations VALUES (121, 'remove_true_up_review_history');
INSERT INTO public.db_migrations VALUES (122, 'preferences_value_length');
INSERT INTO public.db_migrations VALUES (123, 'remove_upload_file_permission');
INSERT INTO public.db_migrations VALUES (124, 'remove_manage_team_permission');
INSERT INTO public.db_migrations VALUES (125, 'remoteclusters_add_default_team_id');
INSERT INTO public.db_migrations VALUES (126, 'sharedchannels_remotes_add_deleteat');
INSERT INTO public.db_migrations VALUES (127, 'add_mfa_used_ts_to_users');
INSERT INTO public.db_migrations VALUES (128, 'create_scheduled_posts');
INSERT INTO public.db_migrations VALUES (129, 'add_property_system_architecture');
INSERT INTO public.db_migrations VALUES (130, 'system_console_stats');
INSERT INTO public.db_migrations VALUES (131, 'create_index_pagination_on_property_values');
INSERT INTO public.db_migrations VALUES (132, 'create_index_pagination_on_property_fields');
INSERT INTO public.db_migrations VALUES (133, 'add_channel_banner_fields');
INSERT INTO public.db_migrations VALUES (134, 'create_access_control_policies');
INSERT INTO public.db_migrations VALUES (135, 'sidebarchannels_categoryid');
INSERT INTO public.db_migrations VALUES (136, 'create_attribute_view');
INSERT INTO public.db_migrations VALUES (137, 'update_attribute_view');


--
-- TOC entry 4126 (class 0 OID 17473)
-- Dependencies: 283
-- Data for Name: db_migrations_calls; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.db_migrations_calls VALUES (1, 'create_calls_channels');
INSERT INTO public.db_migrations_calls VALUES (2, 'create_calls');
INSERT INTO public.db_migrations_calls VALUES (3, 'create_calls_sessions');
INSERT INTO public.db_migrations_calls VALUES (4, 'create_calls_jobs');


--
-- TOC entry 4106 (class 0 OID 17198)
-- Dependencies: 263
-- Data for Name: desktoptokens; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4104 (class 0 OID 17173)
-- Dependencies: 261
-- Data for Name: drafts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4050 (class 0 OID 16443)
-- Dependencies: 207
-- Data for Name: emoji; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4091 (class 0 OID 16829)
-- Dependencies: 248
-- Data for Name: fileinfo; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4054 (class 0 OID 16480)
-- Dependencies: 211
-- Data for Name: groupchannels; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4052 (class 0 OID 16467)
-- Dependencies: 209
-- Data for Name: groupmembers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4053 (class 0 OID 16473)
-- Dependencies: 210
-- Data for Name: groupteams; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4057 (class 0 OID 16507)
-- Dependencies: 214
-- Data for Name: incomingwebhooks; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.incomingwebhooks VALUES ('r74rdb9eh7dbzqhrornxwgfdqo', 1752631082447, 1752631082447, 0, 'bdc3dd1mzjd888gwfyfoxb4zkw', '38qt17ckcffktjh9czdffytp8r', 'xjxaqwfdm3rgtjry53iqr6r4pe', 'Octopus-Ivy', '', '', '', true);


--
-- TOC entry 4139 (class 0 OID 17692)
-- Dependencies: 296
-- Data for Name: ir_category; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4140 (class 0 OID 17704)
-- Dependencies: 297
-- Data for Name: ir_category_item; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4138 (class 0 OID 17678)
-- Dependencies: 295
-- Data for Name: ir_channelaction; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4122 (class 0 OID 17414)
-- Dependencies: 279
-- Data for Name: ir_incident; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4137 (class 0 OID 17658)
-- Dependencies: 294
-- Data for Name: ir_metric; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4136 (class 0 OID 17642)
-- Dependencies: 293
-- Data for Name: ir_metricconfig; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4123 (class 0 OID 17428)
-- Dependencies: 280
-- Data for Name: ir_playbook; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4135 (class 0 OID 17622)
-- Dependencies: 292
-- Data for Name: ir_playbookautofollow; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4124 (class 0 OID 17439)
-- Dependencies: 281
-- Data for Name: ir_playbookmember; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4134 (class 0 OID 17606)
-- Dependencies: 291
-- Data for Name: ir_run_participants; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4125 (class 0 OID 17459)
-- Dependencies: 282
-- Data for Name: ir_statusposts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4121 (class 0 OID 17406)
-- Dependencies: 278
-- Data for Name: ir_system; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ir_system VALUES ('DatabaseVersion', '0.63.0');


--
-- TOC entry 4128 (class 0 OID 17491)
-- Dependencies: 285
-- Data for Name: ir_timelineevent; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4133 (class 0 OID 17598)
-- Dependencies: 290
-- Data for Name: ir_userinfo; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ir_userinfo VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 1752631005849, '{"disable_daily_digest":false,"disable_weekly_digest":false}');


--
-- TOC entry 4132 (class 0 OID 17559)
-- Dependencies: 289
-- Data for Name: ir_viewedchannel; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4082 (class 0 OID 16739)
-- Dependencies: 239
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.jobs VALUES ('whpz54c9y7dnmbfhis1in6stzw', 'delete_dms_preferences_migration', 0, 1752630850490, 1752630870621, 1752630871643, 'success', 100, '{}');
INSERT INTO public.jobs VALUES ('i8gpbm78epbojkdb1f93889yjc', 'delete_orphan_drafts_migration', 0, 1752630850487, 1752630870622, 1752630871657, 'success', 100, '{}');
INSERT INTO public.jobs VALUES ('yg3ozwi1zpd8pe4s86y44wuweo', 'delete_empty_drafts_migration', 0, 1752630850482, 1752630870621, 1752630871658, 'success', 100, '{}');
INSERT INTO public.jobs VALUES ('ibb3xz189f8fjdppyiyrcwju3h', 'migrations', 0, 1752630911673, 1752630915629, 1752630915857, 'success', 0, '{"last_done": "{\"current_table\":\"ChannelMembers\",\"last_team_id\":\"00000000000000000000000000\",\"last_channel_id\":\"00000000000000000000000000\",\"last_user\":\"00000000000000000000000000\"}", "migration_key": "migration_advanced_permissions_phase_2"}');


--
-- TOC entry 4063 (class 0 OID 16568)
-- Dependencies: 220
-- Data for Name: licenses; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4055 (class 0 OID 16486)
-- Dependencies: 212
-- Data for Name: linkmetadata; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4101 (class 0 OID 17158)
-- Dependencies: 258
-- Data for Name: notifyadmin; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4069 (class 0 OID 16631)
-- Dependencies: 226
-- Data for Name: oauthaccessdata; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4092 (class 0 OID 16845)
-- Dependencies: 249
-- Data for Name: oauthapps; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4078 (class 0 OID 16709)
-- Dependencies: 235
-- Data for Name: oauthauthdata; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4109 (class 0 OID 17223)
-- Dependencies: 266
-- Data for Name: outgoingoauthconnections; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4058 (class 0 OID 16520)
-- Dependencies: 215
-- Data for Name: outgoingwebhooks; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4105 (class 0 OID 17193)
-- Dependencies: 262
-- Data for Name: persistentnotifications; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4089 (class 0 OID 16793)
-- Dependencies: 246
-- Data for Name: pluginkeyvaluestore; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.pluginkeyvaluestore VALUES ('mattermost-ai', 'migrate_services_to_bots_done', '\x74727565', 0);
INSERT INTO public.pluginkeyvaluestore VALUES ('com.mattermost.nps', 'ServerUpgrade-10.9.0', '\x7b227365727665725f76657273696f6e223a2231302e392e30222c22757067726164655f6174223a22323032352d30372d31365430313a35343a31312e3230343337333939395a227d', 0);
INSERT INTO public.pluginkeyvaluestore VALUES ('com.mattermost.nps', 'WelcomeFeedbackMigration', '\x7b224372656174654174223a22323032352d30372d31365430313a35343a31312e3230343337333939395a227d', 0);
INSERT INTO public.pluginkeyvaluestore VALUES ('com.mattermost.nps', 'Survey-10.9.0', '\x7b227365727665725f76657273696f6e223a2231302e392e30222c226372656174655f6174223a22323032352d30372d31365430313a35343a31312e3230343337333939395a222c2273746172745f6174223a22323032352d30382d33305430313a35343a31312e3230343337333939395a227d', 0);
INSERT INTO public.pluginkeyvaluestore VALUES ('com.mattermost.nps', 'LastAdminNotice', '\x22323032352d30372d31365430313a35343a31312e3230343337333939395a22', 0);
INSERT INTO public.pluginkeyvaluestore VALUES ('playbooks', 'mmi_botid', '\x797134746178686b6f6667716d646d633373707867776364626f', 0);
INSERT INTO public.pluginkeyvaluestore VALUES ('com.mattermost.calls', 'mmi_botid', '\x707963366f383467657464383764706e6172756264373363746f', 0);


--
-- TOC entry 4103 (class 0 OID 17168)
-- Dependencies: 260
-- Data for Name: postacknowledgements; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4100 (class 0 OID 17150)
-- Dependencies: 257
-- Data for Name: postreminders; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4064 (class 0 OID 16576)
-- Dependencies: 221
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.posts VALUES ('c6e6grs8ufdfxydrx6bzmwp54c', 1752631000314, 1752631000314, 0, 'bdc3dd1mzjd888gwfyfoxb4zkw', '38qt17ckcffktjh9czdffytp8r', '', '', 'dino joined the team.', 'system_join_team', '{"username": "dino"}', '', '[]', '[]', false, 0, false, NULL);
INSERT INTO public.posts VALUES ('yo91o4nubpbjxy7x5xfa7747io', 1752631000377, 1752631000377, 0, 'bdc3dd1mzjd888gwfyfoxb4zkw', '6m4kqf36bprf5dkb458nhk6fne', '', '', 'dino joined the channel.', 'system_join_channel', '{"username": "dino"}', '', '[]', '[]', false, 0, false, NULL);
INSERT INTO public.posts VALUES ('ihzycrdto3yexdd5utxa91w5rw', 1752631105679, 1752631105679, 0, 'iyc3dqxk7bbimywg73cfgo15qo', 'ndftxtgu5tgoxpft97k4jxmz1y', '', '', 'Please add me to teams and channels you want me to interact in. To do this, use the browser or Mattermost Desktop App.', 'add_bot_teams_channels', '{"from_bot": "true"}', '', '[]', '[]', false, 0, false, NULL);


--
-- TOC entry 4102 (class 0 OID 17163)
-- Dependencies: 259
-- Data for Name: postspriority; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4070 (class 0 OID 16640)
-- Dependencies: 227
-- Data for Name: preferences; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.preferences VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'tutorial_step', 'bdc3dd1mzjd888gwfyfoxb4zkw', '0');
INSERT INTO public.preferences VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'system_notice', 'GMasDM', 'true');
INSERT INTO public.preferences VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'onboarding_task_list', 'onboarding_task_list_show', 'true');
INSERT INTO public.preferences VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'recommended_next_steps', 'hide', 'true');
INSERT INTO public.preferences VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'onboarding_task_list', 'onboarding_task_list_open', 'false');
INSERT INTO public.preferences VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'channel_approximate_view_time', '38qt17ckcffktjh9czdffytp8r', '1752631445258');
INSERT INTO public.preferences VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'direct_channel_show', 'iyc3dqxk7bbimywg73cfgo15qo', 'true');
INSERT INTO public.preferences VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'channel_open_time', 'ndftxtgu5tgoxpft97k4jxmz1y', '1752631630717');


--
-- TOC entry 4065 (class 0 OID 16594)
-- Dependencies: 222
-- Data for Name: productnoticeviewstate; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'gfycat_deprecation_7.8', 1, 1752630995);
INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'gif_deprecation_7.9_7.10', 1, 1752630995);
INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'gfycat_deprecation_8.0', 1, 1752630995);
INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'gfycat_deprecation_8.1', 1, 1752630995);
INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'server_upgrade_v10.9', 1, 1752630995);
INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'crt-admin-disabled', 1, 1752630995);
INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'crt-admin-default_off', 1, 1752630995);
INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'crt-user-default-on', 1, 1752630995);
INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'crt-user-always-on', 1, 1752630995);
INSERT INTO public.productnoticeviewstate VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'unsupported-server-v5.37', 1, 1752630995);


--
-- TOC entry 4113 (class 0 OID 17297)
-- Dependencies: 270
-- Data for Name: propertyfields; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4112 (class 0 OID 17276)
-- Dependencies: 269
-- Data for Name: propertygroups; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4114 (class 0 OID 17306)
-- Dependencies: 271
-- Data for Name: propertyvalues; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4095 (class 0 OID 16885)
-- Dependencies: 252
-- Data for Name: publicchannels; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.publicchannels VALUES ('38qt17ckcffktjh9czdffytp8r', 0, 'xjxaqwfdm3rgtjry53iqr6r4pe', 'Town Square', 'town-square', '', '');
INSERT INTO public.publicchannels VALUES ('6m4kqf36bprf5dkb458nhk6fne', 0, 'xjxaqwfdm3rgtjry53iqr6r4pe', 'Off-Topic', 'off-topic', '', '');


--
-- TOC entry 4060 (class 0 OID 16540)
-- Dependencies: 217
-- Data for Name: reactions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4099 (class 0 OID 17075)
-- Dependencies: 256
-- Data for Name: recentsearches; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4075 (class 0 OID 16683)
-- Dependencies: 232
-- Data for Name: remoteclusters; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4107 (class 0 OID 17204)
-- Dependencies: 264
-- Data for Name: retentionidsfordeletion; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4096 (class 0 OID 16901)
-- Dependencies: 253
-- Data for Name: retentionpolicies; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4098 (class 0 OID 16911)
-- Dependencies: 255
-- Data for Name: retentionpolicieschannels; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4097 (class 0 OID 16906)
-- Dependencies: 254
-- Data for Name: retentionpoliciesteams; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4061 (class 0 OID 16545)
-- Dependencies: 218
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.roles VALUES ('yftfkfpumbgy7q8tixcmdomd6a', 'team_post_all_public', 'authentication.roles.team_post_all_public.name', 'authentication.roles.team_post_all_public.description', 1752630848579, 1752630850440, 0, ' use_channel_mentions use_group_mentions create_post_public', false, true);
INSERT INTO public.roles VALUES ('yd1jpxucz3rn7mhxk6hb81tuoc', 'channel_user', 'authentication.roles.channel_user.name', 'authentication.roles.channel_user.description', 1752630848544, 1752630850426, 0, ' read_channel_content add_bookmark_private_channel create_post delete_public_channel read_private_channel_groups use_group_mentions manage_public_channel_properties edit_bookmark_public_channel manage_private_channel_properties use_channel_mentions edit_bookmark_private_channel delete_post get_public_link delete_bookmark_public_channel delete_private_channel delete_bookmark_private_channel edit_post remove_reaction order_bookmark_private_channel order_bookmark_public_channel manage_private_channel_members manage_public_channel_members upload_file add_bookmark_public_channel read_channel add_reaction read_public_channel_groups', true, true);
INSERT INTO public.roles VALUES ('54cfibsujtbxzd46km595ht47c', 'team_admin', 'authentication.roles.team_admin.name', 'authentication.roles.team_admin.description', 1752630848547, 1752630850428, 0, ' use_channel_mentions delete_bookmark_private_channel convert_public_channel_to_private convert_private_channel_to_public add_bookmark_public_channel manage_others_outgoing_webhooks manage_slash_commands manage_team_roles playbook_private_manage_roles edit_bookmark_private_channel playbook_public_manage_roles remove_reaction add_reaction manage_others_slash_commands delete_others_posts manage_private_channel_banner add_bookmark_private_channel order_bookmark_public_channel manage_team import_team manage_incoming_webhooks read_private_channel_groups order_bookmark_private_channel edit_bookmark_public_channel read_public_channel_groups manage_public_channel_members remove_user_from_team manage_others_incoming_webhooks delete_post use_group_mentions manage_channel_roles manage_public_channel_banner manage_outgoing_webhooks manage_private_channel_members upload_file delete_bookmark_public_channel create_post', true, true);
INSERT INTO public.roles VALUES ('5ux5jxkxstdsmbu5iuq86nph6c', 'playbook_member', 'authentication.roles.playbook_member.name', 'authentication.roles.playbook_member.description', 1752630848549, 1752630850430, 0, ' playbook_public_manage_properties playbook_private_view playbook_private_manage_members playbook_private_manage_properties run_create playbook_public_view playbook_public_manage_members', true, true);
INSERT INTO public.roles VALUES ('3cjy4psaff8idmes4zjddbkp1e', 'custom_group_user', 'authentication.roles.custom_group_user.name', 'authentication.roles.custom_group_user.description', 1752630848559, 1752630850432, 0, '', false, false);
INSERT INTO public.roles VALUES ('6s56884uepgfbce6sn5wkc3c4e', 'team_guest', 'authentication.roles.team_guest.name', 'authentication.roles.team_guest.description', 1752630848562, 1752630850433, 0, ' view_team', true, true);
INSERT INTO public.roles VALUES ('spcosx7nh7f8fxdtr8ffpb3fjy', 'playbook_admin', 'authentication.roles.playbook_admin.name', 'authentication.roles.playbook_admin.description', 1752630848582, 1752630850442, 0, ' playbook_public_manage_properties playbook_private_manage_members playbook_private_manage_roles playbook_private_manage_properties playbook_public_make_private playbook_public_manage_members playbook_public_manage_roles', true, true);
INSERT INTO public.roles VALUES ('9mec786g3pyrxqputwm4wjxawy', 'team_post_all', 'authentication.roles.team_post_all.name', 'authentication.roles.team_post_all.description', 1752630848564, 1752630850435, 0, ' use_group_mentions use_channel_mentions upload_file create_post', false, true);
INSERT INTO public.roles VALUES ('5mk1auew5bb4fb7wpmzrnme18y', 'system_user_access_token', 'authentication.roles.system_user_access_token.name', 'authentication.roles.system_user_access_token.description', 1752630848586, 1752630850443, 0, ' revoke_user_access_token create_user_access_token read_user_access_token', false, true);
INSERT INTO public.roles VALUES ('679ya5s45bg4xyse6cqy38okee', 'system_admin', 'authentication.roles.global_admin.name', 'authentication.roles.global_admin.description', 1752630848552, 1752630850445, 0, ' create_custom_group manage_public_channel_properties delete_public_channel edit_others_posts sysconsole_read_site_customization sysconsole_write_integrations_cors read_public_channel sysconsole_write_compliance_compliance_export manage_team_roles sysconsole_read_environment_push_notification_server read_audits create_ldap_sync_job read_ldap_sync_job sysconsole_read_environment_database manage_private_channel_properties read_jobs playbook_private_manage_members sysconsole_read_authentication_guest_access create_public_channel sysconsole_read_user_management_system_roles sysconsole_read_site_notifications recycle_database_connections sysconsole_read_site_localization manage_public_channel_members sysconsole_read_integrations_integration_management edit_brand read_bots edit_other_users manage_data_retention_job run_view edit_post manage_compliance_export_job playbook_public_manage_roles list_public_teams sysconsole_read_environment_session_lengths sysconsole_write_site_emoji join_public_channels sysconsole_write_about_edition_and_license sysconsole_read_integrations_cors create_bot join_private_teams sysconsole_write_compliance_compliance_monitoring use_slash_commands assign_system_admin_role sysconsole_write_environment_session_lengths sysconsole_write_integrations_integration_management sysconsole_write_authentication_saml list_team_channels sysconsole_read_integrations_gif add_ldap_private_cert sysconsole_read_authentication_mfa delete_others_emojis sysconsole_read_user_management_channels remove_ldap_private_cert test_elasticsearch playbook_public_manage_properties sysconsole_write_site_notifications read_elasticsearch_post_indexing_job sysconsole_read_site_posts manage_outgoing_webhooks invite_guest manage_private_channel_members sysconsole_read_compliance_compliance_monitoring sysconsole_write_integrations_bot_accounts create_post_ephemeral manage_others_slash_commands read_user_access_token test_site_url sysconsole_read_compliance_custom_terms_of_service read_compliance_export_job manage_shared_channels sysconsole_read_site_users_and_teams sysconsole_read_plugins sysconsole_write_environment_database add_saml_idp_cert manage_secure_connections promote_guest sysconsole_write_environment_file_storage sysconsole_read_user_management_groups manage_private_channel_banner manage_incoming_webhooks sysconsole_write_environment_elasticsearch get_saml_cert_status sysconsole_write_site_public_links order_bookmark_private_channel create_compliance_export_job add_bookmark_private_channel invite_user run_create create_private_channel invalidate_caches manage_others_incoming_webhooks edit_bookmark_public_channel get_analytics create_data_retention_job sysconsole_write_site_announcement_banner sysconsole_read_environment_logging sysconsole_read_products_boards sysconsole_read_about_edition_and_license sysconsole_write_site_file_sharing_and_downloads sysconsole_write_user_management_system_roles convert_public_channel_to_private sysconsole_write_environment_web_server sysconsole_read_compliance_compliance_export manage_elasticsearch_post_aggregation_job manage_jobs sysconsole_read_authentication_openid sysconsole_write_compliance_custom_terms_of_service manage_ldap_sync_job create_post sysconsole_read_reporting_site_statistics view_team sysconsole_read_experimental_features sysconsole_write_user_management_groups sysconsole_read_site_notices sysconsole_write_integrations_gif assign_bot test_email sysconsole_read_integrations_bot_accounts delete_bookmark_public_channel delete_bookmark_private_channel create_post_public sysconsole_read_authentication_email sysconsole_read_environment_high_availability sysconsole_read_site_emoji playbook_public_manage_members sysconsole_read_user_management_teams sysconsole_write_site_users_and_teams manage_channel_roles purge_bleve_indexes sysconsole_read_site_announcement_banner invalidate_email_invite read_channel read_channel_content read_other_users_teams create_direct_channel sysconsole_read_site_public_links sysconsole_read_authentication_saml run_manage_members sysconsole_write_reporting_team_statistics manage_elasticsearch_post_indexing_job delete_others_posts sysconsole_write_site_ip_filters remove_saml_private_cert download_compliance_export_result test_ldap add_saml_public_cert playbook_public_make_private sysconsole_read_environment_web_server import_team sysconsole_write_user_management_permissions sysconsole_read_authentication_ldap sysconsole_write_authentication_mfa sysconsole_read_user_management_users manage_system_wide_oauth create_post_bleve_indexes_job manage_license_information get_saml_metadata_from_idp use_channel_mentions sysconsole_write_compliance_data_retention_policy playbook_public_view demote_to_guest playbook_private_manage_properties remove_ldap_public_cert playbook_private_manage_roles manage_system sysconsole_read_environment_image_proxy delete_custom_group sysconsole_read_site_ip_filters restore_custom_group playbook_private_make_public sysconsole_write_authentication_openid playbook_private_create list_private_teams sysconsole_read_compliance_data_retention_policy order_bookmark_public_channel manage_slash_commands remove_user_from_team sysconsole_write_authentication_password add_reaction remove_others_reactions read_others_bots read_private_channel_groups sysconsole_write_authentication_ldap sysconsole_write_site_notices create_user_access_token sysconsole_write_environment_high_availability run_manage_properties read_elasticsearch_post_aggregation_job sysconsole_read_reporting_team_statistics sysconsole_read_experimental_feature_flags manage_team read_public_channel_groups sysconsole_read_environment_mobile_security manage_custom_group_members view_members playbook_public_create sysconsole_read_billing convert_private_channel_to_public sysconsole_read_authentication_password sysconsole_write_experimental_bleve upload_file manage_public_channel_banner sysconsole_write_experimental_features edit_bookmark_private_channel add_ldap_public_cert sysconsole_read_environment_elasticsearch add_saml_private_cert sysconsole_write_environment_image_proxy reload_config sysconsole_write_user_management_channels manage_outgoing_oauth_connections manage_bots sysconsole_write_reporting_site_statistics sysconsole_write_environment_mobile_security get_logs sysconsole_read_authentication_signup manage_roles sysconsole_write_billing sysconsole_write_site_customization read_deleted_posts use_group_mentions sysconsole_read_user_management_permissions add_bookmark_public_channel create_elasticsearch_post_aggregation_job remove_reaction playbook_private_view read_data_retention_job create_group_channel create_elasticsearch_post_indexing_job add_user_to_team sysconsole_write_environment_logging sysconsole_write_site_posts sysconsole_write_plugins manage_others_bots test_s3 manage_others_outgoing_webhooks sysconsole_read_environment_developer manage_post_bleve_indexes_job remove_saml_public_cert sysconsole_read_environment_smtp sysconsole_write_products_boards sysconsole_write_environment_performance_monitoring sysconsole_write_site_localization sysconsole_read_site_file_sharing_and_downloads sysconsole_write_experimental_feature_flags sysconsole_read_environment_file_storage sysconsole_write_environment_push_notification_server revoke_user_access_token sysconsole_write_environment_rate_limiting sysconsole_write_environment_smtp delete_private_channel sysconsole_read_experimental_bleve list_users_without_team create_emojis sysconsole_write_reporting_server_logs get_public_link delete_emojis sysconsole_read_environment_rate_limiting manage_oauth edit_custom_group sysconsole_write_user_management_teams sysconsole_write_authentication_signup join_public_teams purge_elasticsearch_indexes sysconsole_write_environment_developer sysconsole_read_environment_performance_monitoring sysconsole_write_user_management_users sysconsole_read_reporting_server_logs read_license_information create_team sysconsole_write_authentication_guest_access delete_post sysconsole_write_authentication_email remove_saml_idp_cert', true, true);
INSERT INTO public.roles VALUES ('t6cxmxa55tyf8ef4hpea7unnch', 'run_admin', 'authentication.roles.run_admin.name', 'authentication.roles.run_admin.description', 1752630848527, 1752630850420, 0, ' run_manage_properties run_manage_members', true, true);
INSERT INTO public.roles VALUES ('93crmp3sa3yxtqbw9bhqcpr4jw', 'channel_admin', 'authentication.roles.channel_admin.name', 'authentication.roles.channel_admin.description', 1752630848570, 1752630850439, 0, ' use_channel_mentions edit_bookmark_public_channel delete_bookmark_public_channel remove_reaction add_bookmark_private_channel add_bookmark_public_channel order_bookmark_public_channel manage_public_channel_members order_bookmark_private_channel read_public_channel_groups use_group_mentions manage_private_channel_banner read_private_channel_groups upload_file manage_private_channel_members create_post add_reaction edit_bookmark_private_channel delete_bookmark_private_channel manage_channel_roles manage_public_channel_banner', true, true);
INSERT INTO public.roles VALUES ('xwf6bj3ks7r3dyk981z6pzseja', 'system_guest', 'authentication.roles.global_guest.name', 'authentication.roles.global_guest.description', 1752630848534, 1752630850421, 0, ' create_group_channel create_direct_channel', true, true);
INSERT INTO public.roles VALUES ('1t8sx6hmain8db6jw586mr1hee', 'channel_guest', 'authentication.roles.channel_guest.name', 'authentication.roles.channel_guest.description', 1752630848542, 1752630850424, 0, ' remove_reaction edit_post create_post use_channel_mentions read_channel_content add_reaction upload_file read_channel', true, true);
INSERT INTO public.roles VALUES ('bq3tpkjfab8npbhoksf5qhrsxr', 'system_custom_group_admin', 'authentication.roles.system_custom_group_admin.name', 'authentication.roles.system_custom_group_admin.description', 1752630848597, 1752630850449, 0, ' delete_custom_group restore_custom_group manage_custom_group_members create_custom_group edit_custom_group', false, true);
INSERT INTO public.roles VALUES ('wk7kkq845iyz5kbsk7w5pedrne', 'team_user', 'authentication.roles.team_user.name', 'authentication.roles.team_user.description', 1752630848601, 1752630850451, 0, ' read_public_channel create_private_channel add_user_to_team create_public_channel view_team list_team_channels playbook_public_create invite_user join_public_channels playbook_private_create', true, true);
INSERT INTO public.roles VALUES ('4rzhq34oity8zf6htx57jpi9te', 'run_member', 'authentication.roles.run_member.name', 'authentication.roles.run_member.description', 1752630848604, 1752630850453, 0, ' run_view', true, true);
INSERT INTO public.roles VALUES ('358ag8kmwjbuzp8tt5p895w6dc', 'system_post_all', 'authentication.roles.system_post_all.name', 'authentication.roles.system_post_all.description', 1752630848606, 1752630850454, 0, ' upload_file create_post use_channel_mentions use_group_mentions', false, true);
INSERT INTO public.roles VALUES ('8fo78jbyajbr8g1id3m863w45r', 'system_post_all_public', 'authentication.roles.system_post_all_public.name', 'authentication.roles.system_post_all_public.description', 1752630848609, 1752630850456, 0, ' use_channel_mentions create_post_public use_group_mentions', false, true);
INSERT INTO public.roles VALUES ('cgmbt5gk5fbp9x88yfimhu6wyr', 'system_user', 'authentication.roles.global_user.name', 'authentication.roles.global_user.description', 1752630848537, 1752630850457, 0, ' create_group_channel restore_custom_group delete_emojis create_team view_members manage_custom_group_members join_public_teams create_custom_group create_direct_channel delete_custom_group list_public_teams edit_custom_group create_emojis', true, true);
INSERT INTO public.roles VALUES ('dyer5dhszb873et7hpjngh8huw', 'system_read_only_admin', 'authentication.roles.system_read_only_admin.name', 'authentication.roles.system_read_only_admin.description', 1752630848540, 1752630850423, 0, ' sysconsole_read_site_emoji sysconsole_read_site_users_and_teams sysconsole_read_environment_image_proxy sysconsole_read_site_posts sysconsole_read_environment_rate_limiting sysconsole_read_authentication_ldap sysconsole_read_environment_logging sysconsole_read_about_edition_and_license sysconsole_read_user_management_permissions read_audits sysconsole_read_experimental_bleve sysconsole_read_user_management_channels read_private_channel_groups download_compliance_export_result get_analytics read_ldap_sync_job sysconsole_read_authentication_openid sysconsole_read_authentication_mfa sysconsole_read_authentication_password sysconsole_read_site_file_sharing_and_downloads sysconsole_read_authentication_guest_access sysconsole_read_site_notifications read_public_channel sysconsole_read_user_management_groups sysconsole_read_compliance_data_retention_policy sysconsole_read_integrations_cors read_elasticsearch_post_indexing_job sysconsole_read_site_public_links sysconsole_read_environment_smtp sysconsole_read_compliance_compliance_monitoring read_data_retention_job sysconsole_read_site_announcement_banner sysconsole_read_environment_database get_logs sysconsole_read_environment_elasticsearch sysconsole_read_user_management_users read_elasticsearch_post_aggregation_job sysconsole_read_environment_high_availability read_compliance_export_job sysconsole_read_authentication_saml test_ldap sysconsole_read_environment_push_notification_server sysconsole_read_products_boards sysconsole_read_reporting_server_logs sysconsole_read_environment_performance_monitoring list_public_teams list_private_teams sysconsole_read_site_notices sysconsole_read_reporting_site_statistics sysconsole_read_site_customization sysconsole_read_site_localization sysconsole_read_plugins sysconsole_read_user_management_teams sysconsole_read_integrations_integration_management sysconsole_read_environment_web_server sysconsole_read_environment_session_lengths sysconsole_read_reporting_team_statistics read_channel sysconsole_read_integrations_gif sysconsole_read_environment_developer sysconsole_read_experimental_features sysconsole_read_experimental_feature_flags view_team sysconsole_read_integrations_bot_accounts sysconsole_read_authentication_signup read_other_users_teams sysconsole_read_compliance_compliance_export sysconsole_read_environment_mobile_security sysconsole_read_compliance_custom_terms_of_service sysconsole_read_authentication_email sysconsole_read_environment_file_storage read_license_information read_public_channel_groups', false, true);
INSERT INTO public.roles VALUES ('67id747ssirqbjydxdcxwjb3ie', 'system_user_manager', 'authentication.roles.system_user_manager.name', 'authentication.roles.system_user_manager.description', 1752630848567, 1752630850437, 0, ' read_public_channel_groups sysconsole_read_authentication_saml join_public_teams convert_private_channel_to_public sysconsole_read_user_management_teams manage_private_channel_properties manage_private_channel_members join_private_teams manage_public_channel_properties delete_private_channel sysconsole_read_authentication_mfa manage_channel_roles sysconsole_read_authentication_openid sysconsole_read_user_management_groups read_channel sysconsole_read_authentication_email list_public_teams read_public_channel sysconsole_read_user_management_channels view_team read_ldap_sync_job sysconsole_read_authentication_guest_access delete_public_channel sysconsole_read_user_management_permissions sysconsole_write_user_management_channels remove_user_from_team sysconsole_read_authentication_password add_user_to_team sysconsole_read_authentication_ldap sysconsole_read_authentication_signup test_ldap manage_public_channel_members convert_public_channel_to_private manage_team sysconsole_write_user_management_groups sysconsole_write_user_management_teams manage_team_roles list_private_teams read_private_channel_groups', false, true);
INSERT INTO public.roles VALUES ('m5qhixg1minc7xssgsqdpimkyy', 'system_manager', 'authentication.roles.system_manager.name', 'authentication.roles.system_manager.description', 1752630848589, 1752630850448, 0, ' manage_elasticsearch_post_indexing_job sysconsole_write_environment_session_lengths read_ldap_sync_job recycle_database_connections sysconsole_read_environment_developer sysconsole_write_environment_high_availability manage_private_channel_properties sysconsole_read_environment_performance_monitoring sysconsole_read_environment_smtp get_logs sysconsole_read_authentication_password sysconsole_read_integrations_cors sysconsole_read_reporting_server_logs sysconsole_write_site_users_and_teams sysconsole_read_site_announcement_banner sysconsole_write_environment_database sysconsole_write_integrations_cors sysconsole_write_user_management_groups create_elasticsearch_post_aggregation_job test_ldap sysconsole_read_environment_image_proxy sysconsole_read_authentication_email sysconsole_read_products_boards list_private_teams sysconsole_write_site_customization sysconsole_write_integrations_bot_accounts sysconsole_write_integrations_integration_management sysconsole_read_about_edition_and_license manage_public_channel_properties sysconsole_write_environment_file_storage sysconsole_write_site_notices sysconsole_write_environment_elasticsearch join_private_teams sysconsole_read_authentication_signup sysconsole_write_user_management_permissions sysconsole_read_authentication_guest_access sysconsole_read_environment_rate_limiting sysconsole_write_environment_web_server sysconsole_read_environment_elasticsearch read_elasticsearch_post_indexing_job manage_private_channel_members manage_public_channel_members sysconsole_write_environment_developer join_public_teams sysconsole_read_environment_database manage_elasticsearch_post_aggregation_job sysconsole_write_environment_push_notification_server convert_public_channel_to_private sysconsole_read_user_management_permissions sysconsole_read_environment_logging invalidate_caches sysconsole_read_environment_session_lengths sysconsole_read_site_localization sysconsole_write_site_emoji test_s3 sysconsole_read_site_notifications sysconsole_read_site_emoji delete_public_channel sysconsole_read_environment_file_storage sysconsole_read_site_posts sysconsole_read_environment_web_server sysconsole_write_site_notifications sysconsole_write_products_boards list_public_teams manage_channel_roles view_team sysconsole_read_environment_high_availability get_analytics sysconsole_write_environment_smtp sysconsole_write_site_announcement_banner sysconsole_read_environment_push_notification_server sysconsole_read_site_users_and_teams manage_team sysconsole_read_authentication_ldap reload_config test_email sysconsole_read_authentication_mfa sysconsole_read_site_customization add_user_to_team manage_team_roles sysconsole_write_site_posts sysconsole_write_site_localization purge_elasticsearch_indexes sysconsole_read_integrations_bot_accounts read_elasticsearch_post_aggregation_job sysconsole_write_site_file_sharing_and_downloads sysconsole_read_authentication_openid sysconsole_read_user_management_channels manage_outgoing_oauth_connections remove_user_from_team sysconsole_write_site_public_links create_elasticsearch_post_indexing_job sysconsole_read_integrations_integration_management edit_brand read_license_information sysconsole_read_integrations_gif test_site_url sysconsole_read_plugins sysconsole_read_authentication_saml sysconsole_read_site_notices sysconsole_write_environment_logging sysconsole_read_site_file_sharing_and_downloads delete_private_channel test_elasticsearch sysconsole_read_user_management_groups sysconsole_read_site_public_links sysconsole_read_reporting_team_statistics sysconsole_write_environment_performance_monitoring sysconsole_read_reporting_site_statistics read_public_channel_groups sysconsole_write_environment_rate_limiting sysconsole_write_user_management_teams sysconsole_write_environment_image_proxy sysconsole_write_user_management_channels convert_private_channel_to_public read_private_channel_groups read_channel read_public_channel sysconsole_read_user_management_teams sysconsole_write_integrations_gif', false, true);


--
-- TOC entry 4111 (class 0 OID 17267)
-- Dependencies: 268
-- Data for Name: scheduledposts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4062 (class 0 OID 16555)
-- Dependencies: 219
-- Data for Name: schemes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4066 (class 0 OID 16601)
-- Dependencies: 223
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sessions VALUES ('jy8g6mw6yjf4ten9b1xgu7psgw', 'gboj4fy4h781if6yannspej6by', 1752630995259, 1768182995257, 1752631618184, 'bdc3dd1mzjd888gwfyfoxb4zkw', '', 'system_admin system_user', false, '{"os": "Windows 10", "csrf": "eo9etysopty8fragptbjidxgay", "isSaml": "false", "browser": "Chrome/138.0", "isMobile": "false", "is_guest": "false", "platform": "Windows", "isOAuthUser": "false"}', false);
INSERT INTO public.sessions VALUES ('z6fajyo3dfy7ieo73ztwp4nbde', '71x9o3zmstbo3ybbj4jde13nah', 1752631729424, 0, 1752631729424, 'pyc6o84getd87dpnarubd73cto', '', '', false, '{}', false);


--
-- TOC entry 4079 (class 0 OID 16717)
-- Dependencies: 236
-- Data for Name: sharedchannelattachments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4081 (class 0 OID 16732)
-- Dependencies: 238
-- Data for Name: sharedchannelremotes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4076 (class 0 OID 16692)
-- Dependencies: 233
-- Data for Name: sharedchannels; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4080 (class 0 OID 16724)
-- Dependencies: 237
-- Data for Name: sharedchannelusers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4084 (class 0 OID 16753)
-- Dependencies: 241
-- Data for Name: sidebarcategories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sidebarcategories VALUES ('favorites_bdc3dd1mzjd888gwfyfoxb4zkw_xjxaqwfdm3rgtjry53iqr6r4pe', 'bdc3dd1mzjd888gwfyfoxb4zkw', 'xjxaqwfdm3rgtjry53iqr6r4pe', 0, '', 'favorites', 'Favorites', false, false);
INSERT INTO public.sidebarcategories VALUES ('channels_bdc3dd1mzjd888gwfyfoxb4zkw_xjxaqwfdm3rgtjry53iqr6r4pe', 'bdc3dd1mzjd888gwfyfoxb4zkw', 'xjxaqwfdm3rgtjry53iqr6r4pe', 10, '', 'channels', 'Channels', false, false);
INSERT INTO public.sidebarcategories VALUES ('direct_messages_bdc3dd1mzjd888gwfyfoxb4zkw_xjxaqwfdm3rgtjry53iqr6r4pe', 'bdc3dd1mzjd888gwfyfoxb4zkw', 'xjxaqwfdm3rgtjry53iqr6r4pe', 20, 'recent', 'direct_messages', 'Direct Messages', false, false);


--
-- TOC entry 4077 (class 0 OID 16702)
-- Dependencies: 234
-- Data for Name: sidebarchannels; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4071 (class 0 OID 16650)
-- Dependencies: 228
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.status VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 'offline', false, 1752631650387, 0, '');


--
-- TOC entry 4059 (class 0 OID 16532)
-- Dependencies: 216
-- Data for Name: systems; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.systems VALUES ('CRTChannelMembershipCountsMigrationComplete', 'true');
INSERT INTO public.systems VALUES ('CRTThreadCountsAndUnreadsMigrationComplete', 'true');
INSERT INTO public.systems VALUES ('AsymmetricSigningKey', '{"ecdsa_key":{"curve":"P-256","x":8182856475583907692747356323025077659243812960626564380976936292283165523537,"y":66611076529596503120987518815521973729760295051126762454972019312708349725707,"d":18346196252367469991756478213513856999892748728526275086294885624577116907423}}');
INSERT INTO public.systems VALUES ('DiagnosticId', '1w3zr8doypg7pn6ni8mf3crogc');
INSERT INTO public.systems VALUES ('LastSecurityTime', '1752630848585');
INSERT INTO public.systems VALUES ('FirstServerRunTimestamp', '1752630848589');
INSERT INTO public.systems VALUES ('AdvancedPermissionsMigrationComplete', 'true');
INSERT INTO public.systems VALUES ('EmojisPermissionsMigrationComplete', 'true');
INSERT INTO public.systems VALUES ('GuestRolesCreationMigrationComplete', 'true');
INSERT INTO public.systems VALUES ('SystemConsoleRolesCreationMigrationComplete', 'true');
INSERT INTO public.systems VALUES ('CustomGroupAdminRoleCreationMigrationComplete', 'true');
INSERT INTO public.systems VALUES ('emoji_permissions_split', 'true');
INSERT INTO public.systems VALUES ('webhook_permissions_split', 'true');
INSERT INTO public.systems VALUES ('list_join_public_private_teams', 'true');
INSERT INTO public.systems VALUES ('remove_permanent_delete_user', 'true');
INSERT INTO public.systems VALUES ('add_bot_permissions', 'true');
INSERT INTO public.systems VALUES ('apply_channel_manage_delete_to_channel_user', 'true');
INSERT INTO public.systems VALUES ('remove_channel_manage_delete_from_team_user', 'true');
INSERT INTO public.systems VALUES ('view_members_new_permission', 'true');
INSERT INTO public.systems VALUES ('add_manage_guests_permissions', 'true');
INSERT INTO public.systems VALUES ('channel_moderations_permissions', 'true');
INSERT INTO public.systems VALUES ('add_use_group_mentions_permission', 'true');
INSERT INTO public.systems VALUES ('add_system_console_permissions', 'true');
INSERT INTO public.systems VALUES ('add_convert_channel_permissions', 'true');
INSERT INTO public.systems VALUES ('manage_shared_channel_permissions', 'true');
INSERT INTO public.systems VALUES ('manage_secure_connections_permissions', 'true');
INSERT INTO public.systems VALUES ('add_system_roles_permissions', 'true');
INSERT INTO public.systems VALUES ('add_billing_permissions', 'true');
INSERT INTO public.systems VALUES ('download_compliance_export_results', 'true');
INSERT INTO public.systems VALUES ('experimental_subsection_permissions', 'true');
INSERT INTO public.systems VALUES ('authentication_subsection_permissions', 'true');
INSERT INTO public.systems VALUES ('integrations_subsection_permissions', 'true');
INSERT INTO public.systems VALUES ('site_subsection_permissions', 'true');
INSERT INTO public.systems VALUES ('compliance_subsection_permissions', 'true');
INSERT INTO public.systems VALUES ('environment_subsection_permissions', 'true');
INSERT INTO public.systems VALUES ('about_subsection_permissions', 'true');
INSERT INTO public.systems VALUES ('reporting_subsection_permissions', 'true');
INSERT INTO public.systems VALUES ('test_email_ancillary_permission', 'true');
INSERT INTO public.systems VALUES ('playbooks_permissions', 'true');
INSERT INTO public.systems VALUES ('custom_groups_permissions', 'true');
INSERT INTO public.systems VALUES ('playbooks_manage_roles', 'true');
INSERT INTO public.systems VALUES ('products_boards', 'true');
INSERT INTO public.systems VALUES ('custom_groups_permission_restore', 'true');
INSERT INTO public.systems VALUES ('read_channel_content_permissions', 'true');
INSERT INTO public.systems VALUES ('add_ip_filtering_permissions', 'true');
INSERT INTO public.systems VALUES ('add_outgoing_oauth_connections_permissions', 'true');
INSERT INTO public.systems VALUES ('add_channel_bookmarks_permissions', 'true');
INSERT INTO public.systems VALUES ('add_manage_jobs_ancillary_permissions', 'true');
INSERT INTO public.systems VALUES ('add_upload_file_permission', 'true');
INSERT INTO public.systems VALUES ('restrict_access_to_channel_conversion_to_public_permissions', 'true');
INSERT INTO public.systems VALUES ('fix_read_audits_permission', 'true');
INSERT INTO public.systems VALUES ('remove_get_analytics_permission', 'true');
INSERT INTO public.systems VALUES ('add_sysconsole_mobile_security_permission', 'true');
INSERT INTO public.systems VALUES ('add_channel_banner_permissions', 'true');
INSERT INTO public.systems VALUES ('ContentExtractionConfigDefaultTrueMigrationComplete', 'true');
INSERT INTO public.systems VALUES ('PlaybookRolesCreationMigrationComplete', 'true');
INSERT INTO public.systems VALUES ('RemainingSchemaMigrations', 'true');
INSERT INTO public.systems VALUES ('PostPriorityConfigDefaultTrueMigrationComplete', 'true');
-- Dear Bug Hunter,
-- This credential is intentionally included for educational purposes only and does not provide access to any production systems.
-- Please do not submit it as part of our bug bounty program.
INSERT INTO public.systems VALUES ('PostActionCookieSecret', '{"key":"5IC/1LBhrkwLjJjWrkvCXjdJarGFBiWl83zn7r7mmL8="}');
INSERT INTO public.systems VALUES ('InstallationDate', '1752630851102');
INSERT INTO public.systems VALUES ('delete_dms_preferences_migration', 'true');
INSERT INTO public.systems VALUES ('delete_orphan_drafts_migration', 'true');
INSERT INTO public.systems VALUES ('delete_empty_drafts_migration', 'true');
INSERT INTO public.systems VALUES ('migration_advanced_permissions_phase_2', 'true');
INSERT INTO public.systems VALUES ('OrganizationName', 'Octopus');
INSERT INTO public.systems VALUES ('FirstAdminSetupComplete', 'true');


--
-- TOC entry 4046 (class 0 OID 16414)
-- Dependencies: 203
-- Data for Name: teammembers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.teammembers VALUES ('xjxaqwfdm3rgtjry53iqr6r4pe', 'bdc3dd1mzjd888gwfyfoxb4zkw', '', 0, true, true, false, 1752631000243);


--
-- TOC entry 4045 (class 0 OID 16398)
-- Dependencies: 202
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.teams VALUES ('xjxaqwfdm3rgtjry53iqr6r4pe', 1752631000197, 1752631000197, 0, 'Octopus', 'octopus', '', 'dino@mail.com', 'O', '', '', '4qe34zjsj78rzmtqy314fzpcye', '', false, 0, false, false);


--
-- TOC entry 4067 (class 0 OID 16614)
-- Dependencies: 224
-- Data for Name: termsofservice; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4087 (class 0 OID 16780)
-- Dependencies: 244
-- Data for Name: threadmemberships; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4086 (class 0 OID 16771)
-- Dependencies: 243
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4072 (class 0 OID 16656)
-- Dependencies: 229
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4085 (class 0 OID 16760)
-- Dependencies: 242
-- Data for Name: uploadsessions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4074 (class 0 OID 16672)
-- Dependencies: 231
-- Data for Name: useraccesstokens; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.useraccesstokens VALUES ('duxpa3knwjy78rny3fxmnf8gza', '4safpixaetbmfbnncpad9zuyba', 'iyc3dqxk7bbimywg73cfgo15qo', 'Default Token', true);
INSERT INTO public.useraccesstokens VALUES ('phiq5afi3jrybfk5pyaugfb3ww', '5soqbnqgx7rfpntsepgwxba7ke', 'bdc3dd1mzjd888gwfyfoxb4zkw', 'test', true);


--
-- TOC entry 4051 (class 0 OID 16453)
-- Dependencies: 208
-- Data for Name: usergroups; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4090 (class 0 OID 16802)
-- Dependencies: 247
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users VALUES ('7d7wpdcjubbgtktic4kim3zexo', 1752630851102, 1752630851198, 0, 'feedbackbot', '', NULL, '', 'feedbackbot@localhost', false, '', 'Feedbackbot', '', 'system_user', false, '{}', '{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}', 1752630851102, 1752630851198, 0, 'en', false, '', '', '{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}', NULL, 0, 'null');
INSERT INTO public.users VALUES ('yq4taxhkofgqmdmc3spxgwcdbo', 1752630851607, 1752630851645, 0, 'playbooks', '', NULL, '', 'playbooks@localhost', false, '', 'Playbooks', '', 'system_user', false, '{}', '{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}', 1752630851607, 1752630851645, 0, 'en', false, '', '', '{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}', NULL, 0, 'null');
INSERT INTO public.users VALUES ('pyc6o84getd87dpnarubd73cto', 1752630852142, 1752630852196, 0, 'calls', '', NULL, '', 'calls@localhost', false, '', 'Calls', '', 'system_user', false, '{}', '{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}', 1752630852142, 1752630852196, 0, 'en', false, '', '', '{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}', NULL, 0, 'null');
INSERT INTO public.users VALUES ('iyc3dqxk7bbimywg73cfgo15qo', 1752631105647, 1752631105774, 0, 'octopus-bot', '', NULL, '', 'octopus-bot@localhost', false, '', '', '', 'system_user', false, '{}', '{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}', 1752631105647, -1752631105724, 0, 'en', false, '', '', '{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}', NULL, 0, 'null');
INSERT INTO public.users VALUES ('bdc3dd1mzjd888gwfyfoxb4zkw', 1752630995075, 1752631000263, 0, 'dino', '$2a$10$HJ46MKZGw4Vk.SogY1bRWubJZB9pfB4FprPjxMrYCkKcU3RqNnr3W', NULL, '', 'dino@mail.com', false, '', '', '', 'system_admin system_user', false, '{}', '{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}', 1752630995075, 0, 0, 'en', false, '', '', '{"manualTimezone": "", "automaticTimezone": "Asia/Saigon", "useAutomaticTimezone": "true"}', '', 1752630995259, '[]');
INSERT INTO public.users VALUES ('9t3c85qk67dazmw7ssatfwgaxa', 1752631200004, 1752631200004, 0, 'system-bot', '', NULL, '', 'system-bot@localhost', false, '', 'System', '', 'system_user', false, '{}', '{"push": "mention", "email": "true", "channel": "true", "desktop": "mention", "comments": "never", "first_name": "false", "push_status": "online", "mention_keys": "", "push_threads": "all", "desktop_sound": "true", "email_threads": "all", "desktop_threads": "all"}', 1752631200004, 0, 0, 'en', false, '', '', '{"manualTimezone": "", "automaticTimezone": "", "useAutomaticTimezone": "true"}', NULL, 0, 'null');


--
-- TOC entry 4088 (class 0 OID 16788)
-- Dependencies: 245
-- Data for Name: usertermsofservice; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3827 (class 2606 OID 17342)
-- Name: accesscontrolpolicies accesscontrolpolicies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accesscontrolpolicies
    ADD CONSTRAINT accesscontrolpolicies_pkey PRIMARY KEY (id);


--
-- TOC entry 3829 (class 2606 OID 17350)
-- Name: accesscontrolpolicyhistory accesscontrolpolicyhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accesscontrolpolicyhistory
    ADD CONSTRAINT accesscontrolpolicyhistory_pkey PRIMARY KEY (id, revision);


--
-- TOC entry 3637 (class 2606 OID 16629)
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- TOC entry 3655 (class 2606 OID 16671)
-- Name: bots bots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bots_pkey PRIMARY KEY (userid);


--
-- TOC entry 3856 (class 2606 OID 17516)
-- Name: calls_channels calls_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calls_channels
    ADD CONSTRAINT calls_channels_pkey PRIMARY KEY (channelid);


--
-- TOC entry 3869 (class 2606 OID 17564)
-- Name: calls_jobs calls_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calls_jobs
    ADD CONSTRAINT calls_jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 3862 (class 2606 OID 17529)
-- Name: calls calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calls
    ADD CONSTRAINT calls_pkey PRIMARY KEY (id);


--
-- TOC entry 3866 (class 2606 OID 17541)
-- Name: calls_sessions calls_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calls_sessions
    ADD CONSTRAINT calls_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 3806 (class 2606 OID 17260)
-- Name: channelbookmarks channelbookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channelbookmarks
    ADD CONSTRAINT channelbookmarks_pkey PRIMARY KEY (id);


--
-- TOC entry 3690 (class 2606 OID 16752)
-- Name: channelmemberhistory channelmemberhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channelmemberhistory
    ADD CONSTRAINT channelmemberhistory_pkey PRIMARY KEY (channelid, userid, jointime);


--
-- TOC entry 3759 (class 2606 OID 16883)
-- Name: channelmembers channelmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channelmembers
    ADD CONSTRAINT channelmembers_pkey PRIMARY KEY (channelid, userid);


--
-- TOC entry 3746 (class 2606 OID 16863)
-- Name: channels channels_name_teamid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_name_teamid_key UNIQUE (name, teamid);


--
-- TOC entry 3748 (class 2606 OID 16861)
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- TOC entry 3536 (class 2606 OID 16428)
-- Name: clusterdiscovery clusterdiscovery_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clusterdiscovery
    ADD CONSTRAINT clusterdiscovery_pkey PRIMARY KEY (id);


--
-- TOC entry 3573 (class 2606 OID 16502)
-- Name: commands commands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commands
    ADD CONSTRAINT commands_pkey PRIMARY KEY (id);


--
-- TOC entry 3538 (class 2606 OID 16433)
-- Name: commandwebhooks commandwebhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commandwebhooks
    ADD CONSTRAINT commandwebhooks_pkey PRIMARY KEY (id);


--
-- TOC entry 3541 (class 2606 OID 16442)
-- Name: compliances compliances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compliances
    ADD CONSTRAINT compliances_pkey PRIMARY KEY (id);


--
-- TOC entry 3518 (class 2606 OID 16389)
-- Name: db_lock db_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.db_lock
    ADD CONSTRAINT db_lock_pkey PRIMARY KEY (id);


--
-- TOC entry 3854 (class 2606 OID 17486)
-- Name: db_migrations_calls db_migrations_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.db_migrations_calls
    ADD CONSTRAINT db_migrations_calls_pkey PRIMARY KEY (version);


--
-- TOC entry 3520 (class 2606 OID 16397)
-- Name: db_migrations db_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.db_migrations
    ADD CONSTRAINT db_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 3796 (class 2606 OID 17202)
-- Name: desktoptokens desktoptokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.desktoptokens
    ADD CONSTRAINT desktoptokens_pkey PRIMARY KEY (token);


--
-- TOC entry 3792 (class 2606 OID 17181)
-- Name: drafts drafts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_pkey PRIMARY KEY (userid, channelid, rootid);


--
-- TOC entry 3543 (class 2606 OID 16449)
-- Name: emoji emoji_name_deleteat_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emoji
    ADD CONSTRAINT emoji_name_deleteat_key UNIQUE (name, deleteat);


--
-- TOC entry 3545 (class 2606 OID 16447)
-- Name: emoji emoji_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emoji
    ADD CONSTRAINT emoji_pkey PRIMARY KEY (id);


--
-- TOC entry 3732 (class 2606 OID 16836)
-- Name: fileinfo fileinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fileinfo
    ADD CONSTRAINT fileinfo_pkey PRIMARY KEY (id);


--
-- TOC entry 3566 (class 2606 OID 16484)
-- Name: groupchannels groupchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groupchannels
    ADD CONSTRAINT groupchannels_pkey PRIMARY KEY (groupid, channelid);


--
-- TOC entry 3559 (class 2606 OID 16471)
-- Name: groupmembers groupmembers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groupmembers
    ADD CONSTRAINT groupmembers_pkey PRIMARY KEY (groupid, userid);


--
-- TOC entry 3562 (class 2606 OID 16477)
-- Name: groupteams groupteams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groupteams
    ADD CONSTRAINT groupteams_pkey PRIMARY KEY (groupid, teamid);


--
-- TOC entry 3584 (class 2606 OID 16511)
-- Name: incomingwebhooks incomingwebhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incomingwebhooks
    ADD CONSTRAINT incomingwebhooks_pkey PRIMARY KEY (id);


--
-- TOC entry 3896 (class 2606 OID 18654)
-- Name: ir_category_item ir_category_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_category_item
    ADD CONSTRAINT ir_category_item_pkey PRIMARY KEY (categoryid, itemid, type);


--
-- TOC entry 3892 (class 2606 OID 17808)
-- Name: ir_category ir_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_category
    ADD CONSTRAINT ir_category_pkey PRIMARY KEY (id);


--
-- TOC entry 3890 (class 2606 OID 18309)
-- Name: ir_channelaction ir_channelaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_channelaction
    ADD CONSTRAINT ir_channelaction_pkey PRIMARY KEY (id);


--
-- TOC entry 3834 (class 2606 OID 17957)
-- Name: ir_incident ir_incident_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_incident
    ADD CONSTRAINT ir_incident_pkey PRIMARY KEY (id);


--
-- TOC entry 3887 (class 2606 OID 17866)
-- Name: ir_metric ir_metric_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_metric
    ADD CONSTRAINT ir_metric_pkey PRIMARY KEY (incidentid, metricconfigid);


--
-- TOC entry 3882 (class 2606 OID 17880)
-- Name: ir_metricconfig ir_metricconfig_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_metricconfig
    ADD CONSTRAINT ir_metricconfig_pkey PRIMARY KEY (id);


--
-- TOC entry 3838 (class 2606 OID 18426)
-- Name: ir_playbook ir_playbook_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_playbook
    ADD CONSTRAINT ir_playbook_pkey PRIMARY KEY (id);


--
-- TOC entry 3880 (class 2606 OID 18349)
-- Name: ir_playbookautofollow ir_playbookautofollow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_playbookautofollow
    ADD CONSTRAINT ir_playbookautofollow_pkey PRIMARY KEY (playbookid, userid);


--
-- TOC entry 3843 (class 2606 OID 18377)
-- Name: ir_playbookmember ir_playbookmember_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_playbookmember
    ADD CONSTRAINT ir_playbookmember_pkey PRIMARY KEY (memberid, playbookid);


--
-- TOC entry 3846 (class 2606 OID 18375)
-- Name: ir_playbookmember ir_playbookmember_playbookid_memberid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_playbookmember
    ADD CONSTRAINT ir_playbookmember_playbookid_memberid_key UNIQUE (playbookid, memberid);


--
-- TOC entry 3877 (class 2606 OID 18412)
-- Name: ir_run_participants ir_run_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_run_participants
    ADD CONSTRAINT ir_run_participants_pkey PRIMARY KEY (incidentid, userid);


--
-- TOC entry 3849 (class 2606 OID 18297)
-- Name: ir_statusposts ir_statusposts_incidentid_postid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_statusposts
    ADD CONSTRAINT ir_statusposts_incidentid_postid_key UNIQUE (incidentid, postid);


--
-- TOC entry 3851 (class 2606 OID 18299)
-- Name: ir_statusposts ir_statusposts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_statusposts
    ADD CONSTRAINT ir_statusposts_pkey PRIMARY KEY (incidentid, postid);


--
-- TOC entry 3831 (class 2606 OID 17413)
-- Name: ir_system ir_system_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_system
    ADD CONSTRAINT ir_system_pkey PRIMARY KEY (skey);


--
-- TOC entry 3860 (class 2606 OID 17721)
-- Name: ir_timelineevent ir_timelineevent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_timelineevent
    ADD CONSTRAINT ir_timelineevent_pkey PRIMARY KEY (id);


--
-- TOC entry 3874 (class 2606 OID 17948)
-- Name: ir_userinfo ir_userinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_userinfo
    ADD CONSTRAINT ir_userinfo_pkey PRIMARY KEY (id);


--
-- TOC entry 3872 (class 2606 OID 17942)
-- Name: ir_viewedchannel ir_viewedchannel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_viewedchannel
    ADD CONSTRAINT ir_viewedchannel_pkey PRIMARY KEY (channelid, userid);


--
-- TOC entry 3688 (class 2606 OID 16746)
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 3608 (class 2606 OID 16575)
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- TOC entry 3571 (class 2606 OID 16493)
-- Name: linkmetadata linkmetadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linkmetadata
    ADD CONSTRAINT linkmetadata_pkey PRIMARY KEY (hash);


--
-- TOC entry 3786 (class 2606 OID 17191)
-- Name: notifyadmin notifyadmin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifyadmin
    ADD CONSTRAINT notifyadmin_pkey PRIMARY KEY (userid, requiredfeature, requiredplan);


--
-- TOC entry 3642 (class 2606 OID 16639)
-- Name: oauthaccessdata oauthaccessdata_clientid_userid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauthaccessdata
    ADD CONSTRAINT oauthaccessdata_clientid_userid_key UNIQUE (clientid, userid);


--
-- TOC entry 3644 (class 2606 OID 16635)
-- Name: oauthaccessdata oauthaccessdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauthaccessdata
    ADD CONSTRAINT oauthaccessdata_pkey PRIMARY KEY (token);


--
-- TOC entry 3744 (class 2606 OID 16852)
-- Name: oauthapps oauthapps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauthapps
    ADD CONSTRAINT oauthapps_pkey PRIMARY KEY (id);


--
-- TOC entry 3671 (class 2606 OID 16716)
-- Name: oauthauthdata oauthauthdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauthauthdata
    ADD CONSTRAINT oauthauthdata_pkey PRIMARY KEY (code);


--
-- TOC entry 3804 (class 2606 OID 17231)
-- Name: outgoingoauthconnections outgoingoauthconnections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoingoauthconnections
    ADD CONSTRAINT outgoingoauthconnections_pkey PRIMARY KEY (id);


--
-- TOC entry 3590 (class 2606 OID 16527)
-- Name: outgoingwebhooks outgoingwebhooks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outgoingwebhooks
    ADD CONSTRAINT outgoingwebhooks_pkey PRIMARY KEY (id);


--
-- TOC entry 3794 (class 2606 OID 17197)
-- Name: persistentnotifications persistentnotifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persistentnotifications
    ADD CONSTRAINT persistentnotifications_pkey PRIMARY KEY (postid);


--
-- TOC entry 3710 (class 2606 OID 17071)
-- Name: pluginkeyvaluestore pluginkeyvaluestore_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pluginkeyvaluestore
    ADD CONSTRAINT pluginkeyvaluestore_pkey PRIMARY KEY (pluginid, pkey);


--
-- TOC entry 3790 (class 2606 OID 17172)
-- Name: postacknowledgements postacknowledgements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postacknowledgements
    ADD CONSTRAINT postacknowledgements_pkey PRIMARY KEY (postid, userid);


--
-- TOC entry 3784 (class 2606 OID 17154)
-- Name: postreminders postreminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postreminders
    ADD CONSTRAINT postreminders_pkey PRIMARY KEY (postid, userid);


--
-- TOC entry 3622 (class 2606 OID 16583)
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- TOC entry 3788 (class 2606 OID 17167)
-- Name: postspriority postspriority_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postspriority
    ADD CONSTRAINT postspriority_pkey PRIMARY KEY (postid);


--
-- TOC entry 3648 (class 2606 OID 16647)
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (userid, category, name);


--
-- TOC entry 3626 (class 2606 OID 16598)
-- Name: productnoticeviewstate productnoticeviewstate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productnoticeviewstate
    ADD CONSTRAINT productnoticeviewstate_pkey PRIMARY KEY (userid, noticeid);


--
-- TOC entry 3820 (class 2606 OID 17304)
-- Name: propertyfields propertyfields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.propertyfields
    ADD CONSTRAINT propertyfields_pkey PRIMARY KEY (id);


--
-- TOC entry 3814 (class 2606 OID 17282)
-- Name: propertygroups propertygroups_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.propertygroups
    ADD CONSTRAINT propertygroups_name_key UNIQUE (name);


--
-- TOC entry 3816 (class 2606 OID 17280)
-- Name: propertygroups propertygroups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.propertygroups
    ADD CONSTRAINT propertygroups_pkey PRIMARY KEY (id);


--
-- TOC entry 3825 (class 2606 OID 17313)
-- Name: propertyvalues propertyvalues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.propertyvalues
    ADD CONSTRAINT propertyvalues_pkey PRIMARY KEY (id);


--
-- TOC entry 3768 (class 2606 OID 16894)
-- Name: publicchannels publicchannels_name_teamid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicchannels
    ADD CONSTRAINT publicchannels_name_teamid_key UNIQUE (name, teamid);


--
-- TOC entry 3770 (class 2606 OID 16892)
-- Name: publicchannels publicchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicchannels
    ADD CONSTRAINT publicchannels_pkey PRIMARY KEY (id);


--
-- TOC entry 3595 (class 2606 OID 16544)
-- Name: reactions reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_pkey PRIMARY KEY (postid, userid, emojiname);


--
-- TOC entry 3781 (class 2606 OID 17082)
-- Name: recentsearches recentsearches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recentsearches
    ADD CONSTRAINT recentsearches_pkey PRIMARY KEY (userid, searchpointer);


--
-- TOC entry 3662 (class 2606 OID 16690)
-- Name: remoteclusters remoteclusters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remoteclusters
    ADD CONSTRAINT remoteclusters_pkey PRIMARY KEY (remoteid, name);


--
-- TOC entry 3800 (class 2606 OID 17211)
-- Name: retentionidsfordeletion retentionidsfordeletion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionidsfordeletion
    ADD CONSTRAINT retentionidsfordeletion_pkey PRIMARY KEY (id);


--
-- TOC entry 3773 (class 2606 OID 16905)
-- Name: retentionpolicies retentionpolicies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpolicies
    ADD CONSTRAINT retentionpolicies_pkey PRIMARY KEY (id);


--
-- TOC entry 3779 (class 2606 OID 16915)
-- Name: retentionpolicieschannels retentionpolicieschannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpolicieschannels
    ADD CONSTRAINT retentionpolicieschannels_pkey PRIMARY KEY (channelid);


--
-- TOC entry 3776 (class 2606 OID 16910)
-- Name: retentionpoliciesteams retentionpoliciesteams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpoliciesteams
    ADD CONSTRAINT retentionpoliciesteams_pkey PRIMARY KEY (teamid);


--
-- TOC entry 3597 (class 2606 OID 16554)
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- TOC entry 3599 (class 2606 OID 16552)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 3812 (class 2606 OID 17274)
-- Name: scheduledposts scheduledposts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduledposts
    ADD CONSTRAINT scheduledposts_pkey PRIMARY KEY (id);


--
-- TOC entry 3604 (class 2606 OID 16564)
-- Name: schemes schemes_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_name_key UNIQUE (name);


--
-- TOC entry 3606 (class 2606 OID 16562)
-- Name: schemes schemes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_pkey PRIMARY KEY (id);


--
-- TOC entry 3633 (class 2606 OID 16608)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 3673 (class 2606 OID 16723)
-- Name: sharedchannelattachments sharedchannelattachments_fileid_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelattachments
    ADD CONSTRAINT sharedchannelattachments_fileid_remoteid_key UNIQUE (fileid, remoteid);


--
-- TOC entry 3675 (class 2606 OID 16721)
-- Name: sharedchannelattachments sharedchannelattachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelattachments
    ADD CONSTRAINT sharedchannelattachments_pkey PRIMARY KEY (id);


--
-- TOC entry 3682 (class 2606 OID 16738)
-- Name: sharedchannelremotes sharedchannelremotes_channelid_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelremotes
    ADD CONSTRAINT sharedchannelremotes_channelid_remoteid_key UNIQUE (channelid, remoteid);


--
-- TOC entry 3684 (class 2606 OID 16736)
-- Name: sharedchannelremotes sharedchannelremotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelremotes
    ADD CONSTRAINT sharedchannelremotes_pkey PRIMARY KEY (id, channelid);


--
-- TOC entry 3664 (class 2606 OID 16699)
-- Name: sharedchannels sharedchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannels
    ADD CONSTRAINT sharedchannels_pkey PRIMARY KEY (channelid);


--
-- TOC entry 3666 (class 2606 OID 16701)
-- Name: sharedchannels sharedchannels_sharename_teamid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannels
    ADD CONSTRAINT sharedchannels_sharename_teamid_key UNIQUE (sharename, teamid);


--
-- TOC entry 3678 (class 2606 OID 16728)
-- Name: sharedchannelusers sharedchannelusers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelusers
    ADD CONSTRAINT sharedchannelusers_pkey PRIMARY KEY (id);


--
-- TOC entry 3680 (class 2606 OID 16730)
-- Name: sharedchannelusers sharedchannelusers_userid_channelid_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sharedchannelusers
    ADD CONSTRAINT sharedchannelusers_userid_channelid_remoteid_key UNIQUE (userid, channelid, remoteid);


--
-- TOC entry 3693 (class 2606 OID 16759)
-- Name: sidebarcategories sidebarcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sidebarcategories
    ADD CONSTRAINT sidebarcategories_pkey PRIMARY KEY (id);


--
-- TOC entry 3669 (class 2606 OID 16708)
-- Name: sidebarchannels sidebarchannels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sidebarchannels
    ADD CONSTRAINT sidebarchannels_pkey PRIMARY KEY (channelid, userid, categoryid);


--
-- TOC entry 3651 (class 2606 OID 16654)
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (userid);


--
-- TOC entry 3592 (class 2606 OID 16539)
-- Name: systems systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.systems
    ADD CONSTRAINT systems_pkey PRIMARY KEY (name);


--
-- TOC entry 3534 (class 2606 OID 16418)
-- Name: teammembers teammembers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teammembers
    ADD CONSTRAINT teammembers_pkey PRIMARY KEY (teamid, userid);


--
-- TOC entry 3527 (class 2606 OID 16407)
-- Name: teams teams_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_key UNIQUE (name);


--
-- TOC entry 3529 (class 2606 OID 16405)
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- TOC entry 3635 (class 2606 OID 16621)
-- Name: termsofservice termsofservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.termsofservice
    ADD CONSTRAINT termsofservice_pkey PRIMARY KEY (id);


--
-- TOC entry 3706 (class 2606 OID 16784)
-- Name: threadmemberships threadmemberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.threadmemberships
    ADD CONSTRAINT threadmemberships_pkey PRIMARY KEY (postid, userid);


--
-- TOC entry 3701 (class 2606 OID 16778)
-- Name: threads threads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (postid);


--
-- TOC entry 3653 (class 2606 OID 16663)
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (token);


--
-- TOC entry 3698 (class 2606 OID 16767)
-- Name: uploadsessions uploadsessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploadsessions
    ADD CONSTRAINT uploadsessions_pkey PRIMARY KEY (id);


--
-- TOC entry 3658 (class 2606 OID 16679)
-- Name: useraccesstokens useraccesstokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.useraccesstokens
    ADD CONSTRAINT useraccesstokens_pkey PRIMARY KEY (id);


--
-- TOC entry 3660 (class 2606 OID 16681)
-- Name: useraccesstokens useraccesstokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.useraccesstokens
    ADD CONSTRAINT useraccesstokens_token_key UNIQUE (token);


--
-- TOC entry 3553 (class 2606 OID 16462)
-- Name: usergroups usergroups_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usergroups
    ADD CONSTRAINT usergroups_name_key UNIQUE (name);


--
-- TOC entry 3555 (class 2606 OID 16460)
-- Name: usergroups usergroups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usergroups
    ADD CONSTRAINT usergroups_pkey PRIMARY KEY (id);


--
-- TOC entry 3557 (class 2606 OID 16464)
-- Name: usergroups usergroups_source_remoteid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usergroups
    ADD CONSTRAINT usergroups_source_remoteid_key UNIQUE (source, remoteid);


--
-- TOC entry 3724 (class 2606 OID 16813)
-- Name: users users_authdata_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_authdata_key UNIQUE (authdata);


--
-- TOC entry 3726 (class 2606 OID 16815)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3728 (class 2606 OID 16809)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3730 (class 2606 OID 16811)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3708 (class 2606 OID 16792)
-- Name: usertermsofservice usertermsofservice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usertermsofservice
    ADD CONSTRAINT usertermsofservice_pkey PRIMARY KEY (userid);


--
-- TOC entry 3638 (class 1259 OID 16630)
-- Name: idx_audits_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audits_user_id ON public.audits USING btree (userid);


--
-- TOC entry 3863 (class 1259 OID 17533)
-- Name: idx_calls_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calls_channel_id ON public.calls USING btree (channelid);


--
-- TOC entry 3864 (class 1259 OID 17534)
-- Name: idx_calls_end_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calls_end_at ON public.calls USING btree (endat);


--
-- TOC entry 3870 (class 1259 OID 17567)
-- Name: idx_calls_jobs_call_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calls_jobs_call_id ON public.calls_jobs USING btree (callid);


--
-- TOC entry 3867 (class 1259 OID 17543)
-- Name: idx_calls_sessions_call_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calls_sessions_call_id ON public.calls_sessions USING btree (callid);


--
-- TOC entry 3749 (class 1259 OID 16874)
-- Name: idx_channel_search_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channel_search_txt ON public.channels USING gin (to_tsvector('english'::regconfig, (((((name)::text || ' '::text) || (displayname)::text) || ' '::text) || (purpose)::text)));


--
-- TOC entry 3807 (class 1259 OID 17261)
-- Name: idx_channelbookmarks_channelid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelbookmarks_channelid ON public.channelbookmarks USING btree (channelid);


--
-- TOC entry 3808 (class 1259 OID 17263)
-- Name: idx_channelbookmarks_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelbookmarks_delete_at ON public.channelbookmarks USING btree (deleteat);


--
-- TOC entry 3809 (class 1259 OID 17262)
-- Name: idx_channelbookmarks_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelbookmarks_update_at ON public.channelbookmarks USING btree (updateat);


--
-- TOC entry 3760 (class 1259 OID 16940)
-- Name: idx_channelmembers_channel_id_scheme_guest_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelmembers_channel_id_scheme_guest_user_id ON public.channelmembers USING btree (channelid, schemeguest, userid);


--
-- TOC entry 3761 (class 1259 OID 16939)
-- Name: idx_channelmembers_user_id_channel_id_last_viewed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channelmembers_user_id_channel_id_last_viewed_at ON public.channelmembers USING btree (userid, channelid, lastviewedat);


--
-- TOC entry 3750 (class 1259 OID 16872)
-- Name: idx_channels_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_create_at ON public.channels USING btree (createat);


--
-- TOC entry 3751 (class 1259 OID 16871)
-- Name: idx_channels_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_delete_at ON public.channels USING btree (deleteat);


--
-- TOC entry 3752 (class 1259 OID 16866)
-- Name: idx_channels_displayname_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_displayname_lower ON public.channels USING btree (lower((displayname)::text));


--
-- TOC entry 3753 (class 1259 OID 16867)
-- Name: idx_channels_name_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_name_lower ON public.channels USING btree (lower((name)::text));


--
-- TOC entry 3754 (class 1259 OID 16875)
-- Name: idx_channels_scheme_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_scheme_id ON public.channels USING btree (schemeid);


--
-- TOC entry 3755 (class 1259 OID 16929)
-- Name: idx_channels_team_id_display_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_team_id_display_name ON public.channels USING btree (teamid, displayname);


--
-- TOC entry 3756 (class 1259 OID 17097)
-- Name: idx_channels_team_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_team_id_type ON public.channels USING btree (teamid, type);


--
-- TOC entry 3757 (class 1259 OID 16869)
-- Name: idx_channels_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_channels_update_at ON public.channels USING btree (updateat);


--
-- TOC entry 3574 (class 1259 OID 16505)
-- Name: idx_command_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_create_at ON public.commands USING btree (createat);


--
-- TOC entry 3575 (class 1259 OID 16506)
-- Name: idx_command_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_delete_at ON public.commands USING btree (deleteat);


--
-- TOC entry 3576 (class 1259 OID 16503)
-- Name: idx_command_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_team_id ON public.commands USING btree (teamid);


--
-- TOC entry 3577 (class 1259 OID 16504)
-- Name: idx_command_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_update_at ON public.commands USING btree (updateat);


--
-- TOC entry 3539 (class 1259 OID 16434)
-- Name: idx_command_webhook_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_command_webhook_create_at ON public.commandwebhooks USING btree (createat);


--
-- TOC entry 3797 (class 1259 OID 17203)
-- Name: idx_desktoptokens_token_createat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_desktoptokens_token_createat ON public.desktoptokens USING btree (token, createat);


--
-- TOC entry 3546 (class 1259 OID 16451)
-- Name: idx_emoji_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emoji_create_at ON public.emoji USING btree (createat);


--
-- TOC entry 3547 (class 1259 OID 16452)
-- Name: idx_emoji_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emoji_delete_at ON public.emoji USING btree (deleteat);


--
-- TOC entry 3548 (class 1259 OID 16450)
-- Name: idx_emoji_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emoji_update_at ON public.emoji USING btree (updateat);


--
-- TOC entry 3733 (class 1259 OID 17192)
-- Name: idx_fileinfo_channel_id_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_channel_id_create_at ON public.fileinfo USING btree (channelid, createat);


--
-- TOC entry 3734 (class 1259 OID 16843)
-- Name: idx_fileinfo_content_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_content_txt ON public.fileinfo USING gin (to_tsvector('english'::regconfig, content));


--
-- TOC entry 3735 (class 1259 OID 16838)
-- Name: idx_fileinfo_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_create_at ON public.fileinfo USING btree (createat);


--
-- TOC entry 3736 (class 1259 OID 16839)
-- Name: idx_fileinfo_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_delete_at ON public.fileinfo USING btree (deleteat);


--
-- TOC entry 3737 (class 1259 OID 16841)
-- Name: idx_fileinfo_extension_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_extension_at ON public.fileinfo USING btree (extension);


--
-- TOC entry 3738 (class 1259 OID 16844)
-- Name: idx_fileinfo_name_splitted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_name_splitted ON public.fileinfo USING gin (to_tsvector('english'::regconfig, translate((name)::text, '.,-'::text, '   '::text)));


--
-- TOC entry 3739 (class 1259 OID 16842)
-- Name: idx_fileinfo_name_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_name_txt ON public.fileinfo USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- TOC entry 3740 (class 1259 OID 16840)
-- Name: idx_fileinfo_postid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_postid_at ON public.fileinfo USING btree (postid);


--
-- TOC entry 3741 (class 1259 OID 16837)
-- Name: idx_fileinfo_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fileinfo_update_at ON public.fileinfo USING btree (updateat);


--
-- TOC entry 3567 (class 1259 OID 16485)
-- Name: idx_groupchannels_channelid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupchannels_channelid ON public.groupchannels USING btree (channelid);


--
-- TOC entry 3568 (class 1259 OID 17045)
-- Name: idx_groupchannels_schemeadmin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupchannels_schemeadmin ON public.groupchannels USING btree (schemeadmin);


--
-- TOC entry 3560 (class 1259 OID 16472)
-- Name: idx_groupmembers_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupmembers_create_at ON public.groupmembers USING btree (createat);


--
-- TOC entry 3563 (class 1259 OID 16478)
-- Name: idx_groupteams_schemeadmin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupteams_schemeadmin ON public.groupteams USING btree (schemeadmin);


--
-- TOC entry 3564 (class 1259 OID 16479)
-- Name: idx_groupteams_teamid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_groupteams_teamid ON public.groupteams USING btree (teamid);


--
-- TOC entry 3578 (class 1259 OID 16515)
-- Name: idx_incoming_webhook_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_create_at ON public.incomingwebhooks USING btree (createat);


--
-- TOC entry 3579 (class 1259 OID 16516)
-- Name: idx_incoming_webhook_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_delete_at ON public.incomingwebhooks USING btree (deleteat);


--
-- TOC entry 3580 (class 1259 OID 16513)
-- Name: idx_incoming_webhook_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_team_id ON public.incomingwebhooks USING btree (teamid);


--
-- TOC entry 3581 (class 1259 OID 16514)
-- Name: idx_incoming_webhook_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_update_at ON public.incomingwebhooks USING btree (updateat);


--
-- TOC entry 3582 (class 1259 OID 16512)
-- Name: idx_incoming_webhook_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incoming_webhook_user_id ON public.incomingwebhooks USING btree (userid);


--
-- TOC entry 3685 (class 1259 OID 17064)
-- Name: idx_jobs_status_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_jobs_status_type ON public.jobs USING btree (status, type);


--
-- TOC entry 3686 (class 1259 OID 16747)
-- Name: idx_jobs_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_jobs_type ON public.jobs USING btree (type);


--
-- TOC entry 3569 (class 1259 OID 16494)
-- Name: idx_link_metadata_url_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_link_metadata_url_timestamp ON public.linkmetadata USING btree (url, "timestamp");


--
-- TOC entry 3623 (class 1259 OID 16599)
-- Name: idx_notice_views_notice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notice_views_notice_id ON public.productnoticeviewstate USING btree (noticeid);


--
-- TOC entry 3624 (class 1259 OID 16600)
-- Name: idx_notice_views_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notice_views_timestamp ON public.productnoticeviewstate USING btree ("timestamp");


--
-- TOC entry 3639 (class 1259 OID 16636)
-- Name: idx_oauthaccessdata_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_oauthaccessdata_refresh_token ON public.oauthaccessdata USING btree (refreshtoken);


--
-- TOC entry 3640 (class 1259 OID 16637)
-- Name: idx_oauthaccessdata_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_oauthaccessdata_user_id ON public.oauthaccessdata USING btree (userid);


--
-- TOC entry 3742 (class 1259 OID 16853)
-- Name: idx_oauthapps_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_oauthapps_creator_id ON public.oauthapps USING btree (creatorid);


--
-- TOC entry 3585 (class 1259 OID 16530)
-- Name: idx_outgoing_webhook_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoing_webhook_create_at ON public.outgoingwebhooks USING btree (createat);


--
-- TOC entry 3586 (class 1259 OID 16531)
-- Name: idx_outgoing_webhook_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoing_webhook_delete_at ON public.outgoingwebhooks USING btree (deleteat);


--
-- TOC entry 3587 (class 1259 OID 16528)
-- Name: idx_outgoing_webhook_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoing_webhook_team_id ON public.outgoingwebhooks USING btree (teamid);


--
-- TOC entry 3588 (class 1259 OID 16529)
-- Name: idx_outgoing_webhook_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoing_webhook_update_at ON public.outgoingwebhooks USING btree (updateat);


--
-- TOC entry 3802 (class 1259 OID 17232)
-- Name: idx_outgoingoauthconnections_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outgoingoauthconnections_name ON public.outgoingoauthconnections USING btree (name);


--
-- TOC entry 3782 (class 1259 OID 17155)
-- Name: idx_postreminders_targettime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_postreminders_targettime ON public.postreminders USING btree (targettime);


--
-- TOC entry 3609 (class 1259 OID 16591)
-- Name: idx_posts_channel_id_delete_at_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_channel_id_delete_at_create_at ON public.posts USING btree (channelid, deleteat, createat);


--
-- TOC entry 3610 (class 1259 OID 16590)
-- Name: idx_posts_channel_id_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_channel_id_update_at ON public.posts USING btree (channelid, updateat);


--
-- TOC entry 3611 (class 1259 OID 16585)
-- Name: idx_posts_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_create_at ON public.posts USING btree (createat);


--
-- TOC entry 3612 (class 1259 OID 17073)
-- Name: idx_posts_create_at_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_create_at_id ON public.posts USING btree (createat, id);


--
-- TOC entry 3613 (class 1259 OID 16586)
-- Name: idx_posts_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_delete_at ON public.posts USING btree (deleteat);


--
-- TOC entry 3614 (class 1259 OID 16593)
-- Name: idx_posts_hashtags_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_hashtags_txt ON public.posts USING gin (to_tsvector('english'::regconfig, (hashtags)::text));


--
-- TOC entry 3615 (class 1259 OID 16589)
-- Name: idx_posts_is_pinned; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_is_pinned ON public.posts USING btree (ispinned);


--
-- TOC entry 3616 (class 1259 OID 16592)
-- Name: idx_posts_message_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_message_txt ON public.posts USING gin (to_tsvector('english'::regconfig, (message)::text));


--
-- TOC entry 3617 (class 1259 OID 17187)
-- Name: idx_posts_original_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_original_id ON public.posts USING btree (originalid);


--
-- TOC entry 3618 (class 1259 OID 17063)
-- Name: idx_posts_root_id_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_root_id_delete_at ON public.posts USING btree (rootid, deleteat);


--
-- TOC entry 3619 (class 1259 OID 16584)
-- Name: idx_posts_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_update_at ON public.posts USING btree (updateat);


--
-- TOC entry 3620 (class 1259 OID 16588)
-- Name: idx_posts_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_posts_user_id ON public.posts USING btree (userid);


--
-- TOC entry 3801 (class 1259 OID 17235)
-- Name: idx_poststats_userid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_poststats_userid ON public.poststats USING btree (userid);


--
-- TOC entry 3645 (class 1259 OID 16648)
-- Name: idx_preferences_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_preferences_category ON public.preferences USING btree (category);


--
-- TOC entry 3646 (class 1259 OID 16649)
-- Name: idx_preferences_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_preferences_name ON public.preferences USING btree (name);


--
-- TOC entry 3817 (class 1259 OID 17334)
-- Name: idx_propertyfields_create_at_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyfields_create_at_id ON public.propertyfields USING btree (createat, id);


--
-- TOC entry 3818 (class 1259 OID 17305)
-- Name: idx_propertyfields_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_propertyfields_unique ON public.propertyfields USING btree (groupid, targetid, name) WHERE (deleteat = 0);


--
-- TOC entry 3821 (class 1259 OID 17333)
-- Name: idx_propertyvalues_create_at_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyvalues_create_at_id ON public.propertyvalues USING btree (createat, id);


--
-- TOC entry 3822 (class 1259 OID 17315)
-- Name: idx_propertyvalues_targetid_groupid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_propertyvalues_targetid_groupid ON public.propertyvalues USING btree (targetid, groupid);


--
-- TOC entry 3823 (class 1259 OID 17314)
-- Name: idx_propertyvalues_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_propertyvalues_unique ON public.propertyvalues USING btree (groupid, targetid, fieldid) WHERE (deleteat = 0);


--
-- TOC entry 3762 (class 1259 OID 16897)
-- Name: idx_publicchannels_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_delete_at ON public.publicchannels USING btree (deleteat);


--
-- TOC entry 3763 (class 1259 OID 16899)
-- Name: idx_publicchannels_displayname_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_displayname_lower ON public.publicchannels USING btree (lower((displayname)::text));


--
-- TOC entry 3764 (class 1259 OID 16898)
-- Name: idx_publicchannels_name_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_name_lower ON public.publicchannels USING btree (lower((name)::text));


--
-- TOC entry 3765 (class 1259 OID 16900)
-- Name: idx_publicchannels_search_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_search_txt ON public.publicchannels USING gin (to_tsvector('english'::regconfig, (((((name)::text || ' '::text) || (displayname)::text) || ' '::text) || (purpose)::text)));


--
-- TOC entry 3766 (class 1259 OID 16895)
-- Name: idx_publicchannels_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicchannels_team_id ON public.publicchannels USING btree (teamid);


--
-- TOC entry 3593 (class 1259 OID 17087)
-- Name: idx_reactions_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reactions_channel_id ON public.reactions USING btree (channelid);


--
-- TOC entry 3798 (class 1259 OID 17212)
-- Name: idx_retentionidsfordeletion_tablename; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_retentionidsfordeletion_tablename ON public.retentionidsfordeletion USING btree (tablename);


--
-- TOC entry 3771 (class 1259 OID 16928)
-- Name: idx_retentionpolicies_displayname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_retentionpolicies_displayname ON public.retentionpolicies USING btree (displayname);


--
-- TOC entry 3777 (class 1259 OID 16927)
-- Name: idx_retentionpolicieschannels_policyid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_retentionpolicieschannels_policyid ON public.retentionpolicieschannels USING btree (policyid);


--
-- TOC entry 3774 (class 1259 OID 16926)
-- Name: idx_retentionpoliciesteams_policyid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_retentionpoliciesteams_policyid ON public.retentionpoliciesteams USING btree (policyid);


--
-- TOC entry 3810 (class 1259 OID 17275)
-- Name: idx_scheduledposts_userid_channel_id_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_scheduledposts_userid_channel_id_scheduled_at ON public.scheduledposts USING btree (userid, channelid, scheduledat);


--
-- TOC entry 3600 (class 1259 OID 16567)
-- Name: idx_schemes_channel_admin_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schemes_channel_admin_role ON public.schemes USING btree (defaultchanneladminrole);


--
-- TOC entry 3601 (class 1259 OID 16565)
-- Name: idx_schemes_channel_guest_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schemes_channel_guest_role ON public.schemes USING btree (defaultchannelguestrole);


--
-- TOC entry 3602 (class 1259 OID 16566)
-- Name: idx_schemes_channel_user_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_schemes_channel_user_role ON public.schemes USING btree (defaultchanneluserrole);


--
-- TOC entry 3627 (class 1259 OID 16612)
-- Name: idx_sessions_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_create_at ON public.sessions USING btree (createat);


--
-- TOC entry 3628 (class 1259 OID 16611)
-- Name: idx_sessions_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_expires_at ON public.sessions USING btree (expiresat);


--
-- TOC entry 3629 (class 1259 OID 16613)
-- Name: idx_sessions_last_activity_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_last_activity_at ON public.sessions USING btree (lastactivityat);


--
-- TOC entry 3630 (class 1259 OID 16610)
-- Name: idx_sessions_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_token ON public.sessions USING btree (token);


--
-- TOC entry 3631 (class 1259 OID 16609)
-- Name: idx_sessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_user_id ON public.sessions USING btree (userid);


--
-- TOC entry 3676 (class 1259 OID 16731)
-- Name: idx_sharedchannelusers_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sharedchannelusers_remote_id ON public.sharedchannelusers USING btree (remoteid);


--
-- TOC entry 3691 (class 1259 OID 17085)
-- Name: idx_sidebarcategories_userid_teamid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sidebarcategories_userid_teamid ON public.sidebarcategories USING btree (userid, teamid);


--
-- TOC entry 3667 (class 1259 OID 17351)
-- Name: idx_sidebarchannels_categoryid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sidebarchannels_categoryid ON public.sidebarchannels USING btree (categoryid);


--
-- TOC entry 3649 (class 1259 OID 17044)
-- Name: idx_status_status_dndendtime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_status_status_dndendtime ON public.status USING btree (status, dndendtime);


--
-- TOC entry 3530 (class 1259 OID 17157)
-- Name: idx_teammembers_createat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teammembers_createat ON public.teammembers USING btree (createat);


--
-- TOC entry 3531 (class 1259 OID 16420)
-- Name: idx_teammembers_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teammembers_delete_at ON public.teammembers USING btree (deleteat);


--
-- TOC entry 3532 (class 1259 OID 16419)
-- Name: idx_teammembers_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teammembers_user_id ON public.teammembers USING btree (userid);


--
-- TOC entry 3521 (class 1259 OID 16410)
-- Name: idx_teams_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_create_at ON public.teams USING btree (createat);


--
-- TOC entry 3522 (class 1259 OID 16411)
-- Name: idx_teams_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_delete_at ON public.teams USING btree (deleteat);


--
-- TOC entry 3523 (class 1259 OID 16408)
-- Name: idx_teams_invite_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_invite_id ON public.teams USING btree (inviteid);


--
-- TOC entry 3524 (class 1259 OID 16413)
-- Name: idx_teams_scheme_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_scheme_id ON public.teams USING btree (schemeid);


--
-- TOC entry 3525 (class 1259 OID 16409)
-- Name: idx_teams_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_teams_update_at ON public.teams USING btree (updateat);


--
-- TOC entry 3702 (class 1259 OID 16785)
-- Name: idx_thread_memberships_last_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thread_memberships_last_update_at ON public.threadmemberships USING btree (lastupdated);


--
-- TOC entry 3703 (class 1259 OID 16786)
-- Name: idx_thread_memberships_last_view_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thread_memberships_last_view_at ON public.threadmemberships USING btree (lastviewed);


--
-- TOC entry 3704 (class 1259 OID 16787)
-- Name: idx_thread_memberships_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_thread_memberships_user_id ON public.threadmemberships USING btree (userid);


--
-- TOC entry 3699 (class 1259 OID 17043)
-- Name: idx_threads_channel_id_last_reply_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_threads_channel_id_last_reply_at ON public.threads USING btree (channelid, lastreplyat);


--
-- TOC entry 3694 (class 1259 OID 16769)
-- Name: idx_uploadsessions_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_uploadsessions_create_at ON public.uploadsessions USING btree (createat);


--
-- TOC entry 3695 (class 1259 OID 17139)
-- Name: idx_uploadsessions_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_uploadsessions_type ON public.uploadsessions USING btree (type);


--
-- TOC entry 3696 (class 1259 OID 16768)
-- Name: idx_uploadsessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_uploadsessions_user_id ON public.uploadsessions USING btree (userid);


--
-- TOC entry 3656 (class 1259 OID 16682)
-- Name: idx_user_access_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_access_tokens_user_id ON public.useraccesstokens USING btree (userid);


--
-- TOC entry 3549 (class 1259 OID 16466)
-- Name: idx_usergroups_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usergroups_delete_at ON public.usergroups USING btree (deleteat);


--
-- TOC entry 3550 (class 1259 OID 17072)
-- Name: idx_usergroups_displayname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usergroups_displayname ON public.usergroups USING btree (displayname);


--
-- TOC entry 3551 (class 1259 OID 16465)
-- Name: idx_usergroups_remote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usergroups_remote_id ON public.usergroups USING btree (remoteid);


--
-- TOC entry 3711 (class 1259 OID 16826)
-- Name: idx_users_all_no_full_name_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_all_no_full_name_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((((username)::text || ' '::text) || (nickname)::text) || ' '::text) || (email)::text)));


--
-- TOC entry 3712 (class 1259 OID 16825)
-- Name: idx_users_all_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_all_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((((((((username)::text || ' '::text) || (firstname)::text) || ' '::text) || (lastname)::text) || ' '::text) || (nickname)::text) || ' '::text) || (email)::text)));


--
-- TOC entry 3713 (class 1259 OID 16818)
-- Name: idx_users_create_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_create_at ON public.users USING btree (createat);


--
-- TOC entry 3714 (class 1259 OID 16819)
-- Name: idx_users_delete_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_delete_at ON public.users USING btree (deleteat);


--
-- TOC entry 3715 (class 1259 OID 16820)
-- Name: idx_users_email_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email_lower_textpattern ON public.users USING btree (lower((email)::text) text_pattern_ops);


--
-- TOC entry 3716 (class 1259 OID 16823)
-- Name: idx_users_firstname_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_firstname_lower_textpattern ON public.users USING btree (lower((firstname)::text) text_pattern_ops);


--
-- TOC entry 3717 (class 1259 OID 16824)
-- Name: idx_users_lastname_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_lastname_lower_textpattern ON public.users USING btree (lower((lastname)::text) text_pattern_ops);


--
-- TOC entry 3718 (class 1259 OID 16828)
-- Name: idx_users_names_no_full_name_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_names_no_full_name_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((username)::text || ' '::text) || (nickname)::text)));


--
-- TOC entry 3719 (class 1259 OID 16827)
-- Name: idx_users_names_txt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_names_txt ON public.users USING gin (to_tsvector('english'::regconfig, (((((((username)::text || ' '::text) || (firstname)::text) || ' '::text) || (lastname)::text) || ' '::text) || (nickname)::text)));


--
-- TOC entry 3720 (class 1259 OID 16822)
-- Name: idx_users_nickname_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_nickname_lower_textpattern ON public.users USING btree (lower((nickname)::text) text_pattern_ops);


--
-- TOC entry 3721 (class 1259 OID 16817)
-- Name: idx_users_update_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_update_at ON public.users USING btree (updateat);


--
-- TOC entry 3722 (class 1259 OID 16821)
-- Name: idx_users_username_lower_textpattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_username_lower_textpattern ON public.users USING btree (lower((username)::text) text_pattern_ops);


--
-- TOC entry 3894 (class 1259 OID 18639)
-- Name: ir_category_item_categoryid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_category_item_categoryid ON public.ir_category_item USING btree (categoryid);


--
-- TOC entry 3893 (class 1259 OID 17839)
-- Name: ir_category_teamid_userid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_category_teamid_userid ON public.ir_category USING btree (teamid, userid);


--
-- TOC entry 3888 (class 1259 OID 17688)
-- Name: ir_channelaction_channelid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_channelaction_channelid ON public.ir_channelaction USING btree (channelid);


--
-- TOC entry 3832 (class 1259 OID 18038)
-- Name: ir_incident_channelid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_incident_channelid ON public.ir_incident USING btree (channelid);


--
-- TOC entry 3835 (class 1259 OID 18023)
-- Name: ir_incident_teamid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_incident_teamid ON public.ir_incident USING btree (teamid);


--
-- TOC entry 3836 (class 1259 OID 18024)
-- Name: ir_incident_teamid_commanderuserid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_incident_teamid_commanderuserid ON public.ir_incident USING btree (teamid, commanderuserid);


--
-- TOC entry 3884 (class 1259 OID 17850)
-- Name: ir_metric_incidentid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_metric_incidentid ON public.ir_metric USING btree (incidentid);


--
-- TOC entry 3885 (class 1259 OID 17867)
-- Name: ir_metric_metricconfigid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_metric_metricconfigid ON public.ir_metric USING btree (metricconfigid);


--
-- TOC entry 3883 (class 1259 OID 17894)
-- Name: ir_metricconfig_playbookid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_metricconfig_playbookid ON public.ir_metricconfig USING btree (playbookid);


--
-- TOC entry 3839 (class 1259 OID 18469)
-- Name: ir_playbook_teamid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_playbook_teamid ON public.ir_playbook USING btree (teamid);


--
-- TOC entry 3840 (class 1259 OID 17579)
-- Name: ir_playbook_updateat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_playbook_updateat ON public.ir_playbook USING btree (updateat);


--
-- TOC entry 3841 (class 1259 OID 18378)
-- Name: ir_playbookmember_memberid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_playbookmember_memberid ON public.ir_playbookmember USING btree (memberid);


--
-- TOC entry 3844 (class 1259 OID 18358)
-- Name: ir_playbookmember_playbookid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_playbookmember_playbookid ON public.ir_playbookmember USING btree (playbookid);


--
-- TOC entry 3875 (class 1259 OID 18413)
-- Name: ir_run_participants_incidentid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_run_participants_incidentid ON public.ir_run_participants USING btree (incidentid);


--
-- TOC entry 3878 (class 1259 OID 18401)
-- Name: ir_run_participants_userid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_run_participants_userid ON public.ir_run_participants USING btree (userid);


--
-- TOC entry 3847 (class 1259 OID 18280)
-- Name: ir_statusposts_incidentid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_statusposts_incidentid ON public.ir_statusposts USING btree (incidentid);


--
-- TOC entry 3852 (class 1259 OID 18300)
-- Name: ir_statusposts_postid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_statusposts_postid ON public.ir_statusposts USING btree (postid);


--
-- TOC entry 3857 (class 1259 OID 17722)
-- Name: ir_timelineevent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_timelineevent_id ON public.ir_timelineevent USING btree (id);


--
-- TOC entry 3858 (class 1259 OID 17732)
-- Name: ir_timelineevent_incidentid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ir_timelineevent_incidentid ON public.ir_timelineevent USING btree (incidentid);


--
-- TOC entry 3898 (class 2606 OID 16921)
-- Name: retentionpolicieschannels fk_retentionpolicieschannels_retentionpolicies; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpolicieschannels
    ADD CONSTRAINT fk_retentionpolicieschannels_retentionpolicies FOREIGN KEY (policyid) REFERENCES public.retentionpolicies(id) ON DELETE CASCADE;


--
-- TOC entry 3897 (class 2606 OID 16916)
-- Name: retentionpoliciesteams fk_retentionpoliciesteams_retentionpolicies; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.retentionpoliciesteams
    ADD CONSTRAINT fk_retentionpoliciesteams_retentionpolicies FOREIGN KEY (policyid) REFERENCES public.retentionpolicies(id) ON DELETE CASCADE;


--
-- TOC entry 3907 (class 2606 OID 18640)
-- Name: ir_category_item ir_category_item_categoryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_category_item
    ADD CONSTRAINT ir_category_item_categoryid_fkey FOREIGN KEY (categoryid) REFERENCES public.ir_category(id);


--
-- TOC entry 3905 (class 2606 OID 17973)
-- Name: ir_metric ir_metric_incidentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_metric
    ADD CONSTRAINT ir_metric_incidentid_fkey FOREIGN KEY (incidentid) REFERENCES public.ir_incident(id);


--
-- TOC entry 3906 (class 2606 OID 17881)
-- Name: ir_metric ir_metric_metricconfigid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_metric
    ADD CONSTRAINT ir_metric_metricconfigid_fkey FOREIGN KEY (metricconfigid) REFERENCES public.ir_metricconfig(id);


--
-- TOC entry 3904 (class 2606 OID 18427)
-- Name: ir_metricconfig ir_metricconfig_playbookid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_metricconfig
    ADD CONSTRAINT ir_metricconfig_playbookid_fkey FOREIGN KEY (playbookid) REFERENCES public.ir_playbook(id);


--
-- TOC entry 3903 (class 2606 OID 18432)
-- Name: ir_playbookautofollow ir_playbookautofollow_playbookid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_playbookautofollow
    ADD CONSTRAINT ir_playbookautofollow_playbookid_fkey FOREIGN KEY (playbookid) REFERENCES public.ir_playbook(id);


--
-- TOC entry 3899 (class 2606 OID 18437)
-- Name: ir_playbookmember ir_playbookmember_playbookid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_playbookmember
    ADD CONSTRAINT ir_playbookmember_playbookid_fkey FOREIGN KEY (playbookid) REFERENCES public.ir_playbook(id);


--
-- TOC entry 3902 (class 2606 OID 18414)
-- Name: ir_run_participants ir_run_participants_incidentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_run_participants
    ADD CONSTRAINT ir_run_participants_incidentid_fkey FOREIGN KEY (incidentid) REFERENCES public.ir_incident(id);


--
-- TOC entry 3900 (class 2606 OID 18281)
-- Name: ir_statusposts ir_statusposts_incidentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_statusposts
    ADD CONSTRAINT ir_statusposts_incidentid_fkey FOREIGN KEY (incidentid) REFERENCES public.ir_incident(id);


--
-- TOC entry 3901 (class 2606 OID 17968)
-- Name: ir_timelineevent ir_timelineevent_incidentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ir_timelineevent
    ADD CONSTRAINT ir_timelineevent_incidentid_fkey FOREIGN KEY (incidentid) REFERENCES public.ir_incident(id);


--
-- TOC entry 4120 (class 0 OID 17353)
-- Dependencies: 277 4142
-- Name: attributeview; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.attributeview;


--
-- TOC entry 4116 (class 0 OID 17321)
-- Dependencies: 273 4142
-- Name: bot_posts_by_team_day; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.bot_posts_by_team_day;


--
-- TOC entry 4117 (class 0 OID 17326)
-- Dependencies: 274 4142
-- Name: file_stats; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.file_stats;


--
-- TOC entry 4115 (class 0 OID 17316)
-- Dependencies: 272 4142
-- Name: posts_by_team_day; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.posts_by_team_day;


--
-- TOC entry 4108 (class 0 OID 17214)
-- Dependencies: 265 4142
-- Name: poststats; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.poststats;


-- Completed on 2025-07-16 09:10:19

--
-- PostgreSQL database dump complete
--

