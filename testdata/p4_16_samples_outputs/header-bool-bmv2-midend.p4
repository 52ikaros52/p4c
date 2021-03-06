#include <core.p4>
#include <v1model.p4>

header Hdr1 {
    bit<7> a;
    bool   x;
}

header Hdr2 {
    bit<16> b;
}

header_union U {
    Hdr1 h1;
    Hdr2 h2;
}

struct Headers {
    Hdr1 h1;
    U    u;
}

struct Meta {
}

parser p(packet_in b, out Headers h, inout Meta m, inout standard_metadata_t sm) {
    state start {
        b.extract<Hdr1>(h.h1);
        transition select(h.h1.a) {
            7w0: getH1;
            default: getH2;
        }
    }
    state getH1 {
        b.extract<Hdr1>(h.u.h1);
        transition accept;
    }
    state getH2 {
        b.extract<Hdr2>(h.u.h2);
        transition accept;
    }
}

control vrfy(inout Headers h, inout Meta m) {
    apply {
    }
}

control update(inout Headers h, inout Meta m) {
    apply {
    }
}

control egress(inout Headers h, inout Meta m, inout standard_metadata_t sm) {
    @hidden action headerboolbmv2l67() {
        h.u.h1.x = true;
    }
    @hidden table tbl_headerboolbmv2l67 {
        actions = {
            headerboolbmv2l67();
        }
        const default_action = headerboolbmv2l67();
    }
    apply {
        tbl_headerboolbmv2l67.apply();
    }
}

control deparser(packet_out b, in Headers h) {
    apply {
        b.emit<Hdr1>(h.h1);
        b.emit<Hdr1>(h.u.h1);
        b.emit<Hdr2>(h.u.h2);
    }
}

control ingress(inout Headers h, inout Meta m, inout standard_metadata_t sm) {
    @hidden action headerboolbmv2l81() {
        h.u.h2.setInvalid();
    }
    @hidden table tbl_headerboolbmv2l81 {
        actions = {
            headerboolbmv2l81();
        }
        const default_action = headerboolbmv2l81();
    }
    apply {
        if (h.u.h2.isValid()) {
            tbl_headerboolbmv2l81.apply();
        }
    }
}

V1Switch<Headers, Meta>(p(), vrfy(), ingress(), egress(), update(), deparser()) main;

