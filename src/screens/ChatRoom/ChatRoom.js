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
import React from "react";
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

const ChatRoom = () => {
  const route = useRoute();
  const navigation = useNavigation();
  const [chatRoom, setChatRoom] = useState(null);
  const [authUser, setAuthUser] = useState(auth.currentUser);
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isTyping, setIsTyping] = useState(false);
  const [replying, setReplying] = useState(null);
  useEffect(() => {
    setAuthUser(auth.currentUser);
    // Auth.currentAuthenticatedUser().then((user) => setAuthUser(user));
    // console.log(authUser?.attributes?.sub);
  }, [chatRoom]);

  const { width } = useWindowDimensions();
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
  const fetchMessages = async (noLimit = false) => {
    setLoading(true);
    try {
      const messagesData = await listMessagesByChatRoom(chatRoomId, noLimit);
      setMessages(messagesData);
      const lmsgOuser = messagesData.find(
        (msg) => msg.UserID === otherUser?.id
      );
      // console.log(lmsgOuser);

      updateUserChatRoomLastSeen({
        ChatRoomID: chatRoomId,
        UserID: auth.currentUser.uid,
        LastSeenMessageID: lmsgOuser.id,
      });
      // console.log(dayjs("2023-01-20T10:23:33.705+00:00").format("hh:mm A"));
    } catch (e) {
      console.log(e);
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
          // console.log("Message payload", payload);
          setIsTyping(false);
          const res = await getMessageByID(payload.new.id);
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
          setIsTyping(false);
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

    // console.log(subscription);

    return () => supabase.removeChannel(subscription);
  }, [chatRoomId]);

  const [msg, setMsg] = useState("");
  const [omsg, setOmsg] = useState("");
  const onTyping = (text) => {
    setMsg(text);
    // console.log(msg);
  };

  useEffect(() => {
    const channel = supabase.channel("user-typing", {
      config: {
        presence: {
          key: auth.currentUser.uid,
        },
      },
    });
    channel.subscribe(async (status) => {
      if (status === "SUBSCRIBED") {
        const status = await channel.track({
          typing: true,
          msg: msg,
          updatedAt: new Date().getTime(),
        });
      }
    });
    channel.on("presence", { event: "leave" }, async () => {
      updateUserChatRoomLastSeenAt({
        ChatRoomID: chatRoomId,
        UserID: auth.currentUser.uid,
      });
    });
    channel.on("presence", { event: "sync" }, async () => {
      const typingUsers = channel.presenceState();
      if (typingUsers.hasOwnProperty(otherUser?.id)) {
        // console.log(
        //   new Date().getTime() - typingUsers[otherUser.id][0].updatedAt,
        //   typingUsers[otherUser?.id][0].msg
        // );
        if (
          new Date().getTime() - typingUsers[otherUser?.id][0].updatedAt <
            10000 &&
          typingUsers[otherUser?.id][0].msg.length > 0
        ) {
          // console.log("he typed");
          setIsTyping(true);
          setOmsg(typingUsers[otherUser?.id][0].msg);
          setTimeout(() => {
            setIsTyping(false);
            setOmsg("...");
          }, 4000);
        }
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

  const handleReplying = (msg) => {
    setReplying(msg);
    console.log(msg);
  };
  const handleReplyingCancel = () => {
    setReplying(null);
  };

  useEffect(() => {
    navigation.setOptions({
      title: null,

      headerStyle: {
        backgroundColor: myColors.pbgc,
      },

      headerLeft: () => (
        <CustomHeader image={otherUser?.image} oUser={otherUser} />
      ),
    });
  }, [otherUser.name]);

  if (!chatRoom) {
    return (
      <View style={styles.root}>
        <ActivityIndicator />
      </View>
    );
  }

  const getItemLayout = (data, index) => ({
    length: width * 0.8,
    offset: 50 * index,
    index,
  });
  const renderItem = ({ item }) => (
    <Message
      key={item.id}
      message={item}
      authUser={authUser.uid}
      handleReplying={handleReplying}
    />
  );

  return (
    <View style={styles.root}>
      <FlatList
        data={messages}
        renderItem={renderItem}
        style={styles.list}
        inverted
        onRefresh={fetchMessages}
        refreshing={loading}
        getItemLayout={getItemLayout}
        onEndReached={() => {
          fetchMessages(true);
        }}
      />
      {isTyping && (
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
      )}
      <View style={{ paddingTop: 10 }}>
        <ChatInput
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
    paddingHorizontal: 10,
  },
});

export default ChatRoom;
