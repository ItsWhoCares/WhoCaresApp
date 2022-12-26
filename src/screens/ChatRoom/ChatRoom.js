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
  useEffect(() => {
    setAuthUser(auth.currentUser);
    // Auth.currentAuthenticatedUser().then((user) => setAuthUser(user));
    // console.log(authUser?.attributes?.sub);
  }, [chatRoom]);

  const [otherUserOnline, setOtherUserOnline] = useState(false);

  const otherUser = route.params?.user;
  const chatRoomId = route.params?.id;

  useEffect(() => {
    navigation.setOptions({
      title: null,
      // headerTitleAlign: "left",
      // headerTitleStyle: {
      //   color: "white",
      // },
      headerStyle: {
        backgroundColor: myColors.pbgc,
        // marginLeft: 10,
      },
      // headerBackImageSource: user.image,
      headerLeft: () => (
        <CustomHeader
          image={otherUser?.image}
          online={false}
          oUser={otherUser}
        />
      ),
    });
  }, [otherUser.name]);
  // const msg = messages.filter((m) => m.chatId === id);

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

  // useEffect(() => {
  //   // Supabase client setup

  //   const channel = supabase.channel("online-users", {
  //     config: {
  //       presence: {
  //         key: authUser.uid,
  //       },
  //     },
  //   });

  //   channel.on("presence", { event: "sync" }, async () => {
  //     const onlineUsers = channel.presenceState();
  //     // console.log("Online users: ", onlineUsers);
  //     console.log("Online users: ", onlineUsers);
  //     setOtherUserOnline(onlineUsers[otherUser.id] ? true : false);
  //     console.log(onlineUsers[otherUser.id] ? true : false);
  //   });

  //   // channel.on("presence", { event: "join" }, ({ newPresences }) => {
  //   //   console.log("New users have joined: ", newPresences);
  //   // });

  //   // channel.on("presence", { event: "leave" }, ({ leftPresences }) => {
  //   //   console.log("Users have left: ", leftPresences);
  //   // });
  //   let inter;

  //   channel.subscribe(async (status) => {
  //     if (status === "SUBSCRIBED") {
  //       inter = setInterval(async () => {
  //         const status = await channel.track({
  //           online_at: new Date().toISOString(),
  //         });
  //       }, 10000);
  //     }
  //   });
  //   return () => {
  //     clearInterval(inter);
  //     supabase.removeChannel(channel);
  //     console.log("channel removed");
  //   };
  // }, [chatRoomId]);

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
      <View style={{ paddingTop: 10 }}>
        <ChatInput chatRoom={chatRoom} otherUser={otherUser} />
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
