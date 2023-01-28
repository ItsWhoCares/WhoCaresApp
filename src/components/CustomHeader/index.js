import { View, Text, Image, StyleSheet } from "react-native";
import React from "react";
import { AntDesign } from "@expo/vector-icons";
import { useNavigation, CommonActions } from "@react-navigation/native";

import { auth } from "../../../firebase";
import { supabase } from "../../initSupabase";

import {
  getUserChatRoomLastSeen,
  getCommonChatRoom,
  updateUserChatRoomLastSeenAt,
} from "../../../supabaseQueries";
// import { set } from "react-hook-form";

import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import { myColors } from "../../../colors";
dayjs.extend(relativeTime);

const admin = "usOWdwZr9XeOwdkIyjbJixXDmC12";

const CustomHeader = ({ image, oUser, getTypingMessage }) => {
  const navigation = useNavigation();
  const [userOnline, setUserOnline] = React.useState(undefined);
  const [otherUser, setOtherUser] = React.useState(oUser);
  const [lastSeenAt, setLastSeenAt] = React.useState(null);
  const [chatRoom, setChatRoom] = React.useState(null);
  const [isTyping, setIsTyping] = React.useState(false);
  const [msg, setMsg] = React.useState(null);

  const fetchLastSeen = async (who) => {
    // console.log(who);
    if (!chatRoom) {
      const res = await getCommonChatRoom({
        authUserID: auth.currentUser.uid,
        otherUserID: otherUser.id,
      });
      setChatRoom(res);
      // console.log(chatRoom?.id, "chat");
    }

    if (chatRoom) {
      const res = await getUserChatRoomLastSeen({
        UserID: otherUser.id,
        ChatRoomID: chatRoom?.id,
      });
      setLastSeenAt(res);
      // console.log(lastSeenAt, "lastSeen");

      updateUserChatRoomLastSeenAt({
        UserID: auth.currentUser.uid,
        ChatRoomID: chatRoom?.id,
      });
    }
  };

  React.useEffect(() => {
    fetchLastSeen("effetc");
  }, [chatRoom]);

  React.useEffect(() => {
    // Supabase client setup

    const channel = supabase.channel("online-users", {
      config: {
        presence: {
          key: auth.currentUser.uid,
        },
      },
    });

    channel.on("presence", { event: "sync" }, async () => {
      const onlineUsers = channel.presenceState();
      const ID = otherUser.id;
      if (onlineUsers[ID]) {
        const temp = onlineUsers[ID][0];
        // console.log("Online users: ", onlineUsers, temp.online_at);
        setUserOnline(
          onlineUsers.hasOwnProperty(otherUser.id) &&
            new Date().getTime() - temp.online_at < 10000
            ? true
            : false
        );
      } else {
        setUserOnline(false);
        fetchLastSeen();
      }
      // console.log(onlineUsers[otherUser.id] ? true : false);
    });
    let inter;

    channel.subscribe(async (status) => {
      if (status === "SUBSCRIBED") {
        inter = setInterval(async () => {
          const status = await channel.track({
            online_at: new Date().getTime(),
          });
        }, 5000);
      }
    });

    return () => {
      clearInterval(inter);
      supabase.removeChannel(channel);
      // console.log("channel removed");
    };
  }, [oUser]);
  let iter;
  const updateTyping = (payload) => {
    if (iter) clearTimeout(iter);
    console.log(payload);
    if (payload) {
      setIsTyping(true);
      setMsg(payload.msg);
      iter = setTimeout(() => {
        setIsTyping(false);
        setMsg(null);
      }, 4000);
    }
  };

  React.useEffect(() => {
    let channel;
    if (chatRoom) {
      channel = supabase.channel("broadcast");
      channel
        .on("broadcast", { event: "TYPING" }, (event) => {
          updateTyping(event.payload);
        })
        .subscribe();
    }
    return () => {
      if (channel) supabase.removeChannel(channel);
    };
  }, [chatRoom]);

  return (
    <>
      <>
        <AntDesign
          onPress={navigation.goBack}
          name="arrowleft"
          size={24}
          color="white"
        />
        <Image
          source={{ uri: image }}
          style={{
            width: 40,
            height: 40,
            borderRadius: 20,
            marginLeft: 15,
            marginRight: 15,
          }}
        />
      </>
      <View style={styles.root}>
        <Text style={{ color: "white", fontWeight: "bold", fontSize: 20 }}>
          {otherUser.name}
        </Text>
        {userOnline ? (
          isTyping ? (
            auth.currentUser.uid == admin ? (
              <Text numberOfLines={1} style={styles.online}>
                {"Typing: " + msg}
              </Text>
            ) : (
              <Text style={styles.online}>Typing...</Text>
            )
          ) : (
            <Text style={styles.online}>Online</Text>
          )
        ) : (
          lastSeenAt && (
            <Text style={styles.lastSeen}>
              {"Last seen " + dayjs(lastSeenAt).fromNow()}
            </Text>
          )
        )}
      </View>
    </>
  );
};

const styles = StyleSheet.create({
  root: {
    flexDirection: "column",
    // alignItems: "center",
    // padding: 10,
  },
  online: {
    color: myColors.PrimaryMessage,
    fontSize: 10,
    fontWeight: "bold",
  },
  lastSeen: {
    color: "white",
    fontSize: 10,
    // fontWeight: "bold",
  },
});

export default CustomHeader;
