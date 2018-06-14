import base_types as bt

proto = bt.Protocol()

# typedefs
packet_type = bt.Typedef("packet_type", bt.Array(bt.Bit(), 7))
version = bt.Typedef("version", bt.Array(bt.Bit(), 32))
cid_len = bt.Typedef("cid_len", bt.Array(bt.Bit(), 4))
full_packet_num = bt.Typedef("full_packet_num", bt.Array(bt.Bit(), 62))
frame_type = bt.Typedef("frame_type", bt.Array(bt.Bit(), 8))
cryptobit = bt.Typedef("cryptobit", bt.Bit())

# var_enc struct
var_enc = bt.Structure()
var_enc.add_element("length", bt.Array(bt.Bit(), 2))
var_enc.add_element("value", bt.Array(bt.Bit(), "undefined"))
proto.add_struct("var_enc", var_enc)

# packet_num enum
packet_num = bt.Structure()
proto.add_struct("packet_num", packet_num)
# skipping for now, because there's no support for contraints
# but ultimately, enums will be syntactic sugar over Structures

# long_hdr struct
long_hdr = bt.Structure()
long_hdr.add_element("header", bt.Bit())
long_hdr.add_element("type", packet_type)
long_hdr.add_element("ver", version)
long_hdr.add_element("dcid_len", cid_len)
long_hdr.add_element("scid_len", cid_len)
long_hdr.add_element("dcid", bt.Array(bt.Bit(), "undefined"))
long_hdr.add_element("scid", bt.Array(bt.Bit(), "undefined"))
long_hdr.add_element("payload_length", var_enc)
long_hdr.add_element("payload", bt.Array(bt.Bit(), "undefined"))
proto.add_struct("long_hdr", long_hdr)

# short_hdr struct
short_hdr = bt.Structure()
short_hdr.add_element("header_type", bt.Bit())
short_hdr.add_element("key_phase", bt.Bit())
short_hdr.add_element("third_bit", bt.Bit())
short_hdr.add_element("forth_bit", bt.Bit())
short_hdr.add_element("google_demux", bt.Bit())
short_hdr.add_element("reserved", bt.Array(bt.Bit(), 3))
short_hdr.add_element("dcid", bt.Bit())
short_hdr.add_element("packet_number", packet_num)
short_hdr.add_element("protected_payload", bt.Array(cryptobit, "undefined"))
proto.add_struct("short_hdr", short_hdr)

# version_negotiation struct
version_negotiation = bt.Structure()
version_negotiation.add_element("header_type", bt.Bit())
version_negotiation.add_element("unused", bt.Array(bt.Bit(), 7))
version_negotiation.add_element("ver", version)
version_negotiation.add_element("dcid_len", cid_len)
version_negotiation.add_element("scid_len", cid_len)
version_negotiation.add_element("dcid", bt.Array(bt.Bit(), "undefined"))
version_negotiation.add_element("scid", bt.Array(bt.Bit(), "undefined"))
version_negotiation.add_element("supported_versions", bt.Array(version, "undefined"))
proto.add_struct("version_negotiation", version_negotiation)

# quic_pdu enum
quic_pdu = bt.Choice()
quic_pdu.add_alternate(long_hdr)
quic_pdu.add_alternate(short_hdr)
quic_pdu.add_alternate(version_negotiation)
proto.add_choice("quic_pdu", quic_pdu)

# padding_frame struct
padding_frame = bt.Structure()
padding_frame.add_element("type", frame_type)
proto.add_struct("padding_frame", padding_frame)
