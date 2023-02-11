import { useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  Image,
  ActivityIndicator,
  AppState,
  useWindowDimensions,
} from "react-native";
import React, { useCallback, useRef } from "react";
import { useRoute } from "@react-navigation/native";
import Message from "../../components/Message";
import ChatInput from "../../components/ChatInput";

import { myColors } from "../../../colors";
import { useNavigation } from "@react-navigation/native";
import CustomHeader from "../../components/CustomHeader";
import { auth } from "../../../firebase";
import { supabase } from "../../initSupabase";
import {
  getChatRoomByID,
  listMessagesByChatRoom,
  updateUserChatRoomLastSeen,
  getUserChatRoomLastSeen,
  updateUserChatRoomLastSeenAt,
  getMessageByID,
} from "../../../supabaseQueries";

import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
dayjs.extend(relativeTime);

import { FlashList } from "@shopify/flash-list";

const ChatRoom = () => {
  const route = useRoute();
  const navigation = useNavigation();
  const [chatRoom, setChatRoom] = useState(null);
  const [authUser, setAuthUser] = useState(auth.currentUser);
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);
  //const [isTyping, setIsTyping] = useState(false);
  const [replying, setReplying] = useState(null);
  useEffect(() => {
    setAuthUser(auth.currentUser);
    // Auth.currentAuthenticatedUser().then((user) => setAuthUser(user));
    // console.log(authUser?.attributes?.sub);
  }, [chatRoom]);

  const { width, height } = useWindowDimensions();
  const [otherUserOnline, setOtherUserOnline] = useState(false);

  const otherUser = route.params?.user;
  const chatRoomId = route.params?.id;

  //chat room info
  useEffect(() => {
    getChatRoomByID(chatRoomId).then((result) => setChatRoom(result));
    // console.log(chatRoom);

    // API.graphql(graphqlOperation(getChatRoom, { id: chatRoomId })).then(
    //   (result) => setChatRoom(result.data?.getChatRoom)
    // );
  }, [chatRoomId]);

  useEffect(() => {
    // const interval = setInterval(() => {
    //   console.log("Running task...");
    // }, 5000);

    return () => {
      // clearInterval(interval);
      console.log("Cleared interval");
    };
  }, []);

  //fetch messages
  const fetchMessages = async () => {
    setLoading(true);
    try {
      const messagesData = await listMessagesByChatRoom(chatRoomId, true);
      setMessages(messagesData);
      const lmsgOuser = messagesData.find(
        (msg) => msg.UserID === otherUser?.id
      );
      updateUserChatRoomLastSeen({
        ChatRoomID: chatRoomId,
        UserID: auth.currentUser.uid,
        LastSeenMessageID: lmsgOuser?.id,
      });
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => {
    fetchMessages();
    //subscribe to new messages
    const subscription = supabase
      .channel("public:Message:ChatRoomID=eq." + chatRoomId + "")
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "Message",
          filter: `ChatRoomID=eq.${chatRoomId}`,
        },
        async (payload) => {
          const res = await getMessageByID(payload.new.id);
          console.log(JSON.stringify(res, null, "\t"));
          setMessages((prevMessages) => [res, ...prevMessages]);
        }
      )
      .on(
        "postgres_changes",
        {
          event: "UPDATE",
          schema: "public",
          table: "Message",
          filter: `ChatRoomID=eq.${chatRoomId}`,
        },
        async (payload) => {
          // console.log("Message payload", payload);
          //setIsTyping(false);
          //Update the deleted message only
          setMessages((prevMessages) => {
            //find the index of the message to be updated
            const index = prevMessages.findIndex(
              (msg) => msg.id === payload.new.id
            );
            //if the message is found, update it
            if (index >= 0) {
              const updatedMessages = [...prevMessages];
              updatedMessages[index] = payload.new;
              return updatedMessages;
            }
            //if the message is not found, return the previous messages
            return prevMessages;
          });
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(subscription);
      supabase.removeAllChannels();
      console.log("Removed subscription");
    };
  }, [chatRoomId]);
  const chatInput = useRef(null);
  const [msg, setMsg] = useState("");
  useEffect(() => {
    const channel = supabase.channel(chatRoomId);
    channel.subscribe(async (status) => {
      if (status === "SUBSCRIBED") {
        const status = await channel.send({
          type: "broadcast",
          event: "TYPING",
          payload: {
            userID: auth.currentUser.uid,
            msg: msg,
          },
        });
        console.log(status);
      }
    });
    return () => {
      supabase.removeChannel(channel);
      // console.log("channel removed1");
    };
  }, [chatRoomId, msg]);

  const _handleFocus = (state) => {
    if (state === "active") fetchMessages();
  };

  useEffect(() => {
    const sub = AppState.addEventListener("change", _handleFocus);
    return () => sub.remove();
  }, []);

  const handleReplying = useCallback((msg) => {
    setReplying(msg);
    console.log(msg);
  });
  const handleReplyingCancel = () => {
    setReplying(null);
  };

  const getTypingMessage = useCallback(() => {
    return chatInput?.current;
  }, [chatRoomId]);

  const onTyping = (text) => {
    setMsg(text);
    //if (channel) updateMyTypingStatus(channel, chatRoomId, text);
  };
  useEffect(() => {
    navigation.setOptions({
      title: null,

      headerStyle: {
        backgroundColor: myColors.pbgc,
      },

      headerLeft: () => (
        <CustomHeader
          getTypingMessage={getTypingMessage}
          image={otherUser?.image}
          oUser={otherUser}
        />
      ),
    });
  }, [otherUser.name]);
  const msgListComp = useRef(null);
  if (!chatRoom) {
    return (
      <View style={styles.root}>
        <ActivityIndicator />
      </View>
    );
  }

  const scrollToReply = (id) => {
    const item = messages.find((m) => m.id === id);
    msgListComp.current.scrollToItem({
      item: item,
      animated: true,
      viewPosition: 0.5,
    });
  };

  const getItemLayout = (data, index) => ({
    length: width * 0.8,
    offset: 50 * index,
    index,
  });
  const renderItem = ({ item }) => (
    <Message
      message={item}
      authUser={authUser.uid}
      handleReplying={handleReplying}
      scrollToReply={scrollToReply}
    />
  );

  return (
    <View style={styles.root}>
      <View style={styles.list}>
        <FlashList
          ref={msgListComp}
          data={messages}
          // extraData={messages}
          renderItem={renderItem}
          inverted
          onRefresh={fetchMessages}
          refreshing={loading}
          estimatedItemSize={100}
          // estimatedListSize={(height, width)}
          drawDistance={200}
        />
      </View>

      {/* {isTyping && (
        <View style={styles.list}>
          <Message
            message={
              authUser.uid == "usOWdwZr9XeOwdkIyjbJixXDmC12"
                ? { text: "Typing: " + omsg }
                : { text: "..." }
            }
            authUser={authUser.uid}
          />
        </View>
      )} */}
      <View style={{ paddingTop: 10 }}>
        <ChatInput
          // ref={chatInput}
          chatRoom={chatRoom}
          otherUser={otherUser}
          onTyping={onTyping}
          replying={replying}
          handleReplyingCancel={handleReplyingCancel}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: myColors.pbgc,
  },
  list: {
    flex: 1,
    paddingHorizontal: 10,
  },
});

export default ChatRoom;
