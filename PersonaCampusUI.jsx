import { useState } from 'react';
import { User, Users, Calendar, Award, Activity, BookOpen, Coffee, MapPin, QrCode, Settings, BarChart2, Zap, Heart, Star } from 'lucide-react';

export default function PersonaCampusUI() {
  const [activeTab, setActiveTab] = useState('profile');
  const [showQrScanner, setShowQrScanner] = useState(false);
  const [notifications, setNotifications] = useState([
    { id: 1, text: "Workshop Desain UI/UX hari ini!", type: "event" },
    { id: 2, text: "Arya mengajakmu ke kafe kampus", type: "social" },
    { id: 3, text: "Level sosial naik ke level 12!", type: "levelUp" }
  ]);

  // Dummy user data
  const userData = {
    name: "Kiraitsu Mochizuki",
    level: 17,
    type: "The Creative One",
    xp: 2570,
    nextLevel: 3000,
    skills: [
      { name: "Social", level: 12, progress: 75 },
      { name: "Academic", level: 8, progress: 30 },
      { name: "Leadership", level: 5, progress: 60 },
      { name: "Creativity", level: 15, progress: 90 }
    ],
    achievements: [
      "Si Paling Membantu",
      "Master Debater",
      "Event Organizer Pro"
    ],
    friends: [
      { name: "Budi", type: "The Leader", level: 19 },
      { name: "Cindy", type: "The Silent One", level: 15 },
      { name: "Deni", type: "The Athlete", level: 20 }
    ],
    events: [
      { name: "Workshop Python", time: "Rabu, 15:00", points: 50, type: "academic" },
      { name: "Rapat Panitia Festival", time: "Jumat, 13:00", points: 75, type: "leadership" },
      { name: "Nongkrong Bareng Anak DKV", time: "Sabtu, 19:00", points: 40, type: "social" }
    ]
  };

  const renderContent = () => {
    switch(activeTab) {
      case 'profile':
        return (
          <div className="p-4">
            <div className="bg-indigo-900 rounded-xl p-6 text-white relative overflow-hidden mb-6">
              <div className="absolute top-0 right-0 w-32 h-32 bg-indigo-800 rounded-full -mr-16 -mt-16 opacity-50"></div>
              <div className="absolute bottom-0 left-0 w-24 h-24 bg-indigo-800 rounded-full -ml-12 -mb-12 opacity-50"></div>
              
              <div className="flex items-center mb-4 relative z-10">
                <div className="w-16 h-16 bg-indigo-600 rounded-full flex items-center justify-center border-2 border-yellow-400">
                  <User size={28} className="text-white" />
                </div>
                <div className="ml-4">
                  <h2 className="text-xl font-bold">{userData.name}</h2>
                  <div className="flex items-center">
                    <span className="bg-yellow-500 text-black text-xs font-bold px-2 py-1 rounded">LVL {userData.level}</span>
                    <span className="ml-2 text-sm">{userData.type}</span>
                  </div>
                </div>
                <div className="ml-auto">
                  <div className="bg-black bg-opacity-30 p-2 rounded-full">
                    <Settings size={20} />
                  </div>
                </div>
              </div>
              
              <div className="relative z-10">
                <div className="flex justify-between text-xs mb-1">
                  <span>XP: {userData.xp}/{userData.nextLevel}</span>
                  <span>{Math.round((userData.xp/userData.nextLevel)*100)}%</span>
                </div>
                <div className="w-full bg-black bg-opacity-30 rounded-full h-2">
                  <div className="bg-yellow-400 h-2 rounded-full" style={{width: `${(userData.xp/userData.nextLevel)*100}%`}}></div>
                </div>
              </div>
            </div>
            
            <div className="bg-gray-900 rounded-xl p-4 mb-6">
              <h3 className="text-white font-bold flex items-center mb-3">
                <Zap size={18} className="text-yellow-400 mr-2" />
                Skills
              </h3>
              <div className="space-y-3">
                {userData.skills.map((skill, index) => (
                  <div key={index}>
                    <div className="flex justify-between text-sm text-white mb-1">
                      <span>{skill.name}</span>
                      <span className="text-yellow-400">Lv.{skill.level}</span>
                    </div>
                    <div className="w-full bg-gray-800 rounded-full h-2">
                      <div className={`h-2 rounded-full ${getSkillColor(skill.name)}`} style={{width: `${skill.progress}%`}}></div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            
            <div className="bg-gray-900 rounded-xl p-4 mb-6">
              <h3 className="text-white font-bold flex items-center mb-3">
                <Award size={18} className="text-yellow-400 mr-2" />
                Achievements
              </h3>
              <div className="flex flex-wrap gap-2">
                {userData.achievements.map((achievement, index) => (
                  <span key={index} className="bg-indigo-800 text-white text-xs px-3 py-1 rounded-full">
                    {achievement}
                  </span>
                ))}
              </div>
            </div>
          </div>
        );
      
      case 'social':
        return (
          <div className="p-4">
            <div className="bg-gray-900 rounded-xl p-4 mb-4">
              <h3 className="text-white font-bold mb-3">Teman Terdekat</h3>
              {userData.friends.map((friend, index) => (
                <div key={index} className="flex items-center mb-3 p-2 bg-gray-800 rounded-lg">
                  <div className="w-10 h-10 bg-indigo-600 rounded-full flex items-center justify-center">
                    <User size={18} className="text-white" />
                  </div>
                  <div className="ml-3">
                    <div className="text-white font-medium">{friend.name}</div>
                    <div className="text-gray-400 text-xs">{friend.type} • Lv.{friend.level}</div>
                  </div>
                  <div className="ml-auto">
                    <button className="bg-indigo-600 text-white text-xs px-3 py-1 rounded-full">Chat</button>
                  </div>
                </div>
              ))}
              <button className="w-full bg-indigo-800 hover:bg-indigo-700 text-white rounded-lg p-2 mt-2 text-sm">
                Cari Teman Baru
              </button>
            </div>
            
            <div className="bg-gray-900 rounded-xl p-4">
              <h3 className="text-white font-bold mb-3">Rekomendasi Koneksi</h3>
              <div className="grid grid-cols-2 gap-3">
                <div className="bg-gray-800 p-3 rounded-lg">
                  <div className="flex items-center mb-2">
                    <div className="w-8 h-8 bg-purple-600 rounded-full flex items-center justify-center">
                      <User size={16} className="text-white" />
                    </div>
                    <div className="ml-2">
                      <div className="text-white text-sm">Rina</div>
                      <div className="text-gray-400 text-xs">The Creative One</div>
                    </div>
                  </div>
                  <button className="w-full bg-purple-800 hover:bg-purple-700 text-white rounded-lg p-1 text-xs">
                    Kirim Request
                  </button>
                </div>
                <div className="bg-gray-800 p-3 rounded-lg">
                  <div className="flex items-center mb-2">
                    <div className="w-8 h-8 bg-green-600 rounded-full flex items-center justify-center">
                      <User size={16} className="text-white" />
                    </div>
                    <div className="ml-2">
                      <div className="text-white text-sm">Tono</div>
                      <div className="text-gray-400 text-xs">The Leader</div>
                    </div>
                  </div>
                  <button className="w-full bg-green-800 hover:bg-green-700 text-white rounded-lg p-1 text-xs">
                    Kirim Request
                  </button>
                </div>
              </div>
            </div>
          </div>
        );
      
      case 'events':
        return (
          <div className="p-4">
            <div className="flex gap-2 mb-4">
              <button className="bg-indigo-600 text-white px-4 py-2 rounded-lg flex-1 text-sm">Upcoming</button>
              <button className="bg-gray-800 text-gray-300 px-4 py-2 rounded-lg flex-1 text-sm">My Events</button>
              <button className="bg-gray-800 text-gray-300 px-4 py-2 rounded-lg flex-1 text-sm">Explore</button>
            </div>
            
            {userData.events.map((event, index) => (
              <div key={index} className={`mb-3 p-3 rounded-lg border-l-4 ${getEventBorderColor(event.type)}`} style={{backgroundColor: 'rgba(26, 32, 44, 0.8)'}}>
                <div className="flex items-center">
                  <div className={`w-10 h-10 ${getEventBgColor(event.type)} rounded-lg flex items-center justify-center`}>
                    {getEventIcon(event.type)}
                  </div>
                  <div className="ml-3 flex-1">
                    <div className="text-white font-medium">{event.name}</div>
                    <div className="text-gray-400 text-xs flex items-center">
                      <Calendar size={12} className="mr-1" />
                      {event.time}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-yellow-400 font-bold text-sm">+{event.points} XP</div>
                    <button className="bg-gray-700 text-white text-xs px-2 py-1 rounded mt-1">Join</button>
                  </div>
                </div>
              </div>
            ))}
            
            <button className="w-full bg-indigo-800 hover:bg-indigo-700 text-white rounded-lg p-3 mt-3 flex items-center justify-center">
              <Calendar size={18} className="mr-2" />
              View Full Calendar
            </button>
          </div>
        );
        
      case 'scan':
        return (
          <div className="p-4">
            {showQrScanner ? (
              <div className="flex flex-col items-center">
                <div className="bg-gray-900 p-6 rounded-xl mb-6 w-full max-w-xs aspect-square relative">
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div className="w-48 h-48 border-2 border-indigo-500 relative">
                      <div className="absolute top-0 left-0 w-4 h-4 border-t-2 border-l-2 border-indigo-400"></div>
                      <div className="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-indigo-400"></div>
                      <div className="absolute bottom-0 left-0 w-4 h-4 border-b-2 border-l-2 border-indigo-400"></div>
                      <div className="absolute bottom-0 right-0 w-4 h-4 border-b-2 border-r-2 border-indigo-400"></div>
                    </div>
                    <div className="absolute w-full h-1 bg-indigo-500 opacity-50 animate-pulse"></div>
                  </div>
                </div>
                
                <div className="bg-gray-900 rounded-xl p-4 w-full mb-4">
                  <h3 className="text-white font-bold text-center mb-2">Scanning QR...</h3>
                  <p className="text-gray-400 text-sm text-center">Position the QR code within the frame to scan</p>
                </div>
                
                <button 
                  className="bg-red-600 hover:bg-red-700 text-white rounded-lg p-3 mb-3 w-full"
                  onClick={() => setShowQrScanner(false)}
                >
                  Cancel Scan
                </button>
              </div>
            ) : (
              <div>
                <div className="bg-gray-900 rounded-xl p-6 mb-6">
                  <h3 className="text-white font-bold text-center mb-4">Scan QR to Earn XP</h3>
                  <div className="flex flex-col items-center">
                    <div className="w-24 h-24 bg-indigo-900 rounded-full flex items-center justify-center mb-4">
                      <QrCode size={40} className="text-white" />
                    </div>
                    <p className="text-gray-300 text-sm text-center mb-6">
                      Scan QR codes at events, meetings, or when hanging out with friends to earn XP and level up your character!
                    </p>
                    <button 
                      className="bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg p-3 mb-3 w-full"
                      onClick={() => setShowQrScanner(true)}
                    >
                      Start Scanning
                    </button>
                  </div>
                </div>
                
                <div className="bg-gray-900 rounded-xl p-4">
                  <h3 className="text-white font-bold mb-3">Recent Activity</h3>
                  <div className="space-y-3">
                    <div className="bg-gray-800 p-3 rounded-lg flex items-center">
                      <div className="w-10 h-10 bg-green-800 rounded-lg flex items-center justify-center">
                        <Award size={18} className="text-green-400" />
                      </div>
                      <div className="ml-3 flex-1">
                        <div className="text-white text-sm">Workshop Python</div>
                        <div className="text-gray-400 text-xs">Academic XP +50</div>
                      </div>
                      <div className="text-gray-400 text-xs">Today</div>
                    </div>
                    <div className="bg-gray-800 p-3 rounded-lg flex items-center">
                      <div className="w-10 h-10 bg-blue-800 rounded-lg flex items-center justify-center">
                        <Users size={18} className="text-blue-400" />
                      </div>
                      <div className="ml-3 flex-1">
                        <div className="text-white text-sm">Nongkrong dengan Budi</div>
                        <div className="text-gray-400 text-xs">Social XP +30</div>
                      </div>
                      <div className="text-gray-400 text-xs">Yesterday</div>
                    </div>
                    <div className="bg-gray-800 p-3 rounded-lg flex items-center">
                      <div className="w-10 h-10 bg-purple-800 rounded-lg flex items-center justify-center">
                        <Activity size={18} className="text-purple-400" />
                      </div>
                      <div className="ml-3 flex-1">
                        <div className="text-white text-sm">Rapat Panitia</div>
                        <div className="text-gray-400 text-xs">Leadership XP +45</div>
                      </div>
                      <div className="text-gray-400 text-xs">3 days ago</div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        );
        
      case 'stats':
        return (
          <div className="p-4">
            <div className="bg-gray-900 rounded-xl p-4 mb-6">
              <h3 className="text-white font-bold mb-3">Character Stats</h3>
              <div className="grid grid-cols-2 gap-3">
                <div className="bg-gray-800 p-3 rounded-lg">
                  <div className="text-gray-400 text-xs mb-1">Social Influence</div>
                  <div className="text-white font-bold text-xl">78<span className="text-green-500 text-sm ml-1">↑12%</span></div>
                </div>
                <div className="bg-gray-800 p-3 rounded-lg">
                  <div className="text-gray-400 text-xs mb-1">Academic Standing</div>
                  <div className="text-white font-bold text-xl">65<span className="text-green-500 text-sm ml-1">↑5%</span></div>
                </div>
                <div className="bg-gray-800 p-3 rounded-lg">
                  <div className="text-gray-400 text-xs mb-1">Leadership</div>
                  <div className="text-white font-bold text-xl">42<span className="text-yellow-500 text-sm ml-1">↑1%</span></div>
                </div>
                <div className="bg-gray-800 p-3 rounded-lg">
                  <div className="text-gray-400 text-xs mb-1">Creativity</div>
                  <div className="text-white font-bold text-xl">91<span className="text-green-500 text-sm ml-1">↑8%</span></div>
                </div>
              </div>
            </div>
            
            <div className="bg-gray-900 rounded-xl p-4 mb-6">
              <h3 className="text-white font-bold mb-3">Activity Summary</h3>
              <div className="flex mb-3">
                <div className="flex-1 text-center p-2 border-b-2 border-indigo-500 text-white">Weekly</div>
                <div className="flex-1 text-center p-2 text-gray-400">Monthly</div>
                <div className="flex-1 text-center p-2 text-gray-400">All Time</div>
              </div>
              <div className="h-40 flex items-end justify-between px-2">
                <div className="flex flex-col items-center">
                  <div className="w-8 bg-indigo-600 rounded-t-lg" style={{height: '50px'}}></div>
                  <div className="text-xs text-gray-400 mt-1">Mon</div>
                </div>
                <div className="flex flex-col items-center">
                  <div className="w-8 bg-indigo-600 rounded-t-lg" style={{height: '80px'}}></div>
                  <div className="text-xs text-gray-400 mt-1">Tue</div>
                </div>
                <div className="flex flex-col items-center">
                  <div className="w-8 bg-indigo-600 rounded-t-lg" style={{height: '30px'}}></div>
                  <div className="text-xs text-gray-400 mt-1">Wed</div>
                </div>
                <div className="flex flex-col items-center">
                  <div className="w-8 bg-indigo-600 rounded-t-lg" style={{height: '120px'}}></div>
                  <div className="text-xs text-gray-400 mt-1">Thu</div>
                </div>
                <div className="flex flex-col items-center">
                  <div className="w-8 bg-indigo-600 rounded-t-lg" style={{height: '70px'}}></div>
                  <div className="text-xs text-gray-400 mt-1">Fri</div>
                </div>
                <div className="flex flex-col items-center">
                  <div className="w-8 bg-indigo-600 rounded-t-lg" style={{height: '100px'}}></div>
                  <div className="text-xs text-gray-400 mt-1">Sat</div>
                </div>
                <div className="flex flex-col items-center">
                  <div className="w-8 bg-indigo-600 rounded-t-lg" style={{height: '60px'}}></div>
                  <div className="text-xs text-gray-400 mt-1">Sun</div>
                </div>
              </div>
            </div>
            
            <div className="bg-gray-900 rounded-xl p-4">
              <h3 className="text-white font-bold mb-3">Top Skills & Traits</h3>
              <div className="space-y-3">
                <div className="bg-gray-800 p-3 rounded-lg flex items-center">
                  <div className="w-8 h-8 bg-yellow-800 rounded-full flex items-center justify-center">
                    <Star size={16} className="text-yellow-400" />
                  </div>
                  <div className="ml-3 flex-1">
                    <div className="text-white text-sm">Si Paling Membantu</div>
                    <div className="text-gray-400 text-xs">Unlocked 2 weeks ago</div>
                  </div>
                  <div className="text-yellow-400 font-bold">S+</div>
                </div>
                <div className="bg-gray-800 p-3 rounded-lg flex items-center">
                  <div className="w-8 h-8 bg-purple-800 rounded-full flex items-center justify-center">
                    <Heart size={16} className="text-purple-400" />
                  </div>
                  <div className="ml-3 flex-1">
                    <div className="text-white text-sm">Master Debater</div>
                    <div className="text-gray-400 text-xs">Unlocked 1 month ago</div>
                  </div>
                  <div className="text-purple-400 font-bold">A</div>
                </div>
              </div>
            </div>
          </div>
        );
      
      default:
        return null;
    }
  };

  // Helper functions for styling
  function getEventBorderColor(type) {
    switch(type) {
      case 'academic': return 'border-green-500';
      case 'social': return 'border-blue-500';
      case 'leadership': return 'border-purple-500';
      default: return 'border-gray-500';
    }
  }
  
  function getEventBgColor(type) {
    switch(type) {
      case 'academic': return 'bg-green-900';
      case 'social': return 'bg-blue-900';
      case 'leadership': return 'bg-purple-900';
      default: return 'bg-gray-700';
    }
  }
  
  function getEventIcon(type) {
    switch(type) {
      case 'academic': return <BookOpen size={18} className="text-green-400" />;
      case 'social': return <Coffee size={18} className="text-blue-400" />;
      case 'leadership': return <Award size={18} className="text-purple-400" />;
      default: return <Calendar size={18} className="text-gray-400" />;
    }
  }
  
  function getSkillColor(type) {
    switch(type) {
      case 'Social': return 'bg-blue-500';
      case 'Academic': return 'bg-green-500';
      case 'Leadership': return 'bg-purple-500';
      case 'Creativity': return 'bg-pink-500';
      default: return 'bg-gray-500';
    }
  }

  return (
    <div className="min-h-screen bg-black text-white font-sans flex flex-col">
      {/* Header with notifications */}
      <header className="p-4 bg-gray-900 flex items-center justify-between">
        <div className="flex items-center">
          <div className="w-8 h-8 bg-indigo-600 rounded-full flex items-center justify-center">
            <User size={16} className="text-white" />
          </div>
          <div className="ml-2">
            <div className="text-sm font-bold">{userData.name}</div>
            <div className="text-xs text-gray-400">Lv.{userData.level} • {userData.type}</div>
          </div>
        </div>
        
        <div className="relative">
          <div className="bg-gray-800 rounded-full p-2 relative">
            {notifications.length > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs w-5 h-5 flex items-center justify-center rounded-full">
                {notifications.length}
              </span>
            )}
            <Bell size={18} className="text-white" />
          </div>
        </div>
      </header>
      
      {/* Main content */}
      <main className="flex-1 overflow-y-auto bg-gradient-to-b from-gray-900 to-black">
        {renderContent()}
      </main>
      
      {/* Bottom navigation */}
      <nav className="bg-gray-900 px-2 pt-2 pb-6">
        <div className="flex justify-around">
          <button 
            onClick={() => setActiveTab('profile')} 
            className={`p-2 rounded-lg flex flex-col items-center ${activeTab === 'profile' ? 'text-indigo-400' : 'text-gray-500'}`}
          >
            <User size={20} />
            <span className="text-xs mt-1">Profile</span>
          </button>
          <button 
            onClick={() => setActiveTab('social')} 
            className={`p-2 rounded-lg flex flex-col items-center ${activeTab === 'social' ? 'text-indigo-400' : 'text-gray-500'}`}
          >
            <Users size={20} />
            <span className="text-xs mt-1">Social</span>
          </button>
          <button 
            onClick={() => setActiveTab('events')} 
            className={`p-2 rounded-lg flex flex-col items-center ${activeTab === 'events' ? 'text-indigo-400' : 'text-gray-500'}`}
          >
            <Calendar size={20} />
            <span className="text-xs mt-1">Events</span>
          </button>
          <button 
            onClick={() => setActiveTab('scan')} 
            className={`p-2 rounded-lg flex flex-col items-center ${activeTab === 'scan' ? 'text-indigo-400' : 'text-gray-500'}`}
          >
            <QrCode size={20} />
            <span className="text-xs mt-1">Scan QR</span>
          </button>
          <button 
            onClick={() => setActiveTab('stats')} 
            className={`p-2 rounded-lg flex flex-col items-center ${activeTab === 'stats' ? 'text-indigo-400' : 'text-gray-500'}`}
          >
            <BarChart2 size={20} />
            <span className="text-xs mt-1">Stats</span>
          </button>
        </div>
      </nav>
    </div>
  );
}

// Bell icon component missing from lucide-react import
function Bell(props) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={props.size || 24}
      height={props.size || 24}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={props.className}
    >
      <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
      <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
    </svg>
  );
}
