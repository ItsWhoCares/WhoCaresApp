import { useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  Image,
  ActivityIndicator,
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
} from "../../../supabaseQueries";

const ChatRoom = () => {
  const route = useRoute();
  const navigation = useNavigation();
  const [chatRoom, setChatRoom] = useState(null);
  const [authUser, setAuthUser] = useState(auth.currentUser);
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isTyping, setIsTyping] = useState(false);
  useEffect(() => {
    setAuthUser(auth.currentUser);
    // Auth.currentAuthenticatedUser().then((user) => setAuthUser(user));
    // console.log(authUser?.attributes?.sub);
  }, [chatRoom]);

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
      const messagesData = await listMessagesByChatRoom(chatRoomId);
      setMessages(messagesData);
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
        (payload) => {
          // console.log("Message payload", payload);
          setMessages((prevMessages) => [payload.new, ...prevMessages]);
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

  // const onTyping = async (text) => {
  //   const channel = supabase.channel("user-typing", {
  //     config: {
  //       presence: {
  //         key: auth.currentUser.uid,
  //       },
  //     },
  //   });
  //   channel.subscribe(async (status) => {
  //     if (status === "SUBSCRIBED") {
  //       const status = await channel.track({
  //         typing: true,
  //         updatedAt: new Date().getTime(),
  //       });
  //       console.log(status);
  //     }
  //   });
  // };

  // useEffect((text) => {
  //   console.log("typing");
  //   const status = await channel.track({
  //     typing: true,
  //     updatedAt: new Date().getTime(),
  //   });
  //   console.log(status);
  // }, [typing]);

  useEffect(() => {
    navigation.setOptions({
      title: null,

      headerStyle: {
        backgroundColor: myColors.pbgc,
      },

      headerLeft: () => (
        <CustomHeader
          image={otherUser?.image}
          online={false}
          oUser={otherUser}
        />
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
  return (
    <View style={styles.root}>
      <FlatList
        data={messages}
        renderItem={({ item }) => (
          <Message message={item} authUser={authUser.uid} />
        )}
        style={styles.list}
        inverted
        onRefresh={fetchMessages}
        refreshing={loading}
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
