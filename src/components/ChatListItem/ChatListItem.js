import { View, Text, StyleSheet, Image, Pressable } from "react-native";
import React, { useEffect, useState } from "react";
import { useNavigation } from "@react-navigation/native";
import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import { myColors } from "../../../colors";
dayjs.extend(relativeTime);

import { auth } from "../../../firebase";
import { supabase } from "../../initSupabase";
import { getMessageByID } from "../../initSupabase";

// import * as Notifications from "expo-notifications";

const ChatListItem = ({ chat, onPress }) => {
  const navigation = useNavigation();
  const [otherUser, setOtherUser] = useState(chat.User);
  const [chatRoom, setChatRoom] = useState(chat);
  // console.log(console.log("hehe", JSON.stringify(chat, null, "\t")));
  useEffect(() => {
    const fetchUser = async () => {
      // console.log("yeyeyeye");
      // const authUser = auth.currentUser;
      // const userItem = chatRoom.users.find((item) => item?.id !== authUser.uid);
      // setUser(userItem?.users);
      // console.log(userItem);
    };
    fetchUser();

    // Notifications.setNotificationHandler({
    //   handleNotification: async () => ({
    //     shouldShowAlert: true,
    //     shouldPlaySound: true,
    //     shouldSetBadge: false,
    //   }),
    // });

    // console.log(chat.ChatRoom.id);
    // Subscribe to onUpdateChatRoom
    const subscription = supabase
      .channel("public:ChatRoom:id=eq." + chat.ChatRoom.id + "")
      .on(
        "postgres_changes",
        {
          event: "UPDATE",
          schema: "public",
          table: "ChatRoom",
          filter: `id=eq.${chat.ChatRoom.id}`,
        },
        async (payload) => {
          // console.log(
          //   "Before",
          //   auth.currentUser.uid,
          //   JSON.stringify(chatRoom, null, "\t")
          // );
          //Update the chat room last message

          if (payload.new.id === chatRoom.ChatRoom.id) {
            const newChatRoom = { ...chatRoom } || {};
            newChatRoom.ChatRoom.LastMessageID = payload.new.LastMessageID;
            const newMsg = await getMessageByID(payload.new.LastMessageID);
            newChatRoom.ChatRoom.LastMessage = newMsg;
            setChatRoom(newChatRoom);
            // const res = await fetch("https://exp.host/--/api/v2/push/send", {
            //   method: "POST",
            //   headers: {
            //     "Content-Type": "application/json",
            //   },
            //   // body: '{"to": "ExponentPushToken[KBqO4ID4i4FW6nA3vpdgt4]","title":"hello","body": "world"}',
            //   body: JSON.stringify({
            //     to: "ExponentPushToken[KBqO4ID4i4FW6nA3vpdgt4]",
            //     title: otherUser.name,
            //     body: newMsg.text,
            //   }),
            // });
            // console.log(JSON.stringify(res, null, "\t"));
          }

          // console.log(
          //   "After",
          //   auth.currentUser.uid,
          //   JSON.stringify(chatRoom, null, "\t")
          // );
        }
      )
      .subscribe();

    return () => supabase.removeChannel(subscription);
  }, [chat.ChatRoom.id]);

  //check for not Auth user
  if (chatRoom?.ChatRoom?.LastMessage.text == "Send first message") {
    return null;
  }

  return (
    <Pressable
      style={({ pressed }) =>
        pressed ? [styles.containerPressed] : styles.container
      }
      onPress={() =>
        navigation.navigate("ChatRoom", {
          id: chatRoom?.ChatRoom?.id,
          user: {
            id: otherUser.id,
            name: otherUser.name,
            image: otherUser.image,
          },
        })
      }>
      <Image style={styles.image} source={{ uri: otherUser?.image }} />
      <View style={styles.content}>
        <View style={styles.row}>
          <Text numberOfLines={1} style={styles.name}>
            {otherUser?.name}
          </Text>
          {chatRoom?.ChatRoom.LastMessage && (
            <Text numberOfLines={2} style={styles.time}>
              {dayjs(chatRoom?.ChatRoom?.LastMessage?.created_at).fromNow(true)}
            </Text>
          )}
        </View>

        <Text style={styles.text} numberOfLines={2}>
          {chatRoom?.ChatRoom.LastMessage?.text}
        </Text>
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: "row",
    marginHorizontal: 10,
    marginVertical: 5,
    height: 80,

    // backgroundColor: myColors.containerPressed,
    borderRadius: 10,
    padding: 5,
    // borderBottomWidth: StyleSheet.hairlineWidth,
    // borderBottomColor: "grey",
  },
  containerPressed: {
    backgroundColor: myColors.containerPressed,
    flexDirection: "row",
    marginHorizontal: 10,
    marginVertical: 5,
    borderRadius: 10,
    height: 80,
    padding: 5,
  },
  content: {
    flex: 1,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: "grey",
  },
  image: {
    width: 60,
    height: 60,
    borderRadius: 30,
    marginRight: 10,

    marginTop: 5,
  },
  row: {
    flexDirection: "row",
    marginBottom: 5,
  },
  name: {
    // fontWeight: "bold",
    fontSize: 16,
    color: "white",
    flex: 1,
  },
  time: {
    color: myColors.secondaryText,
    paddingHorizontal: 5,
  },
  text: {
    color: myColors.secondaryText,
  },
});

export default ChatListItem;
